import 'package:flutter/material.dart';
import 'package:nravepay/nravepay.dart';
import '../blocs/transaction.bloc.dart';

class Strings {
  final String invalidCVV;
  final String invalidExpiry;
  final String invalidCardNumber;
  final String invalidPhoneNumber;
  final String invalidAccountNumber;
  final String invalidAmount;
  final String invalidEmail;
  final String invalidVoucher;
  final String invalidDOB;
  final String invalidPIN;
  final String fieldRequired;
  final String noResponseData;
  final String enterOtp;
  final String enterPIN;
  final String enterBillingAdressText;
  final String addressHint;
  final String cityHint;
  final String stateHint;
  final String zipCodeHint;
  final String countryHint;
  final String pinHint;
  final String emailHint;
  final String cardExpirtHint;
  final String cardNumberHint;
  final String ccvHint;
  final String otpHint;
  final String continueText;
  final String emailLabel;
  final String cardExpiryLabel;
  final String cardNumberLabel;
  final String cvvLabel;

  final String securedBy;
  final String flutterwave;
  final String wantToCancel;
  final String cancelPayment;
  final String yes;
  final String no;

  static String cannotBeNull(String name) => '$name cannot be null';

  static String cannotBeNullOrNegative(String name) =>
      '${cannotBeNull(name)} or negative';

  static String cannotBeNullOrEmpty(String name) =>
      '${cannotBeNull(name)} or empty';

  const Strings(
      {this.invalidCVV = 'Enter a valid cvv',
      this.invalidExpiry = 'Enter a valid expiry date',
      this.invalidCardNumber = 'Enter a valid card number',
      this.invalidPhoneNumber = 'Enter a valid phone number',
      this.invalidAccountNumber = 'Enter a valid account number',
      this.invalidAmount = 'Enter a valid amount',
      this.invalidEmail = 'Enter a valid email',
      this.invalidVoucher = 'Enter a valid voucher code',
      this.invalidDOB = 'Enter a valid date of birth',
      this.invalidPIN = 'PIN must be exactly 4 digits',
      this.fieldRequired = 'Field is required',
      this.noResponseData = 'No response data was returned',
      this.enterOtp = 'Enter your one time password (OTP)',
      this.enterPIN =
          'Please, enter your card pin to continue your transaction',
      this.enterBillingAdressText = 'Enter your billing address details',
      this.addressHint = 'Address e.g 20 Saltlake Eldorado',
      this.cityHint = 'City e.g. Livingstone',
      this.stateHint = 'State e.g. CA',
      this.zipCodeHint = 'Zip code e.g. 928302',
      this.countryHint = 'Country e.g. US',
      this.continueText = 'Continue',
      this.pinHint = 'PIN',
      this.cardExpirtHint = 'MM/YY',
      this.cardNumberHint = '0000 0000 0000 0000',
      this.emailHint = 'EXAMPLE@EMAIL.COM',
      this.ccvHint = '123',
      this.otpHint = '12345',
      this.emailLabel = 'EMAIL',
      this.cardExpiryLabel = 'CARD EXPIRY',
      this.cardNumberLabel = '0000 0000 0000 0000',
      this.cvvLabel = 'CVV',
      this.flutterwave = 'Flutterwave',
      this.securedBy = ' Secured by  ',
      this.wantToCancel = 'Do you want to cancel this payment?',
      this.cancelPayment = 'Cancel Payment',
      this.yes = 'YES',
      this.no = 'NO'});

