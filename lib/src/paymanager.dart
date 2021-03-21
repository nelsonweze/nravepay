import 'package:flutter/material.dart' hide ConnectionState, State;
import 'home.payment.dart';
import 'pages/choose_card.payment.dart';
import 'payment.dart';

class PayManager {
  PayManager._internal();

  static final PayManager _manager = PayManager._internal();

  factory PayManager() {
    return _manager;
  }

  Future<HttpResult> prompt({
    required BuildContext context,
    required PayInitializer initializer,
  }) async {
    assert(context != null);
    assert(initializer != null);
    print('proimpe');
    
    //fetch the APIs keys initially defined
    initializer.publicKey = NRavePayRepository.instance!.initializer.publicKey;
    initializer.encryptionKey =
        NRavePayRepository.instance!.initializer.encryptionKey;
    initializer.secKey = NRavePayRepository.instance!.initializer.secKey;
    // Validate the initializer params
    var error = ValidatorUtils.validateInitializer(initializer);
    print(error);
    if (error != null) {
      return HttpResult(
          status: HttpStatus.error,
          rawResponse: {'error': error},
          message: error);
    }
    NRavePayRepository.bootStrap(initializer);

    var result;
    if (initializer.useCard)
      result = await Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(
        builder: (context) => ChoosePaymentCard(
          initializer: initializer,
        ),
      ));
    else
      result = await showModalBottomSheet<HttpResult>(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          context: context,
          builder: (context) => Theme(
                data: _getDefaultTheme(context),
                child: PaymentWidget(),
              ));

    // Return a cancelled response if result is null
    return result == null ? HttpResult(status: HttpStatus.cancelled) : result;
  }

  ThemeData _getDefaultTheme(BuildContext context) {
    // Primary and accent colors are from Flutterwave's logo color
    return Theme.of(context).copyWith(
      primaryColor: Colors.black,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
    );
  }
}

class CardTransactionManager extends BaseTransactionManager {
  CardTransactionManager({required BuildContext context})
      : super(context: context);

  @override
  charge() async {
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.charge(payload!);

      setConnectionState(ConnectionState.done);

      flwRef = response.flwRef;

      var suggestedAuth = response.suggestedAuth?.toUpperCase();
      var authModelUsed = response.authModelUsed?.toUpperCase();
      var message = response.message!.toUpperCase();
      var chargeResponseCode = response.chargeResponseCode;

      if (message == PayConstants.AUTH_SUGGESTION) {
        if (suggestedAuth == PayConstants.PIN) {
          _onPinRequested();
          return;
        }

        if (suggestedAuth == PayConstants.AVS_VBVSECURECODE ||
            suggestedAuth == PayConstants.NO_AUTH_INTERNATIONAL) {
          _onBillingRequest();
          return;
        }
      }

      if (message == PayConstants.V_COMP) {
        if (chargeResponseCode == "02") {
          if (authModelUsed == PayConstants.ACCESS_OTP) {
            onOtpRequested(response.chargeResponseMessage);
            return;
          }

          if (authModelUsed == PayConstants.PIN) {
            _onPinRequested();
            return;
          }

          if (authModelUsed == PayConstants.VBV) {
            showWebAuthorization(response.authUrl);
            return;
          }
        }

        if (chargeResponseCode == "00") {
          _onNoAuthUsed();
          return;
        }
      }

      if (authModelUsed == PayConstants.GTB_OTP ||
          authModelUsed == PayConstants.ACCESS_OTP ||
          authModelUsed!.contains("OTP")) {
        onOtpRequested(response.chargeResponseMessage);
        return;
      }

      _onNoAuthUsed();
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  _onPinRequested() {
    var state = TransactionState(
      state: State.pin,
      callback: (pin) {
        if (pin != null && pin.length == 4) {
          payload!
            ..pin = pin
            ..suggestedAuth = PayConstants.PIN;
          _handlePinOrBillingInput();
        } else {
          handleError(
              e: NRavePayException(data: "PIN must be exactly 4 digits"));
        }
      },
    );
    transactionBloc!.setState(
      state,
    );
  }

  _onBillingRequest() {
    transactionBloc!.setState(
      TransactionState(
          state: State.avsSecure,
          callback: (map) {
            payload!
              ..suggestedAuth = PayConstants.NO_AUTH_INTERNATIONAL
              ..billingAddress = map["address"]
              ..billingCity = map["city"]
              ..billingZip = map["zip"]
              ..billingCountry = map["counntry"]
              ..billingState = map["state"];
            _handlePinOrBillingInput();
          }),
    );
  }

  _onNoAuthUsed() => reQueryTransaction();

  _onAVSVBVSecureCodeModelUsed(String? authUrl) => showWebAuthorization(authUrl);

  _handlePinOrBillingInput() async {
    setConnectionState(ConnectionState.waiting);

    try {
      var response = await service.charge(payload!);
      setConnectionState(ConnectionState.done);

      flwRef = response.flwRef;

      var responseCode = response.chargeResponseCode;

      if (response.hasData && responseCode != null) {
        if (responseCode == "00") {
          reQueryTransaction();
        } else if (responseCode == "02") {
          var authModel = response.authModelUsed?.toUpperCase();
          if (authModel == PayConstants.PIN) {
            onOtpRequested(response.chargeResponseMessage);
          } else if (authModel == PayConstants.AVS_VBVSECURECODE ||
              authModel == PayConstants.VBV) {
            _onAVSVBVSecureCodeModelUsed(response.authUrl);
          } else {
            reQueryTransaction();
          }
        } else {
          reQueryTransaction();
        }
      } else {
        reQueryTransaction();
      }
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }
}
