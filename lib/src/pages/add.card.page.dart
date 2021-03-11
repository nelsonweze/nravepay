import 'package:flutter/material.dart' hide State, ConnectionState;
import 'package:nwidgets/nwidgets.dart';
import '../paymanager.dart';
import '../payment.dart';
import 'card.payment.page.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends BaseState<AddCardPage>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  var _slideUpTween = Tween<Offset>(begin: Offset(0, 0.4), end: Offset.zero);

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
    var column = CardPaymentWidget(
      manager: CardTransactionManager(
        context: context,
      ),
    );

    Widget child = SingleChildScrollView(
      child: AnimatedSize(
        duration: Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.topCenter,
        vsync: this,
        child: StreamBuilder<TransactionState>(
          stream: TransactionBloc.instance.stream,
          builder: (_, snapshot) {
            var transactionState = snapshot.data;
            Widget w;
            if (!snapshot.hasData) {
              w = column;
            } else {
              switch (transactionState.state) {
                case State.initial:
                  w = column;
                  break;
                case State.pin:
                  w = PinWidget(
                    onPinInputted: transactionState.callback,
                  );
                  break;
                case State.otp:
                  w = OtpWidget(
                    onPinInputted: transactionState.callback,
                    message: transactionState.data,
                  );
                  break;
                case State.avsSecure:
                  w = BillingWidget(
                      onBillingInputted: transactionState.callback);
              }
            }
            return w;
          },
        ),
      ),
    );

    return Scaffold(
      appBar: NAppBar(
        title: 'Credit Card',
      ),
      body: AnimatedSize(
        vsync: this,
        duration: Duration(milliseconds: 400),
        curve: Curves.linear,
        child: FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: _slideUpTween.animate(_animation),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Positioned(
                  child: child,
                ),
                StreamBuilder<ConnectionState>(
                  stream: ConnectionBloc.instance.stream,
                  builder: (context, snapshot) {
                    return snapshot.hasData &&
                            snapshot.data == ConnectionState.waiting
                        ? OverlayLoaderWidget()
                        : SizedBox();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
