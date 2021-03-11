import 'package:flutter/material.dart' hide State, ConnectionState;
import 'blocs/connection.bloc.dart';
import 'blocs/transaction.bloc.dart';
import 'pages/choose_card.payment.dart';
import 'paymanager.dart';
import 'models.dart';
import 'pages/card.payment.page.dart';
import 'payment.dart';
import 'util.payment.dart';

class PaymentWidget extends StatefulWidget {
  @override
  _PaymentWidgetState createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends BaseState<PaymentWidget>
    with TickerProviderStateMixin {
  final PayInitializer _initializer = Repository.instance.initializer;

  List<_Item> _items;

  @override
  bool get alwaysPop => true;

  @override
  void initState() {
    _items = _getItems();
    super.initState();
  }

  @override
  void dispose() {
    ConnectionBloc.instance.dispose();
    TransactionBloc.instance.dispose();
    super.dispose();
  }

  @override
  Widget buildChild(BuildContext context) {
    var column = Column(
      children: _items.map((item) {
        var index = _items.indexOf(item);
        return buildItemHeader(index);
      }).toList(),
    );

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: EdgeInsets.all(20),
          child: Text(
            'Payment Method',
            style: Theme.of(context).textTheme.subtitle2,
            textAlign: TextAlign.center,
          ),
        ),
        column
      ]),
    );
  }

  List<_Item> _getItems() {
    var items = <_Item>[];
    items
      ..add(
        _Item(
          Strings.card,
          Icons.credit_card,
          ChoosePaymentCard(
            initializer: _initializer,
          ),
        ),
      );
    if (Env.test)
      items
        ..add(_Item(
          Strings.account,
          Icons.account_balance_wallet,
          CardPaymentWidget(
            manager: CardTransactionManager(
              context: context,
            ),
          ),
        ));
    return items;
  }

  Widget buildItemHeader(int index) {
    var item = _items[index];
    return Container(
      width: double.infinity,
      child: ListTile(
        title: Row(
          children: <Widget>[
            Icon(
              item.icon,
              size: 24,
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(child: Text('Pay with ${item.title}')),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        onTap: () {
          return Navigator.of(context, rootNavigator: true).pushReplacement(
              (MaterialPageRoute(builder: (context) => item.content)));
        },
      ),
    );
  }

  @override
  getPopReturnValue() {
    return HttpResult(status: HttpStatus.left, message: Strings.youCancelled);
  }

  _onTransactionComplete(HttpResult result) =>
      Navigator.of(context).pop(result);
}

class _Item {
  final Widget content;
  final String title;
  final IconData icon;

  _Item(this.title, this.icon, this.content);
}
