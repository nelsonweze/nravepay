export 'authorization.dart';
export 'bankcard.model.dart';
export 'charge_request.model.dart';
export 'charge_response.model.dart';
export 'http.model.dart';
export 'meta.model.dart';
export 'payinitializer.dart';
export 'payload.model.dart';
export 'requery_response.model.dart';

class PaymentType {
  static const String account = 'account';
  // static const String ussd = 'ussd';
  static const String card = 'card';
}

class SubAccount {
  final String id;

  SubAccount(this.id);

  Map<String, String> toMap() {
    return {'id': id};
  }
}

class Bank {
  final String name;
  final String code;
  final bool internetBanking;

  Bank.fromJson(Map map)
      : name = map['bankname'],
        code = map['bankcode'],
        internetBanking = map['internetbanking'];

  Map<String, dynamic> toJson() {
    return {
      'bankname': name,
      'bankcode': code,
      'internetbanking': internetBanking
    };
  }

  bool showBVNField() =>
      code == '033'; // 033 is code for UNITED BANK FOR AFRICA PLC

  bool showDOBField() =>
      code == '057' || code == '033'; // 057 is for ZENITH BANK PLC

  bool showAccountNumField() => !internetBanking;
}

enum SplitType { percentage, flat }

class Merchant {
  String accountBank;
  String accountNumber;
  String businessName;
  String? businessEmail;
  String? businessContact;
  String businessMobile;
  String country;
  String? merchantId;
  SplitType splitType;
  double splitValue;
  String? secretKey;
  List<Map<String, dynamic>>? meta;

  Merchant(
      {required this.accountBank,
      required this.accountNumber,
      required this.businessName,
      required this.businessMobile,
      required this.country,
      this.businessContact,
      this.businessEmail,
      this.merchantId,
      this.splitType = SplitType.percentage,
      this.meta,
      this.secretKey,
      this.splitValue = 0.0});

  Map<String, dynamic> toMap() {
    return {
      'account_bank': accountBank,
      'account_number': accountNumber,
      'business_name': businessName,
      'business_email': businessEmail,
      'business_contact': businessContact,
      'business_contact_mobile': businessMobile,
      'business_mobile': businessMobile,
      'split_type': splitType.toString().split('.').last,
      'split_value': splitValue,
      'country': country,
      'seckey': secretKey,
      'meta': meta
    };
  }
}
