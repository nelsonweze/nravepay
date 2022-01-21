import 'models.dart';

class BankAccount {
  final String accountName;
  final Bank? bank;
  final String accountNumber;

  BankAccount({this.accountName = '', this.bank, this.accountNumber = ''});

  factory BankAccount.fromMap(Map map) {
    return BankAccount(
      accountName: map['accountName'],
      accountNumber: map['accountNumber'],
      bank: Bank.fromJson(map['bank']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bank': {'bankname': bank?.name, 'bankcode': bank?.code}
    };
  }
}