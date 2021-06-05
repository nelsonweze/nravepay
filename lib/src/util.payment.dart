import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripledes/tripledes.dart';
import 'payment.dart';
import 'package:get_it/get_it.dart';

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

enum CardType { visa, master, amex, diners, discover, jcb, verve, unknown }

class SuggestedAuth {
  static const String OTP = 'OTP';
  static const String PIN = 'PIN';
  static const String AVS_NOAUTH = 'AVS_NOAUTH';
  static const String AVS_VBVSECURECODE = "AVS_VBVSECURECODE";
  static const String NO_AUTH = "NOAUTH_INTERNATIONAL";
  static const String REDIRECT = 'REDIRECT';
  static const String V_COMP = 'V-COMP';
  static const String GTB_OTP = "GTB_OTP";
  static const String ACCESS_OTP = "ACCESS_OTP";
  static const String VBV = "VBVSECURECODE";
}

class ValidatorUtils {
  static bool isCVVValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    var cvcValue = value.trim();
    bool validLength = cvcValue.length >= 3 && cvcValue.length <= 4;
    return !(!isWholeNumberPositive(cvcValue) || !validLength);
  }

  static bool isCardNumberValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    var number = CardUtils.getCleanedNumber(value.trim());

    //check if formattedNumber is empty or card isn't a whole positive number or isn't Luhn-valid
    return isWholeNumberPositive(number) && _isValidLuhnNumber(number);
  }

  static bool isAmountValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    double? number = double.tryParse(value.trim());
    return number != null && !number.isNegative && number > 0;
  }

  static bool isPhoneValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    // We are assuming no phone number is less than 3 characters
    return value.trim().length > 3;
  }

  static bool isAccountValid(String value) {
    if (value == null || value.trim().isEmpty) return false;
    return value.trim().length == 10;
  }

  static bool isBVNValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return value.trim().length == 11;
  }

  static bool isEmailValid(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    String p =
        '[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})';

    return RegExp(p).hasMatch(value);
  }

  static bool isWholeNumberPositive(String value) {
    if (value == null) {
      return false;
    }

    for (var i = 0; i < value.length; ++i) {
      if (!((value.codeUnitAt(i) ^ 0x30) <= 9)) {
        return false;
      }
    }

    return true;
  }

  static bool isUrlValid(String url) {
    final source =
        r'^(https?|ftp|file|http)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]';
    return RegExp(source).hasMatch(url);
  }

  /// Checks if the card has expired.
  /// Returns true if the card has expired; false otherwise
  static bool validExpiryDate(int? expiryMonth, int? expiryYear) {
    return !(expiryMonth == null || expiryYear == null) &&
        isNotExpired(expiryYear, expiryMonth);
  }

  static bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        CardUtils.convertYearTo4Digits(year) == now.year &&
            (month < now.month + 1);
  }

  static bool isValidMonth(int month) {
    return (month > 0) && (month < 13);
  }

  static bool hasYearPassed(int year) {
    int fourDigitsYear = CardUtils.convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the current year is more than card's year
    return fourDigitsYear < now.year;
  }

  static bool isNotExpired(int year, int month) {
    if (month > 12 || year > 2999) {
      return false;
    }
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  /// Validates the number against Luhn algorithm (https://en.wikipedia.org/wiki/Luhn_algorithm)
  ///
  /// [number]  - number to validate
  /// Returns true if the number is passes the verification.
  static bool _isValidLuhnNumber(String number) {
    int sum = 0;
    int length = number.trim().length;
    for (var i = 0; i < length; i++) {
      // get digits in reverse order
      var source = number[length - i - 1];

      // Check if character is digit before parsing it
      if (!((number.codeUnitAt(i) ^ 0x30) <= 9)) {
        return false;
      }
      int digit = int.parse(source);

      // if it's odd, multiply by 2
      if (i % 2 == 1) {
        digit *= 2;
      }
      sum += digit > 9 ? (digit - 9) : digit;
    }

    return sum % 10 == 0;
  }

  /// Validates that required the variables of [PayInitializer]
  /// are not null, negative or  empty
  static String? validateInitializer(PayInitializer init) {
    if (init.txRef.isEmpty) {
      return Strings.cannotBeNullOrEmpty("txRef");
    }
    if (init.currency.isEmpty) return Strings.cannotBeNullOrEmpty('currency');
    if (init.country.isEmpty) return Strings.cannotBeNullOrEmpty('country');
    if (init.narration.isEmpty) return Strings.cannotBeNull('narration');
    if (init.redirectUrl.isEmpty) return Strings.cannotBeNull('redirectUrl');
    if (init.firstname.isEmpty) return Strings.cannotBeNull('firstName');
    if (init.lastname.isEmpty) return Strings.cannotBeNull('lastName');
    return null;
  }
}

