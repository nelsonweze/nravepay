import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_svg/flutter_svg.dart';
import '../paymanager.dart';
import '../payment.dart';

class CardPaymentWidget extends BasePaymentPage {
  CardPaymentWidget({required CardTransactionManager manager})
      : super(transactionManager: manager);

  @override
  _CardPaymentWidgetState createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends BasePaymentPageState<CardPaymentWidget> {
  TextEditingController? numberController;
  CardType cardType = CardType.unknown;
  var _numberFocusNode = FocusNode();
  var _expiryFocusNode = FocusNode();
  var _cvvFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    numberController = new TextEditingController();
    numberController!.addListener(_setCardTypeFrmNumber);
  }

  @override
  void dispose() {
    numberController!.removeListener(_setCardTypeFrmNumber);
    numberController!.dispose();
    super.dispose();
  }

  @override
  List<Widget> buildLocalFields([data]) {
    return [
      CardNumberField(
        controller: numberController,
        focusNode: _numberFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            swapFocus(_numberFocusNode, _expiryFocusNode),
        onSaved: (value) => payload!.cardNo = CardUtils.getCleanedNumber(value),
        suffix: SvgPicture.asset(
          'assets/${CardUtils.getCardIcon(cardType)}.svg',
          package: 'nravepay',
          width: 30,
          height: 15,
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ExpiryDateField(
              focusNode: _expiryFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) =>
                  swapFocus(_expiryFocusNode, _cvvFocusNode),
              onSaved: (value) {
                List<String> expiryDate = CardUtils.getExpiryDate(value!);
                payload!.expiryMonth = expiryDate[0];
                payload!.expiryYear = expiryDate[1];
              },
            ),
          ),
          Expanded(
            child: CVVField(
                focusNode: _cvvFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => swapFocus(
                      _cvvFocusNode,
                    ),
                onSaved: (value) => payload!.cvv = value),
          ),
        ],
      ),
      Row(children: [
        Checkbox(
            checkColor: Theme.of(context).accentColor,
            value: widget.transactionManager.saveCard,
            onChanged: (val) {
              setState(() {
                widget.transactionManager.saveCard = val;
              });
            }),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Save credit card'),
        )
      ]),
    ];
  }

  @override
  Widget buildTopWidget() {
    return SizedBox(
      height: 20,
    );
  }

  void _setCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController!.text);
    setState(() {
      cardType = CardUtils.getTypeForIIN(input);
    });
  }

  @override
  FocusNode getNextFocusNode() => _numberFocusNode;
}
