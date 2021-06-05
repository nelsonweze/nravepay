import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'blocs/connection.bloc.dart';
import 'blocs/transaction.bloc.dart';
import 'models.dart';
import 'services.dart';
import 'util.payment.dart';

class Strings {
  static const ngn = 'NGN';
  static const ng = 'NG';
  static const card = 'Card';
  static const account = 'Wallet';
  static const amount = 'Amount';
  static const ach = 'ACH';
  static const mpesa = 'Mpesa';
  static const ghanaMobileMoney = 'Ghana Mobile Money';
  static const ugandaMobileMoney = 'Uganda Mobile Money';
  static const mobileMoneyFrancophoneAfrica = 'Mobile Money Francophone Africa';
  static const pay = 'Pay';
  static const invalidCVV = 'Enter a valid cvv';
  static const invalidExpiry = 'Enter a valid expiry date';
  static const invalidCardNumber = 'Enter a valid card number';
  static const invalidPhoneNumber = 'Enter a valid phone number';
  static const invalidAccountNumber = 'Enter a valid account number';
  static const invalidAmount = 'Enter a valid amount';
  static const invalidEmail = 'Enter a valid email';
  static const invalidBVN = 'Enter a valid BVN';
  static const invalidVoucher = 'Enter a valid voucher code';
  static const invalidDOB = 'Enter a valid date of birth';
  static const demo = 'Demo';
  static const youCancelled = 'You cancelled';
  static const sthWentWrong = 'Something went wrong';
  static const noResponseData = 'No response data was returned';
  static const unknownAuthModel = 'Unknown auth model';
  static const enterOtp = 'Enter your one  time password (OTP)';
  static const noAuthUrl = 'No authUrl was returned';

  static cannotBeNull(String name) => '$name cannot be null';

  static cannotBeNullOrNegative(String name) =>
      '${cannotBeNull(name)} or negative';

  static cannotBeNullOrEmpty(String name) => '${cannotBeNull(name)} or empty';
}

class Currency {
  String? name;
  String? symbol;
  String? countryCode;
  int? value;
  Currency({this.name, this.symbol, this.countryCode, this.value});
}

List<Currency> currencies = [
  Currency(name: 'NGN', symbol: '₦', countryCode: 'NG', value: 0),
  // Currency(name: 'USD', symbol: '\$', countryCode: 'US', value: 1),
  // Currency(name: 'EUR', symbol: '€', countryCode: 'EU', value: 2),
  // Currency(name: 'RUB', symbol: '₽', countryCode: 'RU', value: 3),
];

class NRavePayException {
  final String? message;

  NRavePayException({data}) : message = _getMessage(data);

  static String? _getMessage(e) {
    if (e == null) return 'Error occurred.';

    if (e is String) {
      return e;
    }
    if (e is Map) {
      if (e.containsKey("message")) {
        return e["message"];
      }
      if (e.containsKey("data")) {
        var data = e["data"];
        if (data is Map) {
          return data["message"];
        } else {
          return data;
        }
      }
    }

    return 'Error occurred';
  }
}

enum Version { v2, v3 }

class Setup {
  static Setup get instance => ngetIt<Setup>();

  Version version = Version.v2;
  String publicKey = '';
  String encryptionKey = '';
  String secKey = '';
  bool staging = false;

  updateParams(Version v, String pKey, String eKey, String sKey, bool stag) {
    version = v;
    publicKey = pKey;
    encryptionKey = eKey;
    secKey = sKey;
    staging = stag;
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

  static setup(
      {required String publicKey,
      required String encryptionKey,
      required String secKey,
      required bool staging,
      required Version version}) async {
    var initializer = PayInitializer(
      amount: 0.0,
      txRef: '',
      email: '',
      onComplete: print,
    );
    //initializing

    var repository = NRavePayRepository()..initializer = initializer;
    ngetIt.registerSingletonAsync<Setup>(() => Future.value(Setup()
      ..updateParams(version, publicKey, encryptionKey, secKey, staging)));
    ngetIt.registerSingleton<NRavePayRepository>(repository);
    ngetIt.registerSingleton<Env>(Env());
    ngetIt.registerSingletonWithDependencies<HttpService>(() => HttpService(),
        dependsOn: [Setup]);
    ngetIt
        .registerLazySingleton<TransactionService>(() => TransactionService());
    ngetIt.registerLazySingleton<BankService>(() => BankService());
    ngetIt.registerLazySingleton<ConnectionBloc>(() => ConnectionBloc());
    ngetIt.registerLazySingleton<TransactionBloc>(() => TransactionBloc());

    return repository;
  }

  static update(PayInitializer initializer) {
    var repository = NRavePayRepository.instance..initializer = initializer;
    ngetIt.registerSingleton<NRavePayRepository>(repository);
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  String? previousText;
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;

      if (nonZeroIndex % 2 == 0 &&
          ((!_isDeletion(previousText, text) && nonZeroIndex != 4) ||
              (nonZeroIndex != text.length))) {
        buffer.write('/');
      }
    }

    previousText = text;
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}

bool _isDeletion(String? prevText, String newText) {
  if (prevText == null) {
    return false;
  }

  return prevText.length > newText.length;
}
