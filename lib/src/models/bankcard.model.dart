class BankCard {
  String id;
  String token;
  String last4digits;
  String first6digits;
  String expiry;
  String issuer;
  String type;
  String? country;

  BankCard(
      {required this.issuer,
      required this.token,
      required this.expiry,
      required this.last4digits,
      required this.id,
      this.first6digits = '',
      this.country,
      this.type = 'bankcard'});

  /// This is used to parse the card object returned
  /// from the charge response.
  /// Use [BankCard.fromJson] to parse saved card object
  BankCard.fromMap(Map map, bool isV2)
      : id = map['id'] ??
            "${DateTime.now().microsecondsSinceEpoch}_${map["last_4digits"]}",
        token = isV2
            ? map['card_tokens'] != null
                ? (map['card_tokens'] as List).first['embedtoken']
                : null
            : map['token'],
        first6digits = isV2 ? map['cardBIN'] : map['first_6digits'],
        last4digits = isV2 ? map['last4digits'] : map['last_4digits'],
        expiry =
            isV2 ? "${map["expirymonth"]}/${map["expiryyear"]}" : map['expiry'],
        type = map['type'],
        country = map['country'],
        issuer = isV2 ? map['brand'] : map['issuer'];

/// parses saved card object to [BankCard]
  BankCard.fromJson(Map json)
      : id = json['id'],
        token = json['token'],
        last4digits = json['last_4digits'],
        expiry = json['expiry'],
        country = json['country'],
        first6digits = json['first_6digits'],
        issuer = json['issuer'],
        type = json['type'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'last_4digits': last4digits,
      'expiry': expiry,
      'country': country,
      'first_6digits': first6digits,
      'issuer': issuer,
      'type': type,
    };
  }
}
