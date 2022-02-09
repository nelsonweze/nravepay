import 'package:flutter/material.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import 'package:nravepay/src/utils/utils.dart';

class AccountTransactionManager extends BaseTransactionManager {
  AccountTransactionManager({
    required NavigatorState navigatorState,
  }) : super(navigatorState: navigatorState);

  @override
  Future<void> charge() async {
    setConnectionState(LoadingState.active);
    try {
      var response = await service.charge(payload);
      setConnectionState(LoadingState.done);

      flwRef = response.flwRef;

      if (response.hasData) {
        final authUrl = response.authUrl;
        final authUrlIsValid = ValidatorUtils.isUrlValid(authUrl ?? '');
        if (authUrlIsValid) {
          await showWebAuthorization(authUrl ?? '');
        } else {
          var instruction = response.validateInstruction ??
              response.meta?.authorization?.validateInstructions;
          onOtpRequested(instruction);
        }
      } else {
        handleError(
            e: NRavePayException(data: Setup.instance.strings.noResponseData));
      }
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }
}
