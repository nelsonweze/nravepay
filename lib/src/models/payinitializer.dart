import 'package:nravepay/nravepay.dart';

class PayInitializer {
  /// Your customer email. Must be provided otherwise your customer will be promted to input it
  String email;

  /// The amount to be charged in the supplied [currency]. Must be a valid non=null and
  /// positive double. Otherwise, the customer will be asked to input an
  /// amount (this is especially useful for donations).
  double amount;

  /// Transaction reference. It cannot be null or empty
  String txRef;

  /// Custom description added by the merchant.
  String narration;

  /// An ISO 4217 currency code (e.g USD, NGN). I cannot be empty or null. Defaults to NGN
  String currency;

  /// ISO 3166-1 alpha-2 country code (e.g US, NG). Defaults to NG
  String country;

  /// Your customer's first name.
  String firstname;

  /// Your customer's last name.
  String lastname;

  /// Your custom data in key-value pairs
  Map<String, String>? metadata;

  /// As list of sub-accounts. Sub accounts are your vendor's accounts that you
  /// want to settle per transaction.
  /// See https://developer.flutterwave.com/docs/split-payment
  List<SubAccount>? subAccounts;

  /// This is the id of a previously created payment plan
  /// needed to add a card user to the payment plan.
  String? paymentPlan;

  /// URL to redirect to when a transaction is completed. This is useful for 3DSecure payments so we can redirect your customer back to a custom page you want to show them.
  /// defaults to 'https://payment-status-page.firebaseapp.com/'
  String redirectUrl;

  /// The text that is displayed on the pay button. Defaults to "Pay [currency][amount]"
  String? payButtonText;

  /// The default saved card token.
  /// You don't need to supply this here
  String? token;

  /// This is the phone number linked to the customer's mobile money account
  String? phoneNumber;

  /// This should be set to true for preauthoize card transactions
  bool preauthorize;

  /// Build your own custom pay button
  PaymentButtonBuilder? buttonBuilder;

  /// A callback function called if the transaction is completed
  Function(HttpResult) onComplete;

  /// The type of transaction used to sort payments in firestore
  String paymentType;

  PayInitializer({
    required this.amount,
    required this.email,
    required this.txRef,
    required this.onComplete,
    this.currency = 'NGN',
    this.country = 'NG',
    this.narration = '',
    this.firstname = '',
    this.lastname = '',
    this.metadata,
    this.subAccounts,
    this.token,
    this.preauthorize = false,
    this.paymentPlan,
    this.paymentType = PaymentType.card,
    this.buttonBuilder,
    this.redirectUrl = 'https://payment-status-page.firebaseapp.com/',
    this.payButtonText,
    this.phoneNumber,
  });

  PayInitializer copyWith({final String? token}) {
    return PayInitializer(
        token: token ?? this.token,
        amount: amount,
        country: country,
        currency: currency,
        narration: narration,
        firstname: firstname,
        lastname: lastname,
        metadata: metadata,
        paymentType: paymentType,
        subAccounts: subAccounts,
        email: email,
        txRef: txRef,
        paymentPlan: paymentPlan,
        redirectUrl: redirectUrl,
        payButtonText: payButtonText,
        preauthorize: preauthorize,
        onComplete: onComplete,
        buttonBuilder: buttonBuilder);
  }

  factory PayInitializer.fromJson(Map<String, dynamic> json) {
    return PayInitializer(
        amount: json['amount'] ?? 0.0,
        email: json['email'] ?? '',
        txRef: json['txRef'] ?? '',
        subAccounts: (json['subAccounts'] as List?)
            ?.map((e) => SubAccount(e['id']))
            .toList(),
        paymentPlan: json['paymentPlan'],
        country: json['country'],
        currency: json['currency'],
        narration: json['narration'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        phoneNumber: json['phoneNumber'],
        redirectUrl: json['redirectUrl'],
        paymentType: json['paymentType'],
        preauthorize: json['preauthorize'],
        payButtonText: json['payButtonText'],
        token: json['token'],
        metadata: json['metadata'],
        onComplete: (_) => null);
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'subAccounts': subAccounts?.map((e) => e.toMap()).toList(),
      'email': email,
      'paymentPlan': paymentPlan,
      'txRef': txRef,
      'currency': currency,
      'narration': narration,
      'country': country,
      'firstname': firstname,
      'lastname': lastname,
      'phoneNumber': phoneNumber,
      'redirectUrl': redirectUrl,
      'paymentType': paymentType,
      'preauthorize': preauthorize,
      'metadata': metadata?..putIfAbsent('tel', () => phoneNumber.toString())
    };
  }
}
