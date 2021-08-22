import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nravepay/nravepay.dart';

class BankCardWidget extends StatelessWidget {
  final BankCard? card;
  final bool placeholder;
  final bool isDefault;
  final Function(BankCard?) onSelect;
  BankCardWidget(
      {this.card,
      this.placeholder = false,
      required this.onSelect,
      this.isDefault = false});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => onSelect(card),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!placeholder)
              SvgPicture.asset(
                'assets/${card!.type.toLowerCase()}.svg',
                package: 'nravepay',
                width: 50,
                height: 38,
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
              )
          ],
        ),
        trailing: isDefault
            ? Icon(Icons.check_circle)
            : Container(
                height: 0,
                width: 0,
              ),
        title: !placeholder
            ? Row(
                children: [
                  Text(
                    card!.type.toUpperCase(),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(' •••• ${card!.last4digits}',
                      style: Theme.of(context).textTheme.subtitle2),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Add new card',
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      fontSize: 13, color: Theme.of(context).accentColor),
                ),
              ),
        subtitle: !placeholder ? Text('${card!.expiry}') : null);
  }
}
