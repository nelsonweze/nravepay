import 'package:flutter/material.dart' hide State, ConnectionState;
import 'package:nwidgets/nwidgets.dart';
import '../payment.dart';
import '../widgets.payment.dart';

class ChoosePaymentCard extends StatefulWidget {
  final List<BankCard> cards;
  final String defaultCardID;
  final PayInitializer initializer;
  ChoosePaymentCard({this.initializer, this.cards, this.defaultCardID});
  @override
  _ChoosePaymentCardState createState() => _ChoosePaymentCardState();
}

class _ChoosePaymentCardState extends BaseState<ChoosePaymentCard>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  var _slideUpTween = Tween<Offset>(begin: Offset(0, 0.4), end: Offset.zero);
  String defaultCardID;

  @override
  void initState() {
    super.initState();
    defaultCardID = widget.defaultCardID;
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

  BankCard _card;
  @override
  buildChild(BuildContext context) {
    Widget child = Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 12),
        child: widget.cards.isValid()
            ? Column(mainAxisSize: MainAxisSize.max, children: [
                ...List.generate(widget.cards.length, (index) {
                  if (widget.cards.isEmpty)
                    return BankCardWidget(
                      placeholder: true,
                      onSelect: (item) {
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement((MaterialPageRoute(
                                builder: (context) => AddCardPage())));
                      },
                    );
                  var card = widget.cards[index];

                  return Column(
                    children: [
                      BankCardWidget(
                          card: card,
                          isDefault: card.id == defaultCardID,
                          onSelect: (item) {
                            setState(() {
                              _card = item;
                              defaultCardID = item.id;
                            });
                          }),
                      if (index == widget.cards.length - 1)
                        BankCardWidget(
                          placeholder: true,
                          onSelect: (item) {
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacement((MaterialPageRoute(
                                    builder: (context) => AddCardPage())));
                          },
                        )
                    ],
                  );
                }),
              ])
            : BankCardWidget(
                placeholder: true,
                onSelect: (item) {
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                      (MaterialPageRoute(builder: (context) => AddCardPage())));
                },
              ));

    return Scaffold(
      appBar: NAppBar(showCancel: true, title: 'Payment'),
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
      bottomNavigationBar: PaymentButton(
          disable: !widget.cards.isValid(),
          initializer: widget.initializer.copyWith(
              token: (_card ??
                      (widget.cards.isValid() ? widget.cards.first : null))
                  ?.embedtoken)),
    );
  }
}
