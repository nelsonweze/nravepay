import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/base/base.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';

class ChoosePaymentCard extends StatefulWidget {
  final List<BankCard> cards;
  final String? defaultCardID;
  final PayInitializer? initializer;
  ChoosePaymentCard(
      {this.initializer, this.cards = const [], this.defaultCardID});
  @override
  _ChoosePaymentCardState createState() => _ChoosePaymentCardState();
}

class _ChoosePaymentCardState extends BaseState<ChoosePaymentCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  final _slideUpTween = Tween<Offset>(begin: Offset(0, 0.4), end: Offset.zero);
  String? defaultCardID;

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

  BankCard? _card;
  @override
  Widget buildChild(BuildContext context) {
    Widget child = Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 12),
        child: widget.cards.isNotEmpty
            ? Column(mainAxisSize: MainAxisSize.max, children: [
                ...List.generate(widget.cards.length, (index) {
                  if (widget.cards.isEmpty) {
                    return BankCardWidget(
                      placeholder: true,
                      onSelect: (item) {
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement((MaterialPageRoute(
                                builder: (context) => AddCardPage())));
                      },
                    );
                  }
                  var card = widget.cards[index];

                  return Column(
                    children: [
                      BankCardWidget(
                          card: card,
                          isDefault: card.id == defaultCardID,
                          onSelect: (item) {
                            setState(() {
                              _card = item;
                              defaultCardID = item?.id;
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
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.clear), onPressed: () => Navigator.pop(context)),
          title: Text(
            Setup.instance.chooseCardHeaderText,
          )),
      body: BlocBuilder<TransactionBloc, TransactionState>(
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
                      child: child,
                    ),
                  ),
                ));
          }),
      bottomNavigationBar: PaymentButton(
          disable: widget.cards.isEmpty,
          initializer: widget.initializer!.copyWith(
              token: (_card ??
                      (widget.cards.isNotEmpty ? widget.cards.first : null))
                  ?.token)),
    );
  }
}
