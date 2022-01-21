import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import 'card.payment.page.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends BaseState<AddCardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  final _slideUpTween = Tween<Offset>(begin: Offset(0, 0.4), end: Offset.zero);

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = CurvedAnimation(
        parent: Tween<double>(begin: 0, end: 1).animate(_animationController),
        curve: Curves.fastOutSlowIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Setup.instance.addCardHeaderText,
        ),
      ),
      body: Theme(
        data: Theme.of(context)
            .copyWith(inputDecorationTheme: inputDecoration(context)),
        child: BlocBuilder<TransactionBloc, TransactionState>(
            bloc: TransactionBloc.instance,
            builder: (context, state) {
              return OverlayLoading(
                active: state.loadingState == LoadingState.active,
                child: AnimatedSize(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.linear,
                  child: FadeTransition(
                    opacity: _animation as Animation<double>,
                    child: SlideTransition(
                      position: _slideUpTween
                          .animate(_animation as Animation<double>),
                      child: SingleChildScrollView(
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                          alignment: Alignment.topCenter,
                          child: BlocBuilder<TransactionBloc, TransactionState>(
                            bloc: TransactionBloc.instance,
                            builder: (_, state) {
                              late Widget w;
                              switch (state.auth) {
                                case AuthMode.initial:
                                  w = CardPaymentWidget();
                                  break;
                                case AuthMode.pin:
                                  w = PinWidget(
                                    onPinInputted: state.callback,
                                  );
                                  break;
                                case AuthMode.otp:
                                  w = OtpWidget(
                                    onPinInputted: state.callback,
                                    message: state.data,
                                  );
                                  break;
                                case AuthMode.avsSecure:
                                  w = BillingWidget(
                                      onBillingInputted: state.callback);
                              }
                              return w;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
