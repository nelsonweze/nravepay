import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:tripledes/tripledes.dart';
import 'package:get_it/get_it.dart';
import 'package:tripledes_nullsafety/tripledes_nullsafety.dart';

export 'formatters/cardno_formatter.dart';
export 'formatters/cardmonth_formatter.dart';
export 'formatters/double_formatter.dart';

export 'card.util.dart';
export 'validator.util.dart';
export 'helpers.dart';

GetIt ngetIt = GetIt.instance..allowReassignment = true;

class Env extends ChangeNotifier {
  static Env? get instance => ngetIt<Env>();

  static bool beta = true;
  static bool prod = false;
  static bool test = false;

  static bool _drive = false;
  bool get drive => _drive;
  set drive(bool value) {
    _drive = value;
    notifyListeners();
  }
}

class SuggestedAuth {
  static const String OTP = 'OTP';
  static const String PIN = 'PIN';
  static const String AVS_NOAUTH = 'AVS_NOAUTH';
  static const String AVS_VBVSECURECODE = 'AVS_VBVSECURECODE';
  static const String NO_AUTH = 'NOAUTH_INTERNATIONAL';
  static const String REDIRECT = 'REDIRECT';
  static const String V_COMP = 'V-COMP';
  static const String GTB_OTP = 'GTB_OTP';
  static const String ACCESS_OTP = 'ACCESS_OTP';
  static const String VBV = 'VBVSECURECODE';
}

String formatAmount(num amount) {
  return NumberFormat.currency(name: '').format(amount);
}

String getEncryptedData(String str, String key) {
  var blockCipher = BlockCipher(TripleDESEngine(), key);
  return blockCipher.encodeB64(str);
}

/// Remove all line feed, carriage return and whitespace characters
String cleanUrl(String url) {
  return url.replaceAll(RegExp(r'[\n\r\s]+'), '');
}

bool get isInDebugMode {
  var inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

void putIfNotNull({required Map map, required key, required value}) {
  if (value == null || (value is String && value.isEmpty)) return;
  map[key] = value;
}

void putIfTrue({required Map map, required key, required bool value}) {
  if (!value) return;
  map[key] = value;
}

void printWrapped(Object text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text.toString())
      .forEach((match) => debugPrint(match.group(0)));
}

bool isTxPending(String? message, String? status) {
  return message == 'Charge authorization data required' ||
      message == 'Charge initiated' ||
      message == 'V-COMP' ||
      message == 'AUTH_SUGGESTION' ||
      status == 'PENDING' ||
      status == 'SUCCESS-PENDING-VALIDATION';
}
