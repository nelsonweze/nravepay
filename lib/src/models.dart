import 'payment.dart';
import 'package:equatable/equatable.dart';
import 'util.payment.dart';

class PayInitializer {
  /// Your customer email. Must be provided otherwise your customer will be promted to input it
  String? email;

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
  String? txRef;

  /// Order reference. Unique ref for the mobile money transaction to be provided by the merchant.
  /// Required for mobile money francophone africa payments
  String? orderRef;

  /// Custom description added by the merchant.
  String narration;

  /// An ISO 4217 currency code (e.g USD, NGN). I cannot be empty or null. Defaults to NGN
  String currency;

  /// ISO 3166-1 alpha-2 country code (e.g US, NG). Defaults to NG
  String country;

  /// Your customer's first name.
  String fName;

  /// Your customer's last name.
  String lName;

  /// Your custom data in key-value pairs
  Map<String, String>? meta;

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

  /// The type of transaction used to sort payments in firestore
  String? paymentType;
  dynamic Function(HttpResult)? onTransactionComplete;

  PayInitializer({
    required this.amount,
    required this.publicKey,
    required this.encryptionKey,
    required this.secKey,
    this.currency = Strings.ngn,
    this.country = Strings.ng,
    this.narration = '',
    this.fName = '',
    this.lName = '',
    this.meta,
    this.subAccounts,
    this.token,
    this.useCard = false,
    bool? staging,
    this.email,
    this.txRef,
    this.onTransactionComplete,
    this.orderRef,
    this.paymentPlan,
    this.paymentType,
    this.redirectUrl = "https://payment-status-page.firebaseapp.com/",
    this.payButtonText,
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
        fName: this.fName,
        lName: this.lName,
        meta: this.meta,
        paymentType: this.paymentType,
        staging: this.staging,
        subAccounts: this.subAccounts,
        email: this.email,
        txRef: this.txRef,
        useCard: this.useCard,
        orderRef: this.orderRef,
        paymentPlan: this.paymentPlan,
        redirectUrl: this.redirectUrl,
        payButtonText: this.payButtonText,
        onTransactionComplete: this.onTransactionComplete);
  }
}

class Payload {
  String? expiryMonth;
  String pbfPubKey;
  String secKey;
  String? ip;
  String lastName;
  String firstName;
  String currency;
  String country;
  String amount;
  String email;
  String expiryYear;
  String cvv;
  String cardNo;
  String paymentPlan;
  String? network;
  String bvn;
  String? voucher;
  bool isPreAuth = false;
  String? phoneNumber;
  String? accountNumber;
  Bank? bank;
  String? passCode;
  String? txRef;
  String? orderRef;
  Map<String, String>? meta;
  List<SubAccount> subAccounts;
  String cardBIN;
  String pin;
  String? suggestedAuth;
  String? narration;
  String? billingZip;
  String? billingCity;
  String? billingAddress;
  String? billingState;
  String? billingCountry;
  String? redirectUrl;
  String? paymentType;
  String token;

  Payload.fromInitializer(PayInitializer i)
      : this.amount = i.amount.toString(),
        this.currency = i.currency,
        this.country = i.country,
        this.email = i.email ?? '',
        this.firstName = i.fName,
        this.lastName = i.lName,
        this.txRef = i.txRef,
        this.orderRef = i.orderRef,
        this.meta = i.meta,
        this.subAccounts = i.subAccounts ?? [],
        this.redirectUrl = i.redirectUrl,
        this.pbfPubKey = i.publicKey,
        this.isPreAuth = false,
        this.token = i.token ?? "",
        this.secKey = i.secKey,
        this.expiryYear = '',
        this.cvv = '',
        this.cardNo = '',
        this.bvn = '',
        this.cardBIN = '',
        this.pin = '',
        this.paymentPlan = i.paymentPlan ?? '';

