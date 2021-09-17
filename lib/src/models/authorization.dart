import 'package:nravepay/nravepay.dart';

class Authorization {
  String mode;
  String? pin;
  String? city;
  String? address;
  String? state;
  String? country;
  String? zipcode;
  String? endpoint;
  String redirect;
  List<String>? fields;
  String? validateInstructions;

  Authorization(
      {required this.mode,
      this.pin,
      this.city,
      this.address,
      this.state,
      this.country,
      this.endpoint,
      this.zipcode,
      this.fields,
      this.redirect = '',
      this.validateInstructions});

  Authorization.fromMap(Map map)
      : mode = map['mode'],
        redirect = map['redirect'],
        validateInstructions = map['validate_instructions'],
        fields = List.castFrom<dynamic, String>(map['fields']);

  Map<String, dynamic> toMap(Version version) {
    if (version == Version.v2) {
      return {
        'suggested_auth': mode.toUpperCase(),
        'billingzip': zipcode,
        'billingcity': city,
        'billingaddress': address,
        'billingstate': state,
        'billingcountry': country,
        'pin': pin
      };
    }
    return {
      'mode': mode.toLowerCase(),
      'pin': pin,
      'city': city,
      'address': address,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'endpoint': endpoint,
      'validate_instructions': validateInstructions
    };
  }
}
