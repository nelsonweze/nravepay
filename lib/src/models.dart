import 'dart:convert';

import 'payment.dart';
import 'package:equatable/equatable.dart';
import 'util.payment.dart';

enum Version { v2, v3 }

class PayInitializer {
  /// Your customer email. Must be provided otherwise your customer will be promted to input it
  String email;

  /// The amount to be charged in the supplied [currency]. Must be a valid non=null and
  /// positive double. Otherwise, the customer will be asked to input an
  /// amount (this is especially useful for donations).
  double amount;

  /// Rave's merchant account public key.
  String publicKey;

  /// Rave's merchant encryption key
  String encryptionKey;

  /// Rave's secret encryption key
  String secKey;

  /// Transaction reference. It cannot be null or empty
  String txRef;

  /// Custom description added by the merchant.
  String narration;

  /// An ISO 4217 currency code (e.g USD, NGN). I cannot be empty or null. Defaults to NGN
  String currency;

  /// ISO 3166-1 alpha-2 country code (e.g US, NG). Defaults to NG
  String country;

  /// Your customer's full name.
  String firstname;

  String lastname;

  /// Your custom data in key-value pairs
  Meta? meta;

  /// As list of sub-accounts. Sub accounts are your vendor's accounts that you
  /// want to settle per transaction.
  /// See https://developer.flutterwave.com/docs/split-payment
  List<SubAccount>? subAccounts;

  /// plan id for recurrent payments. Only available for card payment.
  /// More info:
  ///
  /// https://developer.flutterwave.com/reference#create-payment-plan
  ///
  /// https://developer.flutterwave.com/docs/recurring-billing
  String? paymentPlan;

  /// Whether to route the payment to Sandbox APIs.
  bool staging;

  /// URL to redirect to when a transaction is completed. This is useful for 3DSecure payments so we can redirect your customer back to a custom page you want to show them.
  String redirectUrl;

  /// The text that is displayed on the pay button. Defaults to "Pay [currency][amount]"
  String? payButtonText;
  String? token;
  bool useCard;
  String? phoneNumber;
  Version? version;
  bool preauthorize;
  
  Function(HttpResult) onComplete;

  /// The type of transaction used to sort payments in firestore
  String? paymentType;

  PayInitializer({
    required this.amount,
    required this.email,
    required this.txRef,
    required this.onComplete,
    this.version = Version.v2,
    this.publicKey = '',
    this.encryptionKey = '',
    this.secKey = '',
    this.currency = Strings.ngn,
    this.country = Strings.ng,
    this.narration = '',
    this.firstname = '',
    this.lastname = '',
    this.meta,
    this.subAccounts,
    this.token,
    this.useCard = false,
    this.preauthorize = false,
    bool? staging,
    this.paymentPlan,
    this.paymentType,
    this.redirectUrl = "https://payment-status-page.firebaseapp.com/",
    this.payButtonText,
    this.phoneNumber,
  }) : this.staging = Env.test;

  PayInitializer copyWith({final String? token}) {
    return PayInitializer(
        token: token ?? this.token,
        amount: this.amount,
        publicKey: this.publicKey,
        encryptionKey: this.encryptionKey,
        secKey: this.secKey,
        country: this.country,
        currency: this.currency,
        narration: this.narration,
        firstname: this.firstname,
        lastname: this.lastname,
        meta: this.meta,
        paymentType: this.paymentType,
        staging: this.staging,
        subAccounts: this.subAccounts,
        email: this.email,
        txRef: this.txRef,
        useCard: this.useCard,
        paymentPlan: this.paymentPlan,
        redirectUrl: this.redirectUrl,
        payButtonText: this.payButtonText,
        preauthorize: this.preauthorize,
        onComplete: this.onComplete);
  }
}

class SubAccount {
  final String id;

  SubAccount(this.id);

