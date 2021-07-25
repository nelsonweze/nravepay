import 'package:nravepay/nravepay.dart';

class Merchant {
  String accountBank;
  String accountNumber;
  String businessName;
  String? businessEmail;
  String? businessContact;
  String businessMobile;
  String country;
  String? merchantId;
  String splitType;
  String splitValue;
  String? secretKey;
  List<Map<String, dynamic>>? meta;

  Merchant(
      {required this.accountBank,
      required this.accountNumber,
      required this.businessName,
      required this.businessMobile,
      this.businessContact,
      this.businessEmail,
      required this.country,
      this.merchantId,
      this.splitType = 'percentage',
      this.meta,
      this.secretKey,
      this.splitValue = '0.1'});

  Map<String, dynamic> toMap() {
    return {
      'account_bank': accountBank,
      'account_number': accountNumber,
      'business_name': businessName,
      'business_email': businessEmail,
      'business_contact': businessContact,
      'business_contact_mobile': businessMobile,
      'business_mobile': businessMobile,
      'split_type': splitType,
      'split_value': splitValue,
      'country': countriesISO[country],
      'seckey': secretKey,
      'meta': meta
    };
  }
}