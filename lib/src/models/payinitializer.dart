import 'package:nravepay/nravepay.dart';

import 'models.dart';

class PayInitializer {
  /// Your customer email. Must be provided otherwise your customer will be promted to input it
  String email;

  /// The amount to be charged in the supplied [currency]. Must be a valid non=null and
  /// positive double. Otherwise, the customer will be asked to input an
  /// amount (this is especially useful for donations).
  double amount;

  // /// Rave's merchant account public key.
  // String publicKey;

  // /// Rave's merchant encryption key
  // String encryptionKey;

  // /// Rave's secret encryption key
  // String secKey;

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

  /// URL to redirect to when a transaction is completed. This is useful for 3DSecure payments so we can redirect your customer back to a custom page you want to show them.
  String redirectUrl;

  /// The text that is displayed on the pay button. Defaults to "Pay [currency][amount]"
  String? payButtonText;
  String? token;
  String? phoneNumber;
  bool preauthorize;

  Function(HttpResult) onComplete;

  /// The type of transaction used to sort payments in firestore
  String paymentType;

  PayInitializer({
    required this.amount,
    required this.email,
    required this.txRef,
    required this.onComplete,
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
    this.paymentType = PaymentType.card,
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
      meta: meta,
      paymentType: paymentType,
      subAccounts: subAccounts,
      email: email,
      txRef: txRef,
      paymentPlan: paymentPlan,
      redirectUrl: redirectUrl,
      payButtonText: payButtonText,
      preauthorize: preauthorize,
      onComplete: onComplete,
    );
  }
}