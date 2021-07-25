export 'authorization.dart';
export 'bankcard.model.dart';
export 'charge_request.model.dart';
export 'charge_response.model.dart';
export 'http.model.dart';
export 'merchant.model.dart';
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

  bool showBVNField() =>
      code == '033'; // 033 is code for UNITED BANK FOR AFRICA PLC

  bool showDOBField() =>
      code == '057' || code == '033'; // 057 is for ZENITH BANK PLC

  bool showAccountNumField() => !internetBanking;
}



