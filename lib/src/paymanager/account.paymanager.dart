import 'package:flutter/material.dart' hide ConnectionState, State;
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/blocs.dart';
import 'package:nravepay/src/utils/utils.dart';

class AccountTransactionManager extends BaseTransactionManager {
  AccountTransactionManager({
    required BuildContext context,
  }) : super(
          context: context,
        );

  @override
  Future<void> charge() async {
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.charge(payload);
      setConnectionState(ConnectionState.done);

      flwRef = response.flwRef;

      if (response.hasData) {
        final authUrl = response.authUrl;
        final authUrlIsValid = ValidatorUtils.isUrlValid(authUrl);
        if (authUrlIsValid) {
          await showWebAuthorization(authUrl);
        } else {
          var instruction = response.validateInstruction ??
              response.meta.authorization?.validateInstructions;
          onOtpRequested(instruction);
        }
      } else {
        handleError(e: NRavePayException(data: Strings.noResponseData));
      }
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }
}
