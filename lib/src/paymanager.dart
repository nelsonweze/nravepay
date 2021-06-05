import 'package:flutter/material.dart' hide ConnectionState, State;
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/util.payment.dart';
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
    print('starting payment');

    var repository = NRavePayRepository.instance;
    // Validate the initializer params
    var error = ValidatorUtils.validateInitializer(initializer);

    if (error != null) {
      print(error);
      return HttpResult(
          status: HttpStatus.error,
          rawResponse: {'error': error},
          message: error);
    }
    NRavePayRepository.update(initializer);
    var result =
        await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) => ChoosePaymentCard(
        initializer: initializer,
        cards: repository.cards ?? [],
        defaultCardID: repository.defaultCardId,
      ),
    ));
    // Return a cancelled response if result is null
    return result == null ? HttpResult(status: HttpStatus.cancelled) : result;
  }
}

class CardTransactionManager extends BaseTransactionManager {
  CardTransactionManager({required BuildContext context})
      : super(context: context);

  @override
  charge() async {
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.charge(payload);
      setConnectionState(ConnectionState.done);

      flwRef = response.flwRef;
      transactionId = response.id;
      bool isV2 = payload.version == Version.v2;
      var suggestedAuth = isV2
          ? response.suggestedAuth
          : response.meta.authorization?.mode.toUpperCase();
      var message = response.message;
      var chargeResponseStatus = response.chargeResponseStatus?.toUpperCase();
      var authModel = response.authModel?.toUpperCase();

      if (isTxPending(message, chargeResponseStatus)) {
        if (suggestedAuth == SuggestedAuth.PIN) {
          _onPinRequested();
          return;
        }

        if (suggestedAuth == SuggestedAuth.OTP) {
          onOtpRequested(response.chargeResponseMessage);
          return;
        }
        if (suggestedAuth == SuggestedAuth.AVS_NOAUTH ||
            suggestedAuth == SuggestedAuth.NO_AUTH ||
            suggestedAuth == SuggestedAuth.AVS_VBVSECURECODE) {
          _onBillingRequest();
          return;
        }

        if (suggestedAuth == SuggestedAuth.REDIRECT) {
          showWebAuthorization(response.meta.authorization!.redirect);
          return;
        }

        if (message == SuggestedAuth.V_COMP) {
          if (response.chargeResponseCode == "02") {
            if (authModel == SuggestedAuth.ACCESS_OTP ||
                authModel == SuggestedAuth.PIN) {
              print('pin requested');
              onOtpRequested(response.chargeResponseMessage);
              return;
            }

            if (authModel == SuggestedAuth.VBV) {
              showWebAuthorization(response.authUrl);
              return;
            }
          }

          if (response.chargeResponseCode == "00") {
            _onNoAuthUsed();
            return;
          }
        }
        if (authModel == SuggestedAuth.GTB_OTP ||
            authModel == SuggestedAuth.ACCESS_OTP ||
            (authModel != null && authModel.contains("OTP"))) {
          onOtpRequested(response.chargeResponseMessage);
          return;
        }
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
          payload.authorization!
            ..pin = pin
            ..mode = SuggestedAuth.PIN;
          _handlePinOrBillingInput();
        } else {
          handleError(
              e: NRavePayException(data: "PIN must be exactly 4 digits"));
        }
      },
    );
    transactionBloc.setState(state);
  }

  _onBillingRequest() {
    transactionBloc.setState(
      TransactionState(
          state: State.avsSecure,
          callback: (map) {
            payload.authorization!
              ..mode = SuggestedAuth.AVS_NOAUTH
              ..address = map["address"]
              ..city = map["city"]
              ..zipcode = map["zip"]
              ..country = map["counntry"]
              ..state = map["state"];
            _handlePinOrBillingInput();
          }),
    );
  }

  _onNoAuthUsed() => reQueryTransaction();

  _onAVSVBVSecureCodeModelUsed(String url) => showWebAuthorization(url);

  _handlePinOrBillingInput() async {
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.charge(payload);
      setConnectionState(ConnectionState.done);
      flwRef = response.flwRef;

      if (response.hasData) {
        var chargeResponseStatus = response.chargeResponseStatus?.toUpperCase();
        var responseCode = response.chargeResponseCode;
        transactionId = response.id;
        if (responseCode == "00" || chargeResponseStatus == "SUCCESSFUL") {
          reQueryTransaction();
        } else if (responseCode == "02" ||
            isTxPending(response.message, chargeResponseStatus)) {
          var suggestedAuth = payload.version == Version.v2
              ? response.authModel?.toUpperCase()
              : response.meta.authorization?.mode.toUpperCase();
          if (suggestedAuth == SuggestedAuth.PIN ||
              suggestedAuth == SuggestedAuth.OTP) {
            onOtpRequested(response.chargeResponseMessage);
          } else if (suggestedAuth == SuggestedAuth.AVS_NOAUTH ||
              suggestedAuth == SuggestedAuth.NO_AUTH ||
              suggestedAuth == SuggestedAuth.AVS_VBVSECURECODE ||
              suggestedAuth == SuggestedAuth.REDIRECT) {
            _onAVSVBVSecureCodeModelUsed(payload.version == Version.v2
                ? response.authUrl
                : response.meta.authorization!.redirect);
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
