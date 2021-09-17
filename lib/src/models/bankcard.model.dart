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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'last_4digits': last4digits,
      'expiry': expiry,
      'country': country,
      'first_6digits': first6digits,
      'issuer': issuer,
      'type': type
    };
  }
}