  Payload(
      {required this.expiryMonth,
      required this.pbfPubKey,
      required this.ip,
      required this.lastName,
      required this.firstName,
      required this.amount,
      required this.email,
      required this.expiryYear,
      required this.cvv,
      required this.cardNo,
      required this.paymentPlan,
      required this.network,
      required this.bvn,
      required this.voucher,
      required this.phoneNumber,
      required this.accountNumber,
      required this.passCode,
      required this.secKey,
      this.currency = Strings.ngn,
      this.country = Strings.ng,
      this.isPreAuth = false,
      this.txRef,
      this.orderRef,
      this.cardBIN = '',
      this.pin = '',
      this.token = '',
      this.subAccounts = const []});

  Map<String, dynamic> toJson(String? paymentType) {
    var json = <String, dynamic>{
      "narration": narration,
      "PBFPubKey": pbfPubKey,
      "lastname": lastName,
      "firstname": firstName,
      "currency": currency,
      "country": country,
      "amount": amount,
      "email": email,
      "txRef": txRef,
      "redirect_url": redirectUrl,
    };
    putIfNotNull(
      map: json,
      key: "token",
      value: token,
    );
    putIfNotNull(map: json, key: "payment_type", value: paymentType);
    putIfNotNull(map: json, key: "expirymonth", value: expiryMonth);
    putIfNotNull(map: json, key: "expiryyear", value: expiryYear);
    putIfNotNull(map: json, key: "cvv", value: cvv);
    putIfNotNull(map: json, key: "cardno", value: cardNo);
    putIfNotNull(map: json, key: "accountbank", value: bank?.code);
    putIfNotNull(map: json, key: "bvn", value: bvn);
    putIfNotNull(map: json, key: "accountnumber", value: accountNumber);
    putIfNotNull(map: json, key: "passcode", value: passCode);
    putIfNotNull(map: json, key: "phonenumber", value: phoneNumber);
    putIfNotNull(map: json, key: "payment_plan", value: paymentPlan);
    putIfNotNull(map: json, key: "billingzip", value: billingZip);
    putIfNotNull(map: json, key: "pin", value: pin);
    putIfNotNull(map: json, key: "suggested_auth", value: suggestedAuth);
    putIfNotNull(map: json, key: "billingcity", value: billingCity);
    putIfNotNull(map: json, key: "billingaddress", value: billingAddress);
    putIfNotNull(map: json, key: "billingstate", value: billingState);
    putIfNotNull(map: json, key: "billingcountry", value: billingCountry);
    putIfNotNull(map: json, key: "billingzip", value: billingZip);
    putIfNotNull(
        map: json, key: "charge_type", value: isPreAuth ? "preauth" : null);
    if (meta == null) meta = {};
    meta!["sdk"] = "flutter";
    json["meta"] = [
      for (var e in meta!.entries) {"metaname": e.key, "metavalue": e.value}
    ];
    putIfNotNull(
      map: json,
      key: "redirect_url",
      value: redirectUrl,
    );
    putIfNotNull(
        map: json,
        key: "subaccounts",
        value: !subAccounts.isNotEmpty
            ? null
            : subAccounts.map((a) => a.toMap()).toList());
    return json;
  }
}

class SubAccount {
  final String id;

  SubAccount(this.id);

  Map<String, String> toMap() {
    return {'id': id};
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

  HttpResult({required this.status, this.rawResponse, this.message});

  @override
  String toString() {
    return 'HttpResult{status: $status, rawResponse: $rawResponse, message: $message}';
  }

  @override
  List<Object?> get props => [status, rawResponse, message];
}

enum HttpStatus { success, error, cancelled, left }

class Bank {
  final String? name;
  final String? code;
  final bool? internetBanking;

  Bank.fromJson(Map map)
      : this.name = map['bankname'],
        this.code = map['bankcode'],
        this.internetBanking = map['internetbanking'];

  bool showBVNField() =>
      code == '033'; // 033 is code for UNITED BANK FOR AFRICA PLC

  bool showDOBField() =>
      code == '057' || code == '033'; // 057 is for ZENITH BANK PLC

  bool showAccountNumField() => !internetBanking!;
}

class BankCard {
  String? id;
  String? embedtoken;
  String? last4digits;
  String? expirymonth;
  String? expiryyear;
  String? cardBIN;
  String? brand;
  String? type;

