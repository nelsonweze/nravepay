import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:nwidgets/nwidgets.dart';
import '../payment.dart';

class ChargeRequestBody extends Equatable {
  final String? pBFPubKey;
  final String? client;
  final String? alg;

  ChargeRequestBody({
    this.pBFPubKey,
    this.client,
    this.alg,
  });

  ChargeRequestBody.fromPayload({required Payload payload, String? type})
      : this.pBFPubKey = payload.pbfPubKey,
        this.alg = "3DES-24",
        this.client = getEncryptedData(json.encode(payload.toJson(type)),
            NRavePayRepository.instance!.initializer.encryptionKey);

  Map<String, dynamic> toJson() => {
        "PBFPubKey": pBFPubKey,
        "client": client,
        "alg": alg,
      };

  @override
  List<Object?> get props => [pBFPubKey, client, alg];
}

class ChargeWithTokenBody extends Equatable {
  final String? secret;
  final String? token;
  final String? currency;
  final String? country;
  final String? amount;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? ip;
  final String? txRef;
  final String? paymentPlan;
  final List<SubAccount> subAccounts;
  final Map<String, String>? meta;
  final String? narration;

  ChargeWithTokenBody(
      {this.secret,
      this.token,
      this.currency,
      this.country,
      this.amount,
      this.email,
      this.firstname,
      this.lastname,
      this.ip,
      this.txRef,
      this.paymentPlan,
      this.subAccounts = const [],
      this.narration,
      this.meta});

  ChargeWithTokenBody.fromPayload({required Payload payload})
      : this.secret = payload.secKey,
        this.token = payload.token,
        this.country = payload.country,
        this.currency = payload.currency,
        this.email = payload.email,
        this.amount = payload.amount,
        this.firstname = payload.firstName,
        this.lastname = payload.lastName,
        this.ip = payload.ip,
        this.txRef = payload.txRef,
        this.paymentPlan = payload.paymentPlan,
        this.meta = payload.meta,
        this.narration = payload.narration,
        this.subAccounts = payload.subAccounts;

  Map<String, dynamic> toJson() => {
        "SECKEY": secret,
        "token": token,
        "currency": currency,
        "country": country,
        "amount": amount,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
        "ip": ip,
        "narration": narration,
        "txRef": txRef,
        "meta": meta,
        "payment_plan": paymentPlan,
        "subaccounts": subAccounts.isNotEmpty
            ? subAccounts.map((e) => e.toString()).toList()
            : null,
      };

  @override
  List<Object?> get props => [
        secret,
        token,
        currency,
        country,
        amount,
        email,
        txRef,
        paymentPlan,
        subAccounts
      ];
}