  Map<String, String> toMap() {
    return {'id': id};
  }
}

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
  String? pbfPubKey;
  String? secKey;

  Payload(
      {required this.amount,
      required this.currency,
      required this.cardNumber,
      required this.cvv,
      required this.expiryMonth,
      required this.expiryYear,
      required this.email,
      required this.txRef,
      this.pbfPubKey,
      this.token,
      this.phoneNumber,
      required this.firstname,
      required this.lastname,
      this.country,
      this.preauthorize = false,
      this.redirectUrl = "https://payment-status-page.firebaseapp.com/",
      this.clientIp,
      this.deviceFingerprint,
      this.meta,
      this.narration,
      this.authorization,
      this.paymentPlan,
      this.paymentType,
      this.subaccounts = const []});

  Payload.fromInitializer(PayInitializer i)
      : this.amount = i.amount,
        this.currency = i.currency,
        this.country = i.country,
        this.email = i.email,
        this.firstname = i.firstname,
        this.lastname = i.lastname,
        this.txRef = i.txRef,
        this.meta = i.meta,
        this.subaccounts = i.subAccounts ?? [],
        this.redirectUrl = i.redirectUrl,
        this.pbfPubKey = i.publicKey,
        this.secKey = i.secKey,
        this.token = i.token,
        this.expiryYear = '',
        this.cvv = '',
        this.preauthorize = i.preauthorize,
        this.authorization = Authorization(
          mode: '',
        ),
        cardNumber = '',
        expiryMonth = '',
        this.paymentPlan = i.paymentPlan ?? '';

  withToken() {
    return {
      "token": token,
      "email": email,
      "currency": currency,
      "country": country,
      "amount": amount,
      "tx_ref": txRef,
      "first_name": firstname,
      "last_name": lastname,
      "ip": clientIp,
      "narration": narration,
      "device_fingerprint": deviceFingerprint,
      "payment_plan": paymentPlan,
      "subaccounts": subaccounts.isEmpty
          ? null
          : subaccounts.map((a) => a.toMap()).toList(),
      "preauthorize": preauthorize
    };
  }

  toMap() {
    return {
      "amount": amount,
      "currency": currency,
      "card_number": cardNumber,
      "cvv": cvv,
      "expiry_month": expiryMonth,
      "expiry_year": expiryYear,
      "email": email,
      "tx_ref": txRef,
      "phone_number": phoneNumber,
      "fullname": '$firstname $lastname',
      "preauthorize": preauthorize,
      "redirect_url": redirectUrl,
      "client_ip": clientIp,
      "device_fingerprint": deviceFingerprint,
      "meta": meta?.toMap(),
      "authorization": authorization?.toMap()
    };
  }
}

class Meta {
  String? flightID;
  String? sideNote;
  Authorization? authorization;

  Meta({this.flightID, this.sideNote, this.authorization});
  Meta.fromMap(Map data)
      : flightID = data['flightID'],
        sideNote = data['sideNote'],
        authorization = Authorization.fromMap(data['authorization']);
  toMap() {
    return {
      "sideNote": sideNote,
      "flightID": flightID,
    };
  }
}

class Authorization {
  String mode;
  String? pin;
  String? city;
  String? address;
  String? state;
  String? country;
  String? zipcode;
  String? endpoint;
  String redirect;
  List<String>? fields;

  Authorization(
      {required this.mode,
      this.pin,
      this.city,
      this.address,
      this.state,
      this.country,
      this.endpoint,
      this.zipcode,
      this.fields,
      this.redirect = ''});

  Authorization.fromMap(Map map)
      : mode = map["mode"],
        redirect = map["redirect"],
        fields = List.castFrom<dynamic, String>(map["fields"]);

  toMap() {
    return {
      'mode': mode.toLowerCase(),
      'pin': pin,
      'city': city,
      'address': address,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'endpoint': endpoint,
    };
  }
}

class HttpResult extends Equatable {
  /// The status of the transaction. Whether
  ///
  /// [HttpStatus.success] for when the transaction completes successfully,
  ///
  /// [HttpStatus.error] for when the transaction completes with an error,
  ///
  /// [HttpStatus.cancelled] for when the user cancelled
  final HttpStatus status;

  /// Raw response from Http. Can be null
  final Map? rawResponse;

  /// Human readable message
  final String? message;

  /// BankCard object returned if save card is set to [true]
  final BankCard? card;

  HttpResult({required this.status, this.rawResponse, this.message, this.card});

  @override
  String toString() {
    return 'HttpResult{status: $status, rawResponse: $rawResponse, message: $message}';
  }

  @override
  List<Object?> get props => [status, rawResponse, message, card];
}

enum HttpStatus { success, error, cancelled, left }

class Bank {
  final String name;
  final String code;
  final bool internetBanking;

  Bank.fromJson(Map map)
      : this.name = map['bankname'],
        this.code = map['bankcode'],
        this.internetBanking = map['internetbanking'];

  bool showBVNField() =>
      code == '033'; // 033 is code for UNITED BANK FOR AFRICA PLC

  bool showDOBField() =>
      code == '057' || code == '033'; // 057 is for ZENITH BANK PLC

  bool showAccountNumField() => !internetBanking;
}

