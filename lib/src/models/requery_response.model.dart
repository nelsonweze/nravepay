import 'package:equatable/equatable.dart';
import 'models.dart';

class ReQueryResponse extends Equatable {
  final String? status;
  final String? dataStatus;
  final Map? rawResponse;
  final String? message;
  final String? txRef;
  final String? chargedAmount;
  final bool? hasData;
  final BankCard? card;
  final String? narration;
  final String? transactionId;

  ReQueryResponse(
      {this.status,
      this.txRef,
      this.dataStatus,
      this.rawResponse,
      this.message,
      this.hasData,
      this.card,
      this.narration,
      this.chargedAmount,
      this.transactionId});

  factory ReQueryResponse.fromJson(Map<String, dynamic> json, bool isV2) {
    Map<String, dynamic> data = json['data'] ?? {};
    var message = data['vbvrespmessage']?.toString();
    if (message == null || message.toUpperCase() == 'N/A') {
      message = data['chargeResponseMessage'];
    }
    return ReQueryResponse(
        status: json['status'],
        dataStatus: data['status'],
        message: isV2 ? message : data['message'],
        txRef: isV2 ? data['txref'] : data['tx_ref'],
        hasData: data.isNotEmpty,
        rawResponse: json,
        card:
            data['card'] != null ? BankCard.fromMap(data['card'], isV2) : null,
        chargedAmount: isV2
            ? data['chargedamount'].toString()
            : data['charged_amount'].toString(),
        narration: data['narration'],
        transactionId: isV2 ? data['txid'].toString() : data['id'].toString());
  }

  @override
  List<Object?> get props => [status, dataStatus, card];
}
