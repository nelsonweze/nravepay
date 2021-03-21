import 'package:flutter/material.dart' hide ConnectionState, State;
import '../models.dart';
import '../payment.dart';
import '../services.dart';

abstract class BaseTransactionManager {
  final TransactionService service = TransactionService();
  final BuildContext context;
  final PayInitializer initializer = NRavePayRepository.instance!.initializer;
  final transactionBloc = TransactionBloc.instance;
  final connectionBloc = ConnectionBloc.instance;
  Payload? payload;
  String? flwRef;
  bool? saveCard = true;
  late Function(bool?, BankCard?, PayInitializer) onPaymentSuccess;
  BaseTransactionManager({
    required this.context,
  });

  processTransaction(Payload? payload) {
    this.payload = payload;
    return charge();
  }

  charge();

  reQueryTransaction({ValueChanged<ReQueryResponse>? onComplete}) async {
    onComplete ??= this.onComplete;
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.reQuery(payload!.txRef, payload!.secKey);
      onComplete(response);
      Navigator.pop(context);
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  onOtpRequested([String? message = Strings.enterOtp]) {
    transactionBloc!.setState(TransactionState(
        state: State.otp,
        data: message,
        callback: (otp) {
          _validateCharge(otp);
        }));
  }

  showWebAuthorization(String? authUrl) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => WebViewWidget(
                authUrl: cleanUrl(authUrl!),
                callbackUrl: cleanUrl(payload!.redirectUrl!),
              ),
          fullscreenDialog: true),
    );
    reQueryTransaction();
  }

  _validateCharge(otp) async {
    try {
      setConnectionState(ConnectionState.waiting);
      var response = await service.validateCardCharge(ValidateChargeRequestBody(
          transactionReference: flwRef,
          otp: otp,
          pBFPubKey: payload!.pbfPubKey));
      setConnectionState(ConnectionState.done);

      var status = response.status;
      if (status == null) {
        reQueryTransaction();
        return;
      }

      if (status.toLowerCase() == "success") {
        reQueryTransaction();
      } else {
        initializer.onTransactionComplete!(HttpResult(
          status: HttpStatus.error,
          message: response.message,
        ));
      }
    } catch (e) {
      reQueryTransaction();
    }
  }

  @mustCallSuper
  handleError({required NRavePayException e, Map? rawResponse}) {
    setConnectionState(ConnectionState.done);
    initializer.onTransactionComplete!(HttpResult(
        status: HttpStatus.error,
        message: e.message,
        rawResponse: rawResponse));
  }

  @mustCallSuper
  onComplete(ReQueryResponse response) {
    setConnectionState(ConnectionState.done);
    // Navigator.of(context).pop();
    initializer.onTransactionComplete!(HttpResult(
        status: response.dataStatus!.toLowerCase() == "successful"
            ? HttpStatus.success
            : HttpStatus.error,
        rawResponse: response.rawResponse,
        message: response.message));
    if (response.dataStatus!.toLowerCase() == "successful") {
      onPaymentSuccess(saveCard, response.card, initializer);
      if (saveCard! && response.status == 'success') {
        //   PaymentService().saveCard(response.card);
        //   AnalyticsCubit().analytics.logAddPaymentInfo();
      }
      // PaymentService().recordTransactions(initializer);
      // AnalyticsCubit().analytics.logEcommercePurchase(
      //       transactionId: initializer.txRef,
      //       currency: initializer.currency,
      //       value: initializer.amount,
      //       origin: initializer.subAccounts.isValid()
      //           ? initializer.subAccounts.first.id
      //           : null,
      //     );
    }
  }

  setConnectionState(ConnectionState state) => connectionBloc!.setState(state);
}

typedef TransactionComplete(HttpResult result);
