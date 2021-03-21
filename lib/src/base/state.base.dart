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

    bool exit = await showNAlert(context, 'Cancel Payment', confirmationMessage,
            btnLabel: 'YES', cancelBtnLabel: 'NO') ??
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