class CardUtils {
  static CardType getTypeForIIN(String value) {
    var input = getCleanedNumber(value);
    var number = input.trim();
    if (number.isEmpty) {
      return CardType.unknown;
    }

    if (number.startsWith(startingPatternVisa)) {
      return CardType.visa;
    } else if (number.startsWith(startingPatternMaster)) {
      return CardType.master;
    } else if (number.startsWith(startingPatternAmex)) {
      return CardType.amex;
    } else if (number.startsWith(startingPatternDiners)) {
      return CardType.diners;
    } else if (number.startsWith(startingPatternJCB)) {
      return CardType.jcb;
    } else if (number.startsWith(startingPatternVerve)) {
      return CardType.verve;
    } else if (number.startsWith(startingPatternDiscover)) {
      return CardType.discover;
    }
    return CardType.unknown;
  }

  /// Convert the two-digit year to four-digit year if necessary
  static int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  static String getCleanedNumber(String? text) {
    if (text == null) {
      return '';
    }
    RegExp regExp = new RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }

  static String getCardIcon(CardType type) {
    String img = "";
    switch (type) {
      case CardType.master:
        img = 'mastercard';
        break;
      case CardType.visa:
        img = 'visa';
        break;
      case CardType.verve:
        img = 'verve';
        break;
      case CardType.amex:
        img = 'bankcard';
        break;
      case CardType.discover:
        img = 'bankcard';
        break;
      case CardType.diners:
        img = 'bankcard';
        break;
      case CardType.jcb:
        img = 'bankcard';
        break;
      case CardType.unknown:
        img = 'bankcard';
        break;
    }
    return img;
  }

  static List<String> getExpiryDate(String value) {
    var split = value.split(new RegExp(r'(\/)'));
    return [split[0], split[1]];
  }
}

final startingPatternVisa = RegExp(r'[4]');
final startingPatternMaster = RegExp(
    r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))');
final startingPatternAmex = RegExp(r'((34)|(37))');
final startingPatternDiners = RegExp(r'((30[0-5])|(3[89])|(36)|(3095))');
final startingPatternJCB = RegExp(r'(352[89]|35[3-8][0-9])');
final startingPatternVerve = RegExp(r'((506(0|1))|(507(8|9))|(6500))');
final startingPatternDiscover = RegExp(r'((6[45])|(6011))');

String formatAmount(num amount) {
  return new NumberFormat.currency(name: '').format(amount);
}

String getEncryptedData(String str, String key) {
  var blockCipher = BlockCipher(TripleDESEngine(), key);
  return blockCipher.encodeB64(str);
}

/// Remove all line feed, carriage return and whitespace characters
String cleanUrl(String url) {
  return url.replaceAll(RegExp(r"[\n\r\s]+"), "");
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

putIfNotNull({required Map map, required key, required value}) {
  if (value == null || (value is String && value.isEmpty)) return;
  map[key] = value;
}

putIfTrue({required Map map, required key, required bool value}) {
  if (!value) return;
  map[key] = value;
}

printWrapped(Object text) {
  final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text.toString())
      .forEach((match) => debugPrint(match.group(0)));
}

bool isTxPending(String? message, String? status) {
  return message == 'Charge authorization data required' ||
      message == 'Charge initiated' ||
      message == "V-COMP" ||
      message == "AUTH_SUGGESTION" ||
      status == 'PENDING' ||
      status == 'SUCCESS-PENDING-VALIDATION';
}

