import 'dart:convert';

import 'payment.dart';
import 'package:equatable/equatable.dart';
import 'util.payment.dart';

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
  String? phoneNumber;
  bool preauthorize;

  Function(HttpResult) onComplete;

  /// The type of transaction used to sort payments in firestore
  String? paymentType;

  ///Choose between Rave v2 and v3
  Version version;

  PayInitializer(
      {required this.amount,
      required this.email,
      required this.txRef,
      required this.onComplete,
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
      this.preauthorize = false,
      bool? staging,
      this.paymentPlan,
      this.paymentType,
      this.redirectUrl = "https://payment-status-page.firebaseapp.com/",
      this.payButtonText,
      this.phoneNumber,
      this.version = Version.v2})
      : this.staging = Env.test;

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
        paymentPlan: this.paymentPlan,
        redirectUrl: this.redirectUrl,
        payButtonText: this.payButtonText,
        preauthorize: this.preauthorize,
        onComplete: this.onComplete,
        version: this.version);
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
  Version version;

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
      this.subaccounts = const [],
      this.version = Version.v2});

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
        version = i.version,
        this.paymentPlan = i.paymentPlan ?? '';

  withToken() {
    return {
      "token": token,
      "email": email,
      "currency": currency,
      "country": country,
      "amount": amount,
      "tx_ref": txRef,
      "txRef": txRef,
      "ip": clientIp,
      "narration": narration,
      "device_fingerprint": deviceFingerprint,
      "payment_plan": paymentPlan,
      "subaccounts": subaccounts.isEmpty
          ? null
          : subaccounts.map((a) => a.toMap()).toList(),
      "preauthorize": preauthorize,
      "SECKEY": secKey
    };
  }

  toMap() {
    if (version == Version.v2)
      return {
        "PBFPubKey": pbfPubKey,
        "cardno": cardNumber,
        "cvv": cvv,
        "expirymonth": expiryMonth,
        "expiryyear": expiryYear,
        "currency": currency,
        "country": country,
        "amount": amount,
        "email": email,
        "phonenumber": phoneNumber,
        "firstname": firstname,
        "lastname": lastname,
        "subaccounts": subaccounts.isNotEmpty
            ? subaccounts.map((e) => e.toMap()).toList()
            : [],
        "txRef": txRef,
        "meta": meta?.toMap(),
        "redirect_url": redirectUrl,
        "device_fingerprint": deviceFingerprint,
        ...authorization?.toMap(version)
      };
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
      "subaccounts": subaccounts.isNotEmpty
          ? subaccounts.map((e) => e.toMap()).toList()
          : [],
      "authorization": authorization?.toMap(version)
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

  toMap(Version version) {
    if (version == Version.v2)
      return {
        "suggested_auth": mode.toUpperCase(),
        "billingzip": zipcode,
        "billingcity": city,
        "billingaddress": address,
        "billingstate": state,
        "billingcountry": country,
        "pin": pin
      };
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
  String id;
  String token;
  String last4digits;
  String first6digits;
  String expiry;
  String issuer;
  String type;
  String? country;

  BankCard(
      {required this.issuer,
      required this.token,
      required this.expiry,
      required this.last4digits,
      required this.id,
      this.first6digits = '',
      this.country,
      this.type = 'bankcard'});

  BankCard.fromMap(Map map, bool isV2)
      : id = map["id"] ??
            "${DateTime.now().microsecondsSinceEpoch}_${map["last_4digits"]}",
        token = isV2
            ? map["card_tokens"] != null
                ? (map["card_tokens"] as List).first["embedtoken"]
                : null
            : map["token"],
        first6digits = isV2 ? map["cardBIN"] : map["first_6digits"],
        last4digits = isV2 ? map["last4digits"] : map["last_4digits"],
        expiry =
            isV2 ? "${map["expirymonth"]}/${map["expiryyear"]}" : map["expiry"],
        type = map["type"],
        country = map["country"],
        issuer = isV2 ? map["brand"] : map["issuer"];

  toMap() {
    return {
      "id": id,
      "token": token,
      "last_4digits": last4digits,
      "expiry": expiry,
      "country": country,
      "first_6digits": first6digits,
      "issuer": issuer,
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
  final String? chargeResponseCode;
  final String flwRef;
  final String txRef;
  final String? orderRef;
  final String? chargeResponseMessage;
  final String authUrl;
  final String appFee;
  final String currency;
  final String chargedAmount;
  final bool hasData;
  final Map rawResponse;
  final BankCard? card;
  final Meta meta;
  final String? suggestedAuth;

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
      required this.id,
      this.orderRef,
      this.suggestedAuth,
      this.chargeResponseCode});

  factory ChargeResponse.fromJson(Map<String, dynamic> json, Version version) {
    Map<String, dynamic> data = json["data"] ?? {};
    bool isV2 = version == Version.v2;

    return ChargeResponse(
        status: json["status"],
        message: json["message"],
        hasData: data.isNotEmpty,
        id: data["id"],
        authModel: isV2 ? data["authModelUsed"] : data["auth_model"],
        chargeResponseStatus: data["status"],
        flwRef: isV2 ? data["flwRef"] : data["flw_ref"],
        txRef: isV2 ? data["txRef"] : data["tx_ref"],
        orderRef: isV2 ? data["orderRef"] : data["order_ref"],
        chargeResponseMessage:
            isV2 ? data["chargeResponseMessage"] : data["processor_response"],
        chargeResponseCode: data["chargeResponseCode"],
        suggestedAuth: data["suggested_auth"],
        authUrl: isV2 ? data["authurl"] : data["auth_url"],
        appFee: isV2 ? data["appfee"].toString() : data["app_fee"].toString(),
        currency: data["currency"],
        chargedAmount: data["charged_amount"].toString(),
        meta: json['meta'] != null ? Meta.fromMap(json['meta']) : Meta(),
        card: data['card'] != null
            ? BankCard.fromMap(data['card'], version == Version.v2)
            : null,
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
  })  : this.pBFPubKey = payload.pbfPubKey,
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

  factory ReQueryResponse.fromJson(Map<String, dynamic> json, bool isV2) {
    Map<String, dynamic> data = json["data"] ?? {};
    var message = data["vbvrespmessage"]?.toString();
    if (message == null || message.toUpperCase() == "N/A") {
      message = data["chargeResponseMessage"];
    }
    return ReQueryResponse(
        status: json["status"],
        dataStatus: data["status"],
        message: isV2 ? message : data["message"],
        txRef: isV2 ? data["txref"] : data['tx_ref'],
        hasData: data.isNotEmpty,
        rawResponse: json,
        card:
            data['card'] != null ? BankCard.fromMap(data['card'], isV2) : null,
        chargedAmount: isV2
            ? data["chargedamount"].toString()
            : data["charged_amount"].toString(),
        narration: data["narration"],
        transactionId: isV2 ? data["txid"].toString() : data["id"].toString());
  }

  @override
  List<Object?> get props => [status, dataStatus, card];
}
