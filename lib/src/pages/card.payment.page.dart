import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import 'package:nravepay/src/paymanager/card.paymanager.dart';
import 'package:websafe_svg/websafe_svg.dart';

class CardPaymentWidget extends StatefulWidget {
  @override
  _CardPaymentWidgetState createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends State<CardPaymentWidget>
    with TickerProviderStateMixin {
  var formKey = GlobalKey<FormState>();
  final initializer = NRavePayRepository.instance.initializer;
  late TextEditingController numberController;
  CardType cardType = CardType.unknown;
  final _numberFocusNode = FocusNode();
  final _expiryFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation _animation;
  final _slideInTween = Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero);
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  late Payload payload;
  late BaseTransactionManager manager;

  @override
  void initState() {
    payload = Payload.fromInitializer(initializer);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_animationController),
        curve: Curves.fastOutSlowIn);
    _animationController.forward();
    numberController = TextEditingController();
    numberController.addListener(_setCardTypeFrmNumber);
    manager = CardTransactionManager(navigatorState: Navigator.of(context));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    numberController.removeListener(_setCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _setCardTypeFrmNumber() {
    var input = CardUtils.getCleanedNumber(numberController.text);
    setState(() {
      cardType = CardUtils.getTypeForIIN(input);
    });
  }

  void swapFocus(FocusNode oldFocus, [FocusNode? newFocus]) {
    oldFocus.unfocus();
    if (newFocus != null) {
      FocusScope.of(context).requestFocus(newFocus);
    } else {
      // The user has reached the end of the form
      _validateInputs();
    }
  }

  List<Widget> buildLocalFields() {
    return [
      CardNumberField(
        controller: numberController,
        focusNode: _numberFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) =>
            swapFocus(_numberFocusNode, _expiryFocusNode),
        onSaved: (value) =>
            payload.cardNumber = CardUtils.getCleanedNumber(value),
        suffix: WebsafeSvg.asset(
          'assets/${CardUtils.getCardIcon(cardType)}.svg',
          package: 'nravepay',
          width: 30,
          height: 15,
        ),
      ),
      SizedBox(height: 8),
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
                var expiryDate = CardUtils.getExpiryDate(value!);
                payload.expiryMonth = expiryDate[0];
                payload.expiryYear = expiryDate[1];
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: CVVField(
                focusNode: _cvvFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => swapFocus(
                      _cvvFocusNode,
                    ),
                onSaved: (value) => payload.cvv = value!),
          ),
        ],
      ),
      if (Setup.instance.allowSaveCard)
        Row(children: [
          Checkbox(
              value: manager.saveCard,
              onChanged: (val) {
                setState(() {
                  manager.saveCard = val ?? false;
                });
              }),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(Setup.instance.saveCardText),
          )
        ]),
    ];
  }

  String? getPaymentText() {
    if (initializer.payButtonText != null &&
        initializer.payButtonText!.isNotEmpty) {
      return initializer.payButtonText;
    }
    if (initializer.amount == 0.0 || initializer.amount.isNegative) {
      return Setup.instance.payText;
    }
    return '${Setup.instance.payText} ${initializer.currency.toUpperCase()} ${formatAmount(initializer.amount)}';
  }

  void _validateInputs() {
    var formState = formKey.currentState!;
    if (!formState.validate()) {
      setState(() => _autoValidate = AutovalidateMode.always);
      return;
    }
    formState.save();
    FocusScope.of(context).unfocus();
    onFormValidated();
  }

  void onFormValidated() {
    manager.processTransaction(payload);
  }

  FocusNode getNextFocusNode() => _numberFocusNode;
  Widget buildTopWidget() => SizedBox(height: 20);
  AutovalidateMode get autoValidate => _autoValidate;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(manager.paymentResult);
        return true;
      },
      child: FadeTransition(
        opacity: _animation as Animation<double>,
        child: SlideTransition(
          position: _slideInTween.animate(_animation as Animation<double>),
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  bloc: TransactionBloc.instance,
                  builder: (context, state) {
                    var child = Form(
                      key: formKey,
                      autovalidateMode: _autoValidate,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildTopWidget(),
                            ...buildLocalFields(),
                            SizedBox(
                              height: 60,
                            ),
                            Container(
                                alignment: Alignment.bottomCenter,
                                child: PaymentButton(
                                    initializer: initializer,
                                    onPressed: _validateInputs))
                          ]),
                    );
                    return state.loadingState == LoadingState.active
                        ? IgnorePointer(
                            child: child,
                          )
                        : child;
                  },
                )),
          ),
        ),
      ),
    );
  }
}
