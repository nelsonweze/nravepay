import 'package:flutter/material.dart' hide ConnectionState, State;
import '../models.dart';
import '../payment.dart';
import '../services.dart';

abstract class BaseTransactionManager {
  final TransactionService service = TransactionService();
  final BuildContext context;
  final PayInitializer initializer = NRavePayRepository.instance.initializer;
  final transactionBloc = TransactionBloc.instance;
  final connectionBloc = ConnectionBloc.instance;
  late Payload payload;
  late String txRef;
  late int transactionId;
  bool saveCard = true;
  HttpResult? paymentResult;

  BaseTransactionManager({
    required this.context,
  });

  Future<void> processTransaction(Payload payload) async {
    this.payload = payload;
    return charge();
  }

  Future<void> charge();

  reQueryTransaction({ValueChanged<ReQueryResponse>? onComplete}) async {
    onComplete ??= this.onComplete;
    setConnectionState(ConnectionState.waiting);
    try {
      var response = await service.reQuery(transactionId);
      onComplete(response);
      Navigator.pop(context);
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  onOtpRequested([String? message = Strings.enterOtp]) {
    transactionBloc.setState(TransactionState(
        state: State.otp,
        data: message,
        callback: (otp) {
          _validateCharge(otp);
        }));
  }

  showWebAuthorization(String url) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => WebViewWidget(
                authUrl: cleanUrl(url),
                callbackUrl: cleanUrl(payload.redirectUrl!),
              ),
          fullscreenDialog: true),
    );
    reQueryTransaction();
  }

  _validateCharge(otp) async {
    try {
      setConnectionState(ConnectionState.waiting);
      var response = await service.validateCardCharge(ValidateChargeRequestBody(
          transactionReference: txRef,
          otp: otp,
          pBFPubKey: payload.pbfPubKey!));
      transactionId = response.id;
      setConnectionState(ConnectionState.done);
      transactionId = response.id;
      var status = response.status;

      if (status.toLowerCase() == "success") {
        reQueryTransaction();
      } else {
        initializer.onComplete(HttpResult(
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
    initializer.onComplete(HttpResult(
        status: HttpStatus.error,
        message: e.message,
        rawResponse: rawResponse));
  }

  @mustCallSuper
  onComplete(ReQueryResponse response) {
    setConnectionState(ConnectionState.done);
    print('completing payment');
    var result = HttpResult(
      status: response.dataStatus!.toLowerCase() == "successful"
          ? HttpStatus.success
          : HttpStatus.error,
      rawResponse: response.rawResponse,
      message: response.message,
      card: saveCard ? response.card : null,
    );
    paymentResult = result;
    initializer.onComplete(result);
  }

  setConnectionState(ConnectionState state) => connectionBloc.setState(state);
}

typedef TransactionComplete(HttpResult result);
