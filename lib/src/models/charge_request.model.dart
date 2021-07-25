import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nravepay/nravepay.dart';

class ChargeRequestBody extends Equatable {
  final String? pBFPubKey;
  final String? client;
  final String? alg;

  ChargeRequestBody({
    this.pBFPubKey,
    this.client,
    this.alg,
  });

  ChargeRequestBody.fromPayload({
    required Payload payload,
  })  : pBFPubKey = payload.pbfPubKey,
        alg = '3DES-24',
        client = getEncryptedData(
            json.encode(payload.toMap()), Setup.instance.encryptionKey);

  Map<String, dynamic> toJson() => {
        'PBFPubKey': pBFPubKey,
        'client': client,
        'alg': alg,
      };

  @override
  List<Object?> get props => [pBFPubKey, client, alg];
}

class ValidateChargeRequestBody {
  final String transactionReference;
  final String pBFPubKey;
  final String otp;

  ValidateChargeRequestBody(
      {required this.transactionReference,
      required this.pBFPubKey,
      required this.otp});

  Map<String, dynamic> toJson() => {
        'transaction_reference': transactionReference,
        'PBFPubKey': pBFPubKey,
        'otp': otp,
      };
}