Map<String, String> countriesISO = {
  "Afghanistan": "AF",
  "Åland Islands": "AX",
  "Albania": "AL",
  "Algeria": "DZ",
  "American Samoa": "AS",
  "Andorra": "AD",
  "Angola": "AO",
  "Anguilla": "AI",
  "Antarctica": "AQ",
  "Antigua and Barbuda": "AG",
  "Argentina": "AR",
  "Armenia": "AM",
  "Aruba": "AW",
  "Australia": "AU",
  "Austria": "AT",
  "Azerbaijan": "AZ",
  "Bahamas": "BS",
  "Bahrain": "BH",
  "Bangladesh": "BD",
  "Barbados": "BB",
  "Belarus": "BY",
  "Belgium": "BE",
  "Belize": "BZ",
  "Benin": "BJ",
  "Bermuda": "BM",
  "Bhutan": "BT",
  "Bolivia": "BO",
  "Bosnia and Herzegovina": "BA",
  "Botswana": "BW",
  "Bouvet Island": "BV",
  "Brazil": "BR",
  "British Indian Ocean Territory": "IO",
  "Brunei Darussalam": "BN",
  "Bulgaria": "BG",
  "Burkina Faso": "BF",
  "Burundi": "BI",
  "Cambodia": "KH",
  "Cameroon": "CM",
  "Canada": "CA",
  "Cape Verde": "CV",
  "Cayman Islands": "KY",
  "Central African Republic": "CF",
  "Chad": "TD",
  "Chile": "CL",
  "China": "CN",
  "Christmas Island": "CX",
  "Cocos (Keeling) Islands": "CC",
  "Colombia": "CO",
  "Comoros": "KM",
  "Congo": "CG",
  "Congo, The Democratic Republic of the": "CD",
  "Cook Islands": "CK",
  "Costa Rica": "CR",
  "Cote D'Ivoire": "CI",
  "Croatia": "HR",
  "Cuba": "CU",
  "Cyprus": "CY",
  "Czech Republic": "CZ",
  "Denmark": "DK",
  "Djibouti": "DJ",
  "Dominica": "DM",
  "Dominican Republic": "DO",
  "Ecuador": "EC",
  "Egypt": "EG",
  "El Salvador": "SV",
  "Equatorial Guinea": "GQ",
  "Eritrea": "ER",
  "Estonia": "EE",
  "Ethiopia": "ET",
  "Falkland Islands (Malvinas)": "FK",
  "Faroe Islands": "FO",
  "Fiji": "FJ",
  "Finland": "FI",
  "France": "FR",
  "French Guiana": "GF",
  "French Polynesia": "PF",
  "French Southern Territories": "TF",
  "Gabon": "GA",
  "Gambia": "GM",
  "Georgia": "GE",
  "Germany": "DE",
  "Ghana": "GH",
  "Gibraltar": "GI",
  "Greece": "GR",
  "Greenland": "GL",
  "Grenada": "GD",
  "Guadeloupe": "GP",
  "Guam": "GU",
  "Guatemala": "GT",
  "Guernsey": "GG",
  "Guinea": "GN",
  "Guinea-Bissau": "GW",
  "Guyana": "GY",
  "Haiti": "HT",
  "Heard Island and Mcdonald Islands": "HM",
  "Holy See (Vatican City State)": "VA",
  "Honduras": "HN",
  "Hong Kong": "HK",
  "Hungary": "HU",
  "Iceland": "IS",
  "India": "IN",
  "Indonesia": "ID",
  "Iran, Islamic Republic Of": "IR",
  "Iraq": "IQ",
  "Ireland": "IE",
  "Isle of Man": "IM",
  "Israel": "IL",
  "Italy": "IT",
  "Jamaica": "JM",
  "Japan": "JP",
  "Jersey": "JE",
  "Jordan": "JO",
  "Kazakhstan": "KZ",
  "Kenya": "KE",
  "Kiribati": "KI",
  "Korea, Democratic People'S Republic of": "KP",
  "Korea, Republic of": "KR",
  "Kuwait": "KW",
  "Kyrgyzstan": "KG",
  "Lao People'S Democratic Republic": "LA",
  "Latvia": "LV",
  "Lebanon": "LB",
  "Lesotho": "LS",
  "Liberia": "LR",
  "Libyan Arab Jamahiriya": "LY",
  "Liechtenstein": "LI",
  "Lithuania": "LT",
  "Luxembourg": "LU",
  "Macao": "MO",
  "Macedonia, The Former Yugoslav Republic of": "MK",
  "Madagascar": "MG",
  "Malawi": "MW",
  "Malaysia": "MY",
  "Maldives": "MV",
  "Mali": "ML",
  "Malta": "MT",
  "Marshall Islands": "MH",
  "Martinique": "MQ",
  "Mauritania": "MR",
  "Mauritius": "MU",
  "Mayotte": "YT",
  "Mexico": "MX",
  "Micronesia, Federated States of": "FM",
  "Moldova, Republic of": "MD",
  "Monaco": "MC",
  "Mongolia": "MN",
  "Montserrat": "MS",
  "Morocco": "MA",
  "Mozambique": "MZ",
  "Myanmar": "MM",
  "Namibia": "NA",
  "Nauru": "NR",
  "Nepal": "NP",
  "Netherlands": "NL",
  "Netherlands Antilles": "AN",
  "New Caledonia": "NC",
  "New Zealand": "NZ",
  "Nicaragua": "NI",
  "Niger": "NE",
  "Nigeria": "NG",
  "Niue": "NU",
  "Norfolk Island": "NF",
  "Northern Mariana Islands": "MP",
  "Norway": "NO",
  "Oman": "OM",
  "Pakistan": "PK",
  "Palau": "PW",
  "Palestinian Territory, Occupied": "PS",
  "Panama": "PA",
  "Papua New Guinea": "PG",
  "Paraguay": "PY",
  "Peru": "PE",
  "Philippines": "PH",
  "Pitcairn": "PN",
  "Poland": "PL",
  "Portugal": "PT",
  "Puerto Rico": "PR",
  "Qatar": "QA",
  "Reunion": "RE",
  "Romania": "RO",
  "Russian Federation": "RU",
  "RWANDA": "RW",
  "Saint Helena": "SH",
  "Saint Kitts and Nevis": "KN",
  "Saint Lucia": "LC",
  "Saint Pierre and Miquelon": "PM",
  "Saint Vincent and the Grenadines": "VC",
  "Samoa": "WS",
  "San Marino": "SM",
  "Sao Tome and Principe": "ST",
  "Saudi Arabia": "SA",
  "Senegal": "SN",
  "Serbia and Montenegro": "CS",
  "Seychelles": "SC",
  "Sierra Leone": "SL",
  "Singapore": "SG",
  "Slovakia": "SK",
  "Slovenia": "SI",
  "Solomon Islands": "SB",
  "Somalia": "SO",
  "South Africa": "ZA",
  "South Georgia and the South Sandwich Islands": "GS",
  "Spain": "ES",
  "Sri Lanka": "LK",
  "Sudan": "SD",
  "Suriname": "SR",
  "Svalbard and Jan Mayen": "SJ",
  "Swaziland": "SZ",
  "Sweden": "SE",
  "Switzerland": "CH",
  "Syrian Arab Republic": "SY",
  "Taiwan, Province of China": "TW",
  "Tajikistan": "TJ",
  "Tanzania, United Republic of": "TZ",
  "Thailand": "TH",
  "Timor-Leste": "TL",
  "Togo": "TG",
  "Tokelau": "TK",
  "Tonga": "TO",
  "Trinidad and Tobago": "TT",
  "Tunisia": "TN",
  "Turkey": "TR",
  "Turkmenistan": "TM",
  "Turks and Caicos Islands": "TC",
  "Tuvalu": "TV",
  "Uganda": "UG",
  "Ukraine": "UA",
  "United Arab Emirates": "AE",
  "United Kingdom": "GB",
  "United States": "US",
  "United States Minor Outlying Islands": "UM",
  "Uruguay": "UY",
  "Uzbekistan": "UZ",
  "Vanuatu": "VU",
  "Venezuela": "VE",
  "Viet Nam": "VN",
  "Virgin Islands, British": "VG",
  "Virgin Islands, U.S.": "VI",
  "Wallis and Futuna": "WF",
  "Western Sahara": "EH",
  "Yemen": "YE",
  "Zambia": "ZM",
  "Zimbabwe": "ZW"
};
