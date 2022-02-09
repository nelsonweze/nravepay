import 'package:flutter/material.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import 'package:nravepay/src/utils/utils.dart';

class CardTransactionManager extends BaseTransactionManager {
  CardTransactionManager({required NavigatorState navigatorState})
      : super(navigatorState: navigatorState);

  @override
  Future<void> charge() async {
    setConnectionState(LoadingState.active);
    try {
      var response = await service.charge(payload);
      setConnectionState(LoadingState.done);

      flwRef = response.flwRef;
      transactionId = response.id;
      var isV2 = payload.version == Version.v2;
      var suggestedAuth = isV2
          ? response.suggestedAuth
          : response.meta?.authorization?.mode.toUpperCase();
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
        if ([
          SuggestedAuth.AVS_NOAUTH,
          SuggestedAuth.NO_AUTH,
          SuggestedAuth.AVS_VBVSECURECODE,
          SuggestedAuth.VBV,
        ].contains(suggestedAuth)) {
          _onBillingRequest(suggestedAuth!);
          return;
        }

        if (suggestedAuth == SuggestedAuth.REDIRECT) {
          await showWebAuthorization(response.meta!.authorization!.redirect);
          return;
        }

        if (message == SuggestedAuth.V_COMP) {
          if (response.chargeResponseCode == '02') {
            if (authModel == SuggestedAuth.ACCESS_OTP ||
                authModel == SuggestedAuth.PIN) {
              onOtpRequested(response.chargeResponseMessage);
              return;
            }
            if (authModel == SuggestedAuth.VBV) {
              await showWebAuthorization(response.authUrl ?? '');
              return;
            }
          }
          if (response.chargeResponseCode == '00') {
            _onNoAuthUsed();
            return;
          }
        }
        if (authModel == SuggestedAuth.GTB_OTP ||
            authModel == SuggestedAuth.ACCESS_OTP ||
            (authModel != null && authModel.contains('OTP'))) {
          onOtpRequested(response.chargeResponseMessage);
          return;
        }
      }
      _onNoAuthUsed();
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  void _onPinRequested() {
    var state = TransactionState(
      auth: AuthMode.pin,
      callback: (pin) {
        if (pin != null && pin.length == 4) {
          payload.authorization!
            ..pin = pin
            ..mode = SuggestedAuth.PIN;
          _handlePinOrBillingInput();
        } else {
          handleError(
              e: NRavePayException(data: Setup.instance.strings.invalidPIN));
        }
      },
    );
    TransactionBloc.instance.add(UpdateState(state: state));
  }

  void _onBillingRequest(String mode) {
    TransactionBloc.instance.add(UpdateState(
      state: TransactionState(
          auth: AuthMode.avsSecure,
          callback: (map) {
            payload.authorization!
              ..mode = SuggestedAuth.AVS_NOAUTH
              ..address = map['address']
              ..city = map['city']
              ..zipcode = map['zip']
              ..country = map['counntry']
              ..state = map['state'];
            _handlePinOrBillingInput();
          }),
    ));
  }

  dynamic _onNoAuthUsed() => reQueryTransaction();

  dynamic _onAVSVBVSecureCodeModelUsed(String url) => showWebAuthorization(url);

  Future<void> _handlePinOrBillingInput() async {
    setConnectionState(LoadingState.active);
    try {
      var response = await service.charge(payload);
      setConnectionState(LoadingState.done);
      flwRef = response.flwRef;

      if (response.hasData) {
        var chargeResponseStatus = response.chargeResponseStatus?.toUpperCase();
        var responseCode = response.chargeResponseCode;
        transactionId = response.id;
        if (responseCode == '00' || chargeResponseStatus == 'SUCCESSFUL') {
          reQueryTransaction();
        } else if (responseCode == '02' ||
            isTxPending(response.message, chargeResponseStatus)) {
          var suggestedAuth = payload.version == Version.v2
              ? response.authModel?.toUpperCase()
              : response.meta?.authorization?.mode.toUpperCase();
          if (suggestedAuth == SuggestedAuth.PIN ||
              suggestedAuth == SuggestedAuth.OTP) {
            onOtpRequested(response.chargeResponseMessage);
          } else if ([
            SuggestedAuth.AVS_NOAUTH,
            SuggestedAuth.NO_AUTH,
            SuggestedAuth.AVS_VBVSECURECODE,
            SuggestedAuth.VBV,
            SuggestedAuth.REDIRECT
          ].contains(suggestedAuth)) {
            _onAVSVBVSecureCodeModelUsed(payload.version == Version.v2
                ? response.authUrl ?? ''
                : response.meta!.authorization!.redirect);
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
