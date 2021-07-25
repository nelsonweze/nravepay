import 'package:nravepay/nravepay.dart';

import 'models.dart';

class Payload {
  double amount;
  String currency;
  String cardNumber;
  String cvv;
  String expiryMonth;
  String expiryYear;
  String email;
  String txRef;
  String? phoneNumber;
  String firstname;
  String lastname;
  bool preauthorize;
  String? redirectUrl;
  String? clientIp;
  String? deviceFingerprint;
  Meta? meta;
  Authorization? authorization;
  String? token;
  String? country;
  String? narration;
  String? paymentPlan;
  String? paymentType;
  List<SubAccount> subaccounts;

  String get pbfPubKey => Setup.instance.publicKey;
  String get secKey => Setup.instance.secKey;
  Version get version => Setup.instance.version;

  Payload({
    required this.amount,
    required this.currency,
    required this.cardNumber,
    required this.cvv,
    required this.expiryMonth,
    required this.expiryYear,
    required this.email,
    required this.txRef,
    this.token,
    this.phoneNumber,
    required this.firstname,
    required this.lastname,
    this.country,
    this.preauthorize = false,
    this.redirectUrl = 'https://payment-status-page.firebaseapp.com/',
    this.clientIp,
    this.deviceFingerprint,
    this.meta,
    this.narration,
    this.authorization,
    this.paymentPlan,
    this.paymentType,
    this.subaccounts = const [],
  });

  Payload.fromInitializer(PayInitializer i)
      : amount = i.amount,
        currency = i.currency,
        country = i.country,
        email = i.email,
        firstname = i.firstname,
        lastname = i.lastname,
        txRef = i.txRef,
        meta = i.meta,
        subaccounts = i.subAccounts ?? [],
        redirectUrl = i.redirectUrl,
        token = i.token,
        expiryYear = '',
        cvv = '',
        preauthorize = i.preauthorize,
        authorization = Authorization(mode: ''),
        cardNumber = '',
        expiryMonth = '',
        paymentType = i.paymentType,
        paymentPlan = i.paymentPlan ?? '';

  Map<String, dynamic> withToken() {
    return {
      'token': token,
      'email': email,
      'currency': currency,
      'country': country,
      'amount': amount,
      'tx_ref': txRef,
      'txRef': txRef,
      'ip': clientIp,
      'narration': narration,
      'device_fingerprint': deviceFingerprint,
      'payment_plan': paymentPlan,
      'subaccounts': subaccounts.isEmpty
          ? null
          : subaccounts.map((a) => a.toMap()).toList(),
      'preauthorize': preauthorize,
      'SECKEY': secKey
    };
  }

  Map<String, dynamic> toMap() {
    if (version == Version.v2) {
      return {
        'PBFPubKey': pbfPubKey,
        'cardno': cardNumber,
        'cvv': cvv,
        'expirymonth': expiryMonth,
        'expiryyear': expiryYear,
        'currency': currency,
        'country': country,
        'amount': amount,
        'email': email,
        'phonenumber': phoneNumber,
        'firstname': firstname,
        'lastname': lastname,
        'subaccounts': subaccounts.isNotEmpty
            ? subaccounts.map((e) => e.toMap()).toList()
            : [],
        'txRef': txRef,
        'meta': meta?.toMap(),
        'payment_type': paymentType,
        'paymentPlan': paymentPlan,
        'redirect_url': redirectUrl,
        'device_fingerprint': deviceFingerprint,
        ...?authorization?.toMap(version)
      };
    }
    return {
      'amount': amount,
      'currency': currency,
      'card_number': cardNumber,
      'cvv': cvv,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'email': email,
      'tx_ref': txRef,
      'phone_number': phoneNumber,
      'fullname': '$firstname $lastname',
      'preauthorize': preauthorize,
      'paymentType': paymentType,
      'paymentPlan': paymentPlan,
      'redirect_url': redirectUrl,
      'client_ip': clientIp,
      'device_fingerprint': deviceFingerprint,
      'meta': meta?.toMap(),
      'subaccounts': subaccounts.isNotEmpty
          ? subaccounts.map((e) => e.toMap()).toList()
          : [],
      'authorization': authorization?.toMap(version)
    };
  }
}