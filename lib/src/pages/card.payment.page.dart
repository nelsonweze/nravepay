import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_svg/flutter_svg.dart';
import '../payment.dart' hide State;

class CardPaymentWidget extends StatefulWidget {
  final BaseTransactionManager manager;
  CardPaymentWidget({required this.manager});
  @override
  _CardPaymentWidgetState createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends State<CardPaymentWidget>
    with TickerProviderStateMixin {
  var formKey = GlobalKey<FormState>();
  final initializer = NRavePayRepository.instance.initializer;
  final _connectionBloc = ConnectionBloc.instance;
  late TextEditingController numberController;
  CardType cardType = CardType.unknown;
  var _numberFocusNode = FocusNode();
  var _expiryFocusNode = FocusNode();
  var _cvvFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation _animation;
  var _slideInTween = Tween<Offset>(begin: Offset(0, -0.5), end: Offset.zero);
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  late Payload payload;

  @override
  void initState() {
    payload = Payload.fromInitializer(initializer);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_animationController),
        curve: Curves.fastOutSlowIn);
    _animationController.forward();
    numberController = new TextEditingController();
    numberController.addListener(_setCardTypeFrmNumber);
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
    String input = CardUtils.getCleanedNumber(numberController.text);
    setState(() {
      cardType = CardUtils.getTypeForIIN(input);
    });
  }

  swapFocus(FocusNode oldFocus, [FocusNode? newFocus]) {
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
                payload.expiryMonth = expiryDate[0];
                payload.expiryYear = expiryDate[1];
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
                onSaved: (value) => payload.cvv = value!),
          ),
        ],
      ),
      Row(children: [
        Checkbox(
            value: widget.manager.saveCard,
            onChanged: (val) {
              setState(() {
                widget.manager.saveCard = val ?? false;
              });
            }),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Save card'),
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
      return Strings.pay;
    }
    return '${Strings.pay} ${initializer.currency.toUpperCase()} ${formatAmount(initializer.amount)}';
  }

  _validateInputs() {
    var formState = formKey.currentState!;
    if (!formState.validate()) {
      setState(() => _autoValidate = AutovalidateMode.always);
      return;
    }
    formState.save();
    FocusScope.of(context).unfocus();
    onFormValidated();
  }

  onFormValidated() {
    widget.manager.processTransaction(payload);
  }

  FocusNode getNextFocusNode() => _numberFocusNode;

  Widget buildTopWidget() => SizedBox(height: 20);

  AutovalidateMode get autoValidate => _autoValidate;

  setDataState(ConnectionState state) => _connectionBloc.setState(state);

  @override
  Widget build(BuildContext context) {
    var child = Form(
      key: formKey,
      autovalidateMode: _autoValidate,
      child: Column(
          children: []
            ..insert(0, buildTopWidget())
            ..addAll(buildLocalFields())
            ..add(SizedBox(
              height: 60,
            ))
            ..add(Container(
                alignment: Alignment.bottomCenter,
                child: PaymentButton(
                    initializer: initializer, onPressed: _validateInputs)))),
    );
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(widget.manager.paymentResult);
        return true;
      },
      child: FadeTransition(
        opacity: _animation as Animation<double>,
        child: SlideTransition(
          position: _slideInTween.animate(_animation as Animation<double>),
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: StreamBuilder<ConnectionState>(
                  stream: ConnectionBloc.instance.stream,
                  builder: (context, snapshot) {
                    return snapshot.hasData &&
                            snapshot.data == ConnectionState.waiting
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