  BankCard(
      {this.brand,
      this.cardBIN,
      this.embedtoken,
      this.expirymonth,
      this.expiryyear,
      this.last4digits,
      this.id,
      this.type});

  BankCard.fromMap(Map map, {bool response = false})
      : id = map["id"],
        embedtoken =
            response ? map["card_tokens"][0]["embedtoken"] : map["embedtoken"],
        last4digits = map["last4digits"],
        expirymonth = map["expirymonth"],
        expiryyear = map["expiryyear"],
        cardBIN = map["cardBIN"],
        type = map["type"],
        brand = map["brand"];

  toMap() {
    return {
      "id": id,
      "embedtoken": embedtoken,
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
  final String? status;
  final String? message;
  final String? validateInstructions;
  final String? validateInstruction;
  final String? suggestedAuth;
  final String? chargeResponseCode;
  final String? authModelUsed;
  final String? flwRef;
  final String? txRef;
  final String? chargeResponseMessage;
  final String? authUrl;
  final String? appFee;
  final String? currency;
  final String chargedAmount;
  final String? redirectUrl;
  final bool hasData;
  final Map rawResponse;
  final BankCard? card;

  ChargeResponse({
    required this.status,
    required this.message,
    required this.validateInstructions,
    required this.suggestedAuth,
    required this.chargeResponseCode,
    required this.authModelUsed,
    required this.flwRef,
    required this.txRef,
    required this.chargeResponseMessage,
    required this.authUrl,
    required this.appFee,
    required this.currency,
    required this.chargedAmount,
    required this.redirectUrl,
    required this.hasData,
    required this.rawResponse,
    required this.validateInstruction,
    required this.card,
  });

  factory ChargeResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json["data"] ?? {};
    return ChargeResponse(
        status: json["status"],
        message: json["message"],
        hasData: data.isNotEmpty,
        suggestedAuth: data["suggested_auth"],
        chargeResponseCode: data["chargeResponseCode"],
        authModelUsed: data["authModelUsed"],
        flwRef: data["flwRef"],
        validateInstruction: data["validateInstruction"],
        validateInstructions: data.containsKey("validateInstructions")
            ? data["validateInstructions"]["instruction"]
            : null,
        txRef: data["txRef"],
        chargeResponseMessage: data["chargeResponseMessage"],
        authUrl: data["authurl"],
        appFee: data["appFee"],
        currency: data["currency"],
        chargedAmount: data["charged_amount"].toString(),
        redirectUrl: data["redirectUrl"],
        card: data['card'] != null
            ? BankCard.fromMap(data['card'], response: true)
            : null,
        rawResponse: json);
  }

  Map<String, dynamic> toJson() => rawResponse as Map<String, dynamic>;

  @override
  List<Object?> get props => [
        status,
        message,
        validateInstructions,
        validateInstruction,
        suggestedAuth,
        chargeResponseCode,
        authModelUsed,
        flwRef,
        chargeResponseMessage,
        authUrl,
        appFee,
        currency,
        chargedAmount,
        redirectUrl,
        hasData,
        card,
      ];
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
  final String? chargeResponseCode;
  final String? dataStatus;
  final Map? rawResponse;
  final String? message;
  final bool? hasData;
  final BankCard? card;
  ReQueryResponse(
      {this.status,
      this.chargeResponseCode,
      this.dataStatus,
      this.rawResponse,
      this.message,
      this.hasData,
      this.card});

  factory ReQueryResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json["data"] ?? {};
    String? message = data["vbvmessage"]?.toString();
    if (message == null || message.toUpperCase() == "N/A") {
      message = data["chargemessage"];
    }
    return ReQueryResponse(
        status: json["status"],
        chargeResponseCode: data["chargecode"],
        dataStatus: data["status"],
        message: message,
        hasData: data.isNotEmpty,
        rawResponse: json,
        card: data['card'] != null
            ? BankCard.fromMap(data['card'], response: true)
            : null);
  }

  @override
  List<Object?> get props => [status, chargeResponseCode, dataStatus, card];
}
