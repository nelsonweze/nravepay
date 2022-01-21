import 'package:flutter/material.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import '../../nravepay.dart';

abstract class BaseTransactionManager {
  final TransactionService service = TransactionService();
  final NavigatorState navigatorState;
  final PayInitializer initializer = NRavePayRepository.instance.initializer;
  late Payload payload;
  String flwRef = '';
  late int transactionId;
  bool saveCard = true;
  HttpResult? paymentResult;

  BaseTransactionManager({required this.navigatorState});

  Future<void> processTransaction(Payload payload) async {
    this.payload = payload;
    return charge();
  }

  Future<void> charge();

  void reQueryTransaction({ValueChanged<ReQueryResponse>? onComplete}) async {
    onComplete ??= this.onComplete;
    setConnectionState(LoadingState.active);
    try {
      var response = await service.reQuery(
          transactionId,
          payload.version == Version.v2
              ? {
                  'txref': payload.txRef,
                  'SECKEY': payload.secKey,
                }
              : null);
      onComplete(response);
      TransactionBloc.instance.add(UpdateState(state: TransactionState()));
      navigatorState.pop();
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  void onOtpRequested(String? message) {
    TransactionBloc.instance.add(UpdateState(
        state: TransactionState(
            auth: AuthMode.otp,
            data: message ?? Setup.instance.strings.enterOtp,
            callback: (otp) {
              _validateCharge(otp);
            })));
  }

  Future<void> showWebAuthorization(String url) async {
    await navigatorState.push(
      MaterialPageRoute(
          builder: (_) => WebViewWidget(
                authUrl: cleanUrl(url),
                callbackUrl: cleanUrl(payload.redirectUrl),
              ),
          fullscreenDialog: true),
    );
    reQueryTransaction();
  }

  Future<void> _validateCharge(otp) async {
    try {
      setConnectionState(LoadingState.active);
      var response = await service.validateCardCharge(
          ValidateChargeRequestBody(
              transactionReference: flwRef,
              otp: otp,
              pBFPubKey: payload.pbfPubKey),
          payload.version);
      transactionId = response.id;
      setConnectionState(LoadingState.done);
      transactionId = response.id;
      var status = response.status;

      if (status.toLowerCase() == 'success') {
        reQueryTransaction();
      } else {
        initializer.onComplete(HttpResult(
          status: HttpStatus.error,
          message: response.message,
        ));
      }
    } catch (e, s) {
      logger(e, stackTrace: s);
      reQueryTransaction();
    }
  }

  @mustCallSuper
  void handleError({required NRavePayException e, Map? rawResponse}) {
    setConnectionState(LoadingState.done);
    initializer.onComplete(HttpResult(
        status: HttpStatus.error,
        message: e.message,
        rawResponse: rawResponse));
  }

  @mustCallSuper
  void onComplete(ReQueryResponse response) {
    setConnectionState(LoadingState.done);
    logger('completing payment ${response.dataStatus}');
    var result = HttpResult(
      status: response.dataStatus?.toLowerCase() == 'successful'
          ? HttpStatus.success
          : HttpStatus.error,
      rawResponse: response.rawResponse,
      message: response.message,
      card: saveCard ? response.card : null,
    );
    paymentResult = result;
    initializer.onComplete(result);
  }

  void setConnectionState(LoadingState status) =>
      TransactionBloc.instance.add(UpdateLoading(status: status));
}

typedef TransactionComplete = Function(HttpResult result);
