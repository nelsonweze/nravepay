import 'package:nravepay/nravepay.dart';

class Authorization {
  /// This is the auth model of the card to use when validating,
  /// it is returned in the initiate charge call as authorization.mode
  String mode;

  /// This is the card's pin. Required when the suggested auth mode is PIN
  String? pin;

  /// This is the city in the card's billing details.
  /// It is required when the suggested auth mode is avs_noauth
  String? city;

  /// This is the cards billing address.
  ///  It is required when the suggested auth mode is avs_noauth
  String? address;

  /// This is the card issuing state.
  /// It is required when the suggested auth mode is avs_noauth
  String? state;

  /// This is the cards issuing country. It is required when the suggested auth mode is avs_noauth
  String? country;

  /// This is cards billing address zipcod.
  /// It is required when the suggested auth mode is avs_noauth
  String? zipcode;

  /// endpoint
  String? endpoint;

  /// The redirect url when payment is completed
  String redirect;

  /// The missing required billing fields for [Version.v3]
  List<String>? fields;

  /// This is the auth model of the card to use when validating,
  /// it is returned in the initiate charge call as authorization.mode
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

  /// Parses a json object to [Authorization]
  Authorization.fromMap(Map map)
      : mode = map['mode'],
        redirect = map['redirect'],
        validateInstructions = map['validate_instructions'],
        fields = List.castFrom<dynamic, String>(map['fields']);

  /// converts a [Authorization] to JSON object
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
