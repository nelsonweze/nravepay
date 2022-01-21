import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nravepay/nravepay.dart';
import 'package:nravepay/src/paymanager/card.paymanager.dart';
import 'package:nravepay/src/utils/data.util.dart';

class PaymentButton extends StatelessWidget {
  final PayInitializer? initializer;
  final VoidCallback? onPressed;
  final bool disable;
  PaymentButton({this.initializer, this.onPressed, this.disable = false});

  @override
  Widget build(BuildContext context) {
    var onPress = disable
        ? null
        : onPressed ??
            () {
              CardTransactionManager(
                navigatorState: Navigator.of(context),
              ).processTransaction(Payload.fromInitializer(initializer!));
            };
    return SafeArea(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(12.0),
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        child: Column(
          children: [
            initializer!.buttonBuilder?.call(initializer!.amount, onPress) ??
                Container(
                    margin: const EdgeInsets.all(
                      20.0,
                    ),
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPress,
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Setup.instance.borderRadius)))),
                      child: Text(
                          '${Setup.instance.payText}  ${getCurrency(initializer!.currency)} ${initializer!.amount}'),
                    )),
            if (Setup.instance.showFlutterwaveBadge)
              Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Setup.instance.strings.securedBy),
                      SvgPicture.asset(
                        'assets/flutterwave_logo.svg',
                        package: 'nravepay',
                        width: 24,
                        height: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(Setup.instance.strings.flutterwave),
                      )
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}
