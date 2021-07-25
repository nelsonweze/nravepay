import 'package:flutter/material.dart' hide ConnectionState, State;
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/utils/utils.dart';
import '../pages/choose_card.payment.dart';

class PayManager {
  PayManager._internal();

  static final PayManager _manager = PayManager._internal();

  factory PayManager() {
    return _manager;
  }

  Future<HttpResult> prompt({
    required BuildContext context,
    required PayInitializer initializer,
  }) async {
    print('starting payment');

    var repository = NRavePayRepository.instance;
    // Validate the initializer params
    var error = ValidatorUtils.validateInitializer(initializer);

    if (error != null) {
      print(error);
      return HttpResult(
          status: HttpStatus.error,
          rawResponse: {'error': error},
          message: error);
    }
    NRavePayRepository.update(initializer);
    var result =
        await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) => ChoosePaymentCard(
        initializer: initializer,
        cards: repository.cards ?? [],
        defaultCardID: repository.defaultCardId,
      ),
    ));
    // Return a cancelled response if result is null
    return result ?? HttpResult(status: HttpStatus.cancelled);
  }
}