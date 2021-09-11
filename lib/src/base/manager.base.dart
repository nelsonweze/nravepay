import 'package:flutter/material.dart' hide ConnectionState, State;
import 'package:nravepay/src/blocs/blocs.dart';
import '../../nravepay.dart';
import '../models/models.dart';
import '../services/services.dart';

abstract class BaseTransactionManager {
  final TransactionService service = TransactionService();
  final BuildContext context;
  final PayInitializer initializer = NRavePayRepository.instance.initializer;
  final transactionBloc = TransactionBloc.instance;
  final connectionBloc = ConnectionBloc.instance;
  late Payload payload;
  String flwRef = '';
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

  void reQueryTransaction({ValueChanged<ReQueryResponse>? onComplete}) async {
    onComplete ??= this.onComplete;
    setConnectionState(ConnectionState.waiting);
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
      Navigator.pop(context);
    } on NRavePayException catch (e) {
      handleError(e: e);
    }
  }

  void onOtpRequested(String? message) {
    transactionBloc.setState(TransactionState(
        state: State.otp,
        data: message ?? Setup.instance.strings.enterOtp,
        callback: (otp) {
          _validateCharge(otp);
        }));
  }

  Future<void> showWebAuthorization(String url) async {
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

  Future<void> _validateCharge(otp) async {
    try {
      setConnectionState(ConnectionState.waiting);
      var response = await service.validateCardCharge(
          ValidateChargeRequestBody(
              transactionReference: flwRef,
              otp: otp,
              pBFPubKey: payload.pbfPubKey),
          payload.version);
      transactionId = response.id;
      setConnectionState(ConnectionState.done);
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
    } catch (e) {
      print(e);
      reQueryTransaction();
    }
  }

  @mustCallSuper
  void handleError({required NRavePayException e, Map? rawResponse}) {
    setConnectionState(ConnectionState.done);
    initializer.onComplete(HttpResult(
        status: HttpStatus.error,
        message: e.message,
        rawResponse: rawResponse));
  }

  @mustCallSuper
  void onComplete(ReQueryResponse response) {
    setConnectionState(ConnectionState.done);
    print('completing payment ${response.dataStatus}');
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

  void setConnectionState(ConnectionState state) =>
      connectionBloc.setState(state);
}

typedef TransactionComplete = Function(HttpResult result);
