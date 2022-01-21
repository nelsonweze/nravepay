import 'package:nravepay/nravepay.dart';

class Payload {
  /// This is the amount to be charged.
  double amount;

  /// This is the specified currency to charge in.
  String currency;

  /// This is the number on the cardholders card. E.g. 5399 6701 2349 0229.
  String cardNumber;

  /// Card security code. This is 3/4 digit code at the back
  ///  of the customers card, used for web payments.
  String cvv;

  /// Two-digit number representing the card's expiration month.
  String expiryMonth;

  /// Two digit number representing the card's expiration year
  String expiryYear;

  /// This is the email address of the customer
  String email;

  /// This is a unique reference peculiar to the transaction being carried out.
  String txRef;

  /// This is the phone number linked to the customer's mobile money account
  String? phoneNumber;

  /// This is the first name of the customer.
  String firstname;

  /// This is the last name of the customer.
  String lastname;

  /// This should be set to true for preauthoize card transactions
  bool preauthorize;

  /// This is a url you provide, we redirect to it after the
  /// customer completes payment and append the response to
  /// it as query parameters. (3DSecure only)
  String redirectUrl;

  /// IP - Internet Protocol. This represents the current IP
  ///  address of the customer carrying out the transaction
  String? clientIp;

  /// This is the fingerprint for the device being used. It can be generated
  /// using a library on whatever platform is being used
  String? deviceFingerprint;

  /// This is used to include additional payment information
  Meta? meta;

  /// This is an object that contains the authorization details of the card you want to charge. The authorization instructions for card charges are returned in the initiate charge call as [meta.authorization]
  Authorization? authorization;

  /// The default saved card token
  String? token;

  /// This is the cards issuing country.
  /// It is required when the suggested auth mode is avs_noauth
  String? country;

  /// This  displays in the debit narration.
  String? narration;

  /// This is the id of a previously created payment plan
  /// needed to add a card user to the payment plan.
  String? paymentPlan;

  /// This specifies that the payment method being used. it should be set to - card

  String? paymentType;

  /// This is an array of objects containing the subaccount IDs to split the payment into.
  List<SubAccount> subaccounts;

  /// The developers's public key
  String get pbfPubKey => Setup.instance.publicKey;

  /// The developer's secret key
  String get secKey => Setup.instance.secKey;

  /// The version to use. Either [Version.v2] or [Version.v3]
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
    required this.redirectUrl,
    this.clientIp,
    this.deviceFingerprint,
    this.meta,
    this.narration,
    this.authorization,
    this.paymentPlan,
    this.paymentType,
    this.subaccounts = const [],
  });

  /// Parses a [PayInitializer] object to [Payload] object
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

  /// Convert payload object to JSON when charging with token
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

  /// Convert payload object to JSON
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