class BankCard {
  String? id;
  String? token;
  String? last4digits;
  String? expirymonth;
  String? expiryyear;
  String? cardBIN;
  String? brand;
  String? type;

  BankCard(
      {this.brand,
      this.cardBIN,
      this.token,
      this.expirymonth,
      this.expiryyear,
      this.last4digits,
      this.id,
      this.type});

  BankCard.fromMap(Map map)
      : id = map["id"],
        token = map["token"],
        last4digits = map["last4digits"],
        expirymonth = map["expirymonth"],
        expiryyear = map["expiryyear"],
        cardBIN = map["cardBIN"],
        type = map["type"],
        brand = map["brand"];

  toMap() {
    return {
      "id": id,
      "token": token,
      "last4digits": last4digits,
      "expirymonth": expirymonth,
      "expiryyear": expiryyear,
      "cardBIN": cardBIN,
      "brand": brand,
      "type": type
    };
  }
}

class ChargeResponse extends Equatable {
  final int id;
  final String status;
  final String message;
  final String? authModel;
  final String? chargeResponseStatus;
  final String flwRef;
  final String txRef;
  final String? chargeResponseMessage;
  final String authUrl;
  final String appFee;
  final String currency;
  final String chargedAmount;
  final bool hasData;
  final Map rawResponse;
  final BankCard? card;
  final Meta meta;

  ChargeResponse(
      {required this.status,
      required this.message,
      required this.authModel,
      required this.chargeResponseStatus,
      required this.flwRef,
      required this.txRef,
      required this.chargeResponseMessage,
      required this.authUrl,
      required this.appFee,
      required this.currency,
      required this.chargedAmount,
      required this.hasData,
      required this.rawResponse,
      required this.card,
      required this.meta,
      required this.id});

  factory ChargeResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json["data"] ?? {};
    return ChargeResponse(
        status: json["status"],
        message: json["message"],
        hasData: data.isNotEmpty,
        id: data["id"],
        authModel: data["auth_model"],
        chargeResponseStatus: data["status"],
        flwRef: data["flw_ref"],
        txRef: data["tx_ref"],
        chargeResponseMessage: data["processor_response"],
        authUrl: data["auth_url"],
        appFee: data["app_fee"].toString(),
        currency: data["currency"],
        chargedAmount: data["charged_amount"].toString(),
        meta: json['meta'] != null ? Meta.fromMap(json['meta']) : Meta(),
        card: data['card'] != null ? BankCard.fromMap(data['card']) : null,
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
      ];
}

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
  })   : this.pBFPubKey = payload.pbfPubKey,
        this.alg = "3DES-24",
        this.client = getEncryptedData(json.encode(payload.toMap()),
            NRavePayRepository.instance.initializer.encryptionKey);

  Map<String, dynamic> toJson() => {
        "PBFPubKey": pBFPubKey,
        "client": client,
        "alg": alg,
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
        "transaction_reference": transactionReference,
        "PBFPubKey": pBFPubKey,
        "otp": otp,
      };
}

class Merchant {
  String accountBank;
  String accountNumber;
  String businessName;
  String? businessEmail;
  String? businessContact;
  String businessMobile;
  String country;
  String? merchantId;
  String splitType;
  String splitValue;
  String? secretKey;
  List<Map<String, dynamic>>? meta;

  Merchant(
      {required this.accountBank,
      required this.accountNumber,
      required this.businessName,
      required this.businessMobile,
      this.businessContact,
      this.businessEmail,
      required this.country,
      this.merchantId,
      this.splitType = 'percentage',
      this.meta,
      this.secretKey,
      this.splitValue = '0.1'});

  toMap() {
    return {
      "account_bank": accountBank,
      "account_number": accountNumber,
      "business_name": businessName,
      "business_email": businessEmail,
      "business_contact": businessContact,
      "business_contact_mobile": businessMobile,
      "business_mobile": businessMobile,
      "split_type": splitType,
      "split_value": splitValue,
      "country": countriesISO[country],
      "seckey": secretKey,
      "meta": meta
    };
  }
}

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

  factory ReQueryResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json["data"] ?? {};
    return ReQueryResponse(
        status: json["status"],
        dataStatus: data["status"],
        message: json["message"],
        txRef: data['tx_ref'],
        hasData: data.isNotEmpty,
        rawResponse: json,
        card: data['card'] != null ? BankCard.fromMap(data['card']) : null,
        chargedAmount: data["charged_amount"].toString(),
        narration: data["narration"],
        transactionId: data["id"].toString());
  }

  @override
  List<Object?> get props => [status, dataStatus, card];
}
