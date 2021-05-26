import 'package:flutter/material.dart' hide ConnectionState;
import 'package:nravepay/src/blocs/connection.bloc.dart';
import '../helpers.dart';
import '../models.dart';
import '../util.payment.dart';
import '../widgets.payment.dart';
import 'manager.base.dart';

abstract class BasePaymentPage extends StatefulWidget {
  final BaseTransactionManager transactionManager;

  BasePaymentPage({required this.transactionManager});
}

abstract class BasePaymentPageState<T extends BasePaymentPage> extends State<T>
    with TickerProviderStateMixin {
  var formKey = GlobalKey<FormState>();
  final initializer = NRavePayRepository.instance.initializer;
  final _connectionBloc = ConnectionBloc.instance;

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
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = buildWidget(context);
    return FadeTransition(
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
    );
  }

  Widget buildMainFields([data]) {
    var fields = <Widget>[];

    Widget topWidget = buildTopWidget();

    Widget payButton = Container(
        alignment: Alignment.bottomCenter,
        child: PaymentButton(
            initializer: initializer, onPressed: _validateInputs));
    return Form(
      key: formKey,
      autovalidateMode: _autoValidate,
      child: Column(
          children: fields
            ..insert(0, topWidget)
            ..addAll(buildLocalFields(data))
            ..add(SizedBox(
              height: 60,
            ))
            ..add(payButton)),
    );
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

  List<Widget> buildLocalFields([data]);

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

  @mustCallSuper
  onFormValidated() {
    widget.transactionManager.processTransaction(payload);
  }

  Widget buildWidget(BuildContext context) => Column(
        children: <Widget>[
          buildMainFields(),
        ],
      );

  FocusNode getNextFocusNode();

  Widget buildTopWidget() => SizedBox();

  AutovalidateMode get autoValidate => _autoValidate;

  setDataState(ConnectionState state) => _connectionBloc.setState(state);
}
