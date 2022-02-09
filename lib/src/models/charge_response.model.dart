import 'package:equatable/equatable.dart';
import 'package:nravepay/nravepay.dart';

class ChargeResponse extends Equatable {
  final int id;
  final String status;
  final String message;
  final String? authModel;
  final String? chargeResponseStatus;
  final String? chargeResponseCode;
  final String? flwRef;
  final String? txRef;
  final String? orderRef;
  final String? chargeResponseMessage;
  final String? authUrl;
  final String? appFee;
  final String? currency;
  final String? chargedAmount;
  final bool hasData;
  final Map? rawResponse;
  final BankCard? card;
  final Meta? meta;
  final String? suggestedAuth;
  final String? validateInstruction;

  ChargeResponse(
      {required this.status,
      required this.message,
      required this.hasData,
      this.id = 0,
      this.authModel,
      this.chargeResponseStatus,
      this.flwRef = '',
      this.txRef = '',
      this.chargeResponseMessage,
      this.authUrl,
      this.appFee,
      this.currency,
      this.chargedAmount,
      this.rawResponse,
      this.card,
      this.meta,
      this.orderRef,
      this.suggestedAuth,
      this.chargeResponseCode,
      this.validateInstruction});

  factory ChargeResponse.fromJson(Map<String, dynamic> json, Version version) {
    Map<String, dynamic> data = json['data'] ?? {};
    var isV2 = version == Version.v2;

    return ChargeResponse(
        status: json['status'],
        message: json['message'],
        hasData: data.isNotEmpty,
        id: data['id'] ?? 0,
        authModel: isV2 ? data['authModelUsed'] : data['auth_model'],
        chargeResponseStatus: data['status'],
        flwRef: isV2 ? data['flwRef'] : data['flw_ref'],
        txRef: isV2 ? data['txRef'] : data['tx_ref'],
        orderRef: isV2 ? data['orderRef'] : data['order_ref'],
        chargeResponseMessage:
            isV2 ? data['chargeResponseMessage'] : data['processor_response'],
        chargeResponseCode: data['chargeResponseCode'],
        suggestedAuth: data['suggested_auth'],
        authUrl: isV2 ? data['authurl'] : data['auth_url'],
        appFee: isV2 ? data['appfee'].toString() : data['app_fee'].toString(),
        currency: data['currency'],
        chargedAmount: data['charged_amount'].toString(),
        meta: json['meta'] != null ? Meta.fromMap(json['meta']) : Meta(),
        card: data['card'] != null
            ? BankCard.fromMap(data['card'], version == Version.v2)
            : null,
        validateInstruction: data['validateInstructions']?['instruction'],
        rawResponse: json);
  }

  Map<String, dynamic> toJson() => rawResponse as Map<String, dynamic>;

  @override
  List<Object?> get props => [
        status,
        message,
        chargeResponseStatus,
        flwRef,
        chargeResponseMessage,
        authUrl,
        appFee,
        currency,
        chargedAmount,
        hasData,
        card,
        suggestedAuth
      ];
}
