import 'package:flutter/material.dart';
import '../models.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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

    bool exit = await showPlatformDialog<bool>(
          context: context,
          builder: (context) => PlatformAlertDialog(
            title: Text('Cancel Payment'),
            content: Text(confirmationMessage),
            actions: [
              PlatformDialogAction(
                child: PlatformText('NO'),
                onPressed: () => Navigator.pop(context, false),
              ),
              PlatformDialogAction(
                child: PlatformText('YES'),
                onPressed: () => Navigator.pop(context, true),
              )
            ],
          ),
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
