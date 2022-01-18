import 'package:flutter/material.dart';
import 'package:nravepay/src/blocs/transaction.bloc.dart';
import 'package:nravepay/src/widgets/dialog.dart';
import '../../nravepay.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context);

  Future<bool> _onWillPop() async {
    if (TransactionBloc.instance.state.loadingState == LoadingState.active) {
      return false;
    }
    if (TransactionBloc.instance.state.auth != AuthMode.initial) {
      var exit = await showDialog<bool>(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: Text(Setup.instance.strings.cancelPayment),
              content: Text(Setup.instance.strings.wantToCancel),
              actions: [
                PlatformDialogAction(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(Setup.instance.strings.no),
                ),
                PlatformDialogAction(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(Setup.instance.strings.yes),
                )
              ],
            ),
          ) ??
          false;
      return exit;
    }
    return true;
  }
}
