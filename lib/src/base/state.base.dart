import 'package:flutter/material.dart';
import 'package:nwidgets/nwidgets.dart';
import '../models.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool isProcessing = false;
  String confirmationMessage = 'Do you want to cancel payment?';
  bool alwaysPop = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context);

  Future<bool> _onWillPop() async {
    print('exit');
    if (isProcessing) {
      return false;
    }

    var returnValue = getPopReturnValue();

    if (alwaysPop ||
        (returnValue != null &&
            (returnValue is HttpResult &&
                returnValue.status == HttpStatus.success))) {
      Navigator.of(context).pop(returnValue);
      return false;
    }

    var text = Text(confirmationMessage);

    var dialog = PlatformAlertDialog(
      content: text,
      actions: <Widget>[
        PlatformDialogAction(
            child: Text(
              'NO',
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Pops the confirmation dialog but not the page.
            }),
        PlatformDialogAction(
            child: Text('YES'),
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Returning true to _onWillPop will pop again.
            })
      ],
    );

    bool exit = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => dialog,
        ) ??
        false;
    if (exit) {
      Navigator.of(context).pop(returnValue);
    }
    return false;
  }

  void onCancelPress() async {
    bool close = await _onWillPop();
    if (close) {
      Navigator.of(context).pop(await getPopReturnValue());
    }
  }

  getPopReturnValue() {}
}