  Strings copyWith({
    final String? invalidCVV,
    final String? invalidExpiry,
    final String? invalidCardNumber,
    final String? invalidPhoneNumber,
    final String? invalidAccountNumber,
    final String? invalidAmount,
    final String? invalidEmail,
    final String? invalidVoucher,
    final String? invalidDOB,
    final String? invalidPIN,
    final String? fieldRequired,
    final String? noResponseData,
    final String? enterOtp,
    final String? enterPIN,
    final String? enterBillingAdressText,
    final String? addressHint,
    final String? cityHint,
    final String? stateHint,
    final String? zipCodeHint,
    final String? countryHint,
    final String? pinHint,
    final String? emailHint,
    final String? cardExpirtHint,
    final String? cardNumberHint,
    final String? ccvHint,
    final String? otpHint,
    final String? continueText,
    final String? emailLabel,
    final String? cardExpiryLabel,
    final String? cardNumberLabel,
    final String? cvvLabel,
    final String? securedBy,
    final String? flutterwave,
    final String? wantToCancel,
    final String? cancelPayment,
    final String? yes,
    final String? no,
  }) {
    return Strings(
        invalidCVV: invalidCVV ?? this.invalidCVV,
        invalidExpiry: invalidExpiry ?? this.invalidExpiry,
        invalidCardNumber: invalidCardNumber ?? this.invalidCardNumber,
        invalidPhoneNumber: invalidPhoneNumber ?? this.invalidPhoneNumber,
        invalidAccountNumber: invalidAccountNumber ?? this.invalidAccountNumber,
        invalidAmount: invalidAmount ?? this.invalidAmount,
        invalidEmail: invalidEmail ?? this.invalidEmail,
        invalidVoucher: invalidVoucher ?? this.invalidVoucher,
        invalidDOB: invalidDOB ?? this.invalidDOB,
        invalidPIN: invalidPIN ?? this.invalidPIN,
        fieldRequired: fieldRequired ?? this.fieldRequired,
        noResponseData: noResponseData ?? this.noResponseData,
        enterOtp: enterOtp ?? this.enterOtp,
        enterPIN: enterPIN ?? this.enterPIN,
        enterBillingAdressText:
            enterBillingAdressText ?? this.enterBillingAdressText,
        addressHint: addressHint ?? this.addressHint,
        cityHint: cityHint ?? this.cityHint,
        stateHint: stateHint ?? this.stateHint,
        zipCodeHint: zipCodeHint ?? this.zipCodeHint,
        countryHint: countryHint ?? this.countryHint,
        pinHint: pinHint ?? this.pinHint,
        emailHint: emailHint ?? this.emailHint,
        cardExpiryLabel: cardExpiryLabel ?? this.cardExpiryLabel,
        cardNumberLabel: cardNumberLabel ?? this.cardNumberLabel,
        cvvLabel: cvvLabel ?? this.cvvLabel,
        otpHint: otpHint ?? this.otpHint,
        securedBy: securedBy ?? this.securedBy,
        flutterwave: flutterwave ?? this.flutterwave,
        wantToCancel: wantToCancel ?? this.wantToCancel,
        cancelPayment: cancelPayment ?? this.cancelPayment,
        yes: yes ?? this.yes,
        no: no ?? this.no);
  }
}

class Currency {
  String? name;
  String? symbol;
  String? countryCode;
  int? value;
  Currency({this.name, this.symbol, this.countryCode, this.value});
}

InputDecorationTheme inputDecoration(BuildContext context) =>
    InputDecorationTheme(
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.withOpacity(.7), width: 1),
            borderRadius: BorderRadius.circular(Setup.instance.borderRadius)),
        errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.red.withOpacity(.7), width: .5),
            borderRadius: BorderRadius.circular(Setup.instance.borderRadius)),
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey[400]!.withOpacity(.7), width: .5),
            borderRadius: BorderRadius.circular(Setup.instance.borderRadius)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: .5),
            borderRadius: BorderRadius.circular(Setup.instance.borderRadius)));

class NRavePayException {
  final String? message;

  NRavePayException({data}) : message = _getMessage(data);

  static String? _getMessage(e) {
    if (e == null) return 'Error occurred.';

    if (e is String) {
      return e;
    }
    if (e is Map) {
      if (e.containsKey('message')) {
        return e['message'];
      }
      if (e.containsKey('data')) {
        var data = e['data'];
        if (data is Map) {
          return data['message'];
        } else {
          return data;
        }
      }
    }

    return 'Error occurred';
  }
}

