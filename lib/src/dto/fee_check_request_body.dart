import 'package:equatable/equatable.dart';
import '../payment.dart';

class FeeCheckRequestBody extends Equatable {
  final String? amount;
  final String? pBFPubKey;
  final String card6;
  final String? currency;
  final String pType;

  FeeCheckRequestBody({
    this.amount,
    this.pBFPubKey,
    this.pType = '',
    this.card6 = '',
    this.currency,
  });

  FeeCheckRequestBody.fromPayload(Payload p)
      : this.amount = p.amount,
        this.pBFPubKey = p.pbfPubKey,
        this.currency = p.currency,
        this.pType = '',
        this.card6 = p.cardNo.isNotEmpty ? p.cardBIN : p.cardNo.substring(0, 6);

  Map<String, dynamic> toJson() {
    var json = {
      "amount": amount,
      "PBFPubKey": pBFPubKey,
      "currency": currency,
    };
    if (card6.isNotEmpty) {
      json["card6"] = card6;
    }
    if (pType.isNotEmpty) {
      json["ptype"] = pType;
    }
    return json;
  }

  @override
  List<Object?> get props => [
        amount,
        pBFPubKey,
        pType,
        card6,
        currency,
      ];
}
