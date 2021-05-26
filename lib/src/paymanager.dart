import 'package:flutter/material.dart' hide ConnectionState, State;
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
    //fetch the APIs keys initially defined
    initializer.publicKey = NRavePayRepository.instance.initializer.publicKey;
    initializer.encryptionKey =
        NRavePayRepository.instance.initializer.encryptionKey;
    initializer.secKey = NRavePayRepository.instance.initializer.secKey;
    initializer.staging = NRavePayRepository.instance.initializer.staging;
    // Validate the initializer params
    var error = ValidatorUtils.validateInitializer(initializer);
    print(error);
    if (error != null) {
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

      txRef = response.txRef;
      transactionId = response.id;

      var suggestedAuth = response.meta.authorization?.mode.toUpperCase();
      var message = response.message;
      var chargeResponseStatus = response.chargeResponseStatus?.toUpperCase();

      if (message == 'Charge authorization data required' ||
          message == 'Charge initiated' ||
          chargeResponseStatus == 'PENDING') {
        if (suggestedAuth == SuggestedAuth.PIN) {
          _onPinRequested();
          return;
        }

        if (suggestedAuth == SuggestedAuth.OTP) {
          onOtpRequested(response.chargeResponseMessage);
          return;
        }
        if (suggestedAuth == SuggestedAuth.AVS_NOAUTH) {
          _onBillingRequest();
          return;
        }

        if (suggestedAuth == SuggestedAuth.REDIRECT) {
          showWebAuthorization(response.meta.authorization!.redirect);
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
      txRef = response.txRef;

      if (response.hasData) {
        var chargeResponseStatus = response.chargeResponseStatus?.toUpperCase();
        transactionId = response.id;
        if (chargeResponseStatus == "SUCCESSFUL") {
          reQueryTransaction();
        } else if (chargeResponseStatus == "PENDING") {
          var suggestedAuth = response.meta.authorization?.mode.toUpperCase();
          if (suggestedAuth == SuggestedAuth.OTP) {
            onOtpRequested(response.chargeResponseMessage);
          } else if (suggestedAuth == SuggestedAuth.AVS_NOAUTH ||
              suggestedAuth == SuggestedAuth.REDIRECT) {
            _onAVSVBVSecureCodeModelUsed(response.meta.authorization!.redirect);
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