enum Version { v2, v3 }

typedef PaymentButtonBuilder = Widget Function(double, VoidCallback?);

class Setup {
  static Setup get instance => ngetIt<Setup>();

  Version version;
  String publicKey;
  String encryptionKey;
  String secKey;
  bool staging;
  bool allowSaveCard;
  String addCardHeaderText;
  String chooseCardHeaderText;
  String saveCardText;
  String payText;
  String addNewCardText;
  bool showFlutterwaveBadge;
  double borderRadius;

  /// Texts used such are error, warnings and hints
  Strings strings;

  Setup(
      {this.version = Version.v2,
      this.publicKey = '',
      this.encryptionKey = '',
      this.secKey = '',
      this.staging = false,
      this.allowSaveCard = false,
      this.addCardHeaderText = 'Add Card',
      this.chooseCardHeaderText = 'Choose Card',
      this.payText = 'Pay',
      this.saveCardText = 'Save card',
      this.addNewCardText = 'Add new card',
      this.strings = const Strings(),
      this.showFlutterwaveBadge = true,
      this.borderRadius = 12});

  Setup copyWith(
      {Version? version,
      String? publicKey,
      String? encryptionKey,
      String? secKey,
      bool? staging,
      bool? allowSaveCard,
      String? addCardHeaderText,
      String? chooseCardHeaderText,
      String? saveCardText,
      String? payText,
      String? addNewCardText,
      bool? showFlutterwaveBadge}) {
    return Setup(
        version: version ?? this.version,
        publicKey: publicKey ?? this.publicKey,
        encryptionKey: encryptionKey ?? this.encryptionKey,
        secKey: secKey ?? this.secKey,
        staging: staging ?? this.staging,
        allowSaveCard: allowSaveCard ?? this.allowSaveCard,
        addCardHeaderText: addCardHeaderText ?? this.addCardHeaderText,
        chooseCardHeaderText: chooseCardHeaderText ?? this.chooseCardHeaderText,
        saveCardText: saveCardText ?? this.saveCardText,
        payText: payText ?? this.payText,
        addNewCardText: addNewCardText ?? this.addNewCardText,
        showFlutterwaveBadge:
            showFlutterwaveBadge ?? this.showFlutterwaveBadge);
  }
}

class NRavePayRepository {
  static NRavePayRepository get instance => ngetIt<NRavePayRepository>();
  late PayInitializer initializer;

  List<BankCard>? _cards;
  List<BankCard>? get cards => _cards;

  String? _defaultCardId;
  String? get defaultCardId => _defaultCardId;

  void updateCards(List<BankCard>? cards, String? defaultCardId) {
    _cards = cards;
    _defaultCardId = defaultCardId;
  }

  static void setup(Setup setup) async {
    var initializer = PayInitializer(
        amount: 0.0,
        txRef: '',
        email: '',
        onComplete: print,
        country: '',
        currency: '');
    //initializing

    var repository = NRavePayRepository()..initializer = initializer;
    ngetIt.registerSingletonAsync<Setup>(() => Future.value(setup));
    ngetIt.registerSingleton<NRavePayRepository>(repository);
    ngetIt.registerSingleton<Env>(Env());
    ngetIt.registerSingletonWithDependencies<HttpService>(() => HttpService(),
        dependsOn: [Setup]);
    ngetIt
        .registerLazySingleton<TransactionService>(() => TransactionService());
    ngetIt.registerLazySingleton<BankService>(() => BankService());
    ngetIt.registerLazySingleton<TransactionBloc>(() => TransactionBloc());

    return;
  }

  static void update(PayInitializer initializer) {
    var repository = NRavePayRepository.instance..initializer = initializer;
    ngetIt.registerSingleton<NRavePayRepository>(repository);
  }
}
