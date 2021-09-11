import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../nravepay.dart';
import '../models/models.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool isProcessing = false;
  String confirmationMessage = Setup.instance.strings.wantToCancel;
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

    var exit = await showDialog<bool>(
          context: context,
          builder: (context) => PlatformAlertDialog(
            title: Text(Setup.instance.strings.cancelPayment),
            content: Text(confirmationMessage),
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
    if (exit) {
      Navigator.of(context).pop(returnValue);
    }
    return false;
  }

  void onCancelPress() async {
    var close = await _onWillPop();
    if (close) {
      Navigator.of(context).pop(getPopReturnValue());
    }
  }

  HttpResult? getPopReturnValue() {}
}

class PlatformAlertDialog extends StatelessWidget {
  const PlatformAlertDialog({
    Key? key,
    this.title,
    this.content,
    this.actions,
  }) : super(key: key);

  /// The title of the dialog.
  ///
  /// Usually a [Text], can be a long sentence.
  final Widget? title;

  /// The content of the dialog.
  ///
  /// Complex widgets, like inputs, have to adapts their style to the current
  /// platform.
  final Widget? content;

  /// The actions of the dialog.
  ///
  /// Usually a list of [PlatformDialogAction].
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return AlertDialog(
          title: title == null ? Container() : Center(child: title),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(12),
          )),
          content: SingleChildScrollView(
            child: content,
          ),
          actions: actions,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoAlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: content,
          ),
          actions: actions!,
        );
    }
  }
}

/// Type of Dialog Actions.
///
/// Multiple types are available, each one indicate to the user the consequence
/// of his action. Changing the type imply the style change of the action button
/// in the dialog.
enum ActionType {
  /// Default style, it's a simple [PlatformDialogAction]. There is no need to
  /// manually specify this type since it's the default one.
  Default,

  /// It's the action suggested to be the _preferred_ one, the user is
  /// encouraged to press this button.
  Preferred,

  /// Indicate to the user that the action linked it's dangerous and imply the
  /// destruction of an object.
  Destructive,
}

class PlatformDialogAction extends StatelessWidget {
  const PlatformDialogAction({
    Key? key,
    required this.child,
    required this.onPressed,
    this.actionType = ActionType.Default,
  }) : super(key: key);

  /// The content of the action.
  ///
  /// Usually a [Text].
  final Widget child;

  /// The callback called when the button is pressed or activated.
  final VoidCallback onPressed;

  /// The type of this action, usually [ActionType.Default].
  final ActionType actionType;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        switch (actionType) {
          case ActionType.Default:
            return TextButton(
              onPressed: onPressed,
              child: child,
            );
          case ActionType.Preferred:
            return TextButton(
              onPressed: onPressed,
              child: child,
              // textColor: accentColor(context),
              // colorBrightness: Theme.of(context).accentColorBrightness,
            );
          case ActionType.Destructive:
            return TextButton(
              onPressed: onPressed,
              child: child,
            );
        }

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        switch (actionType) {
          case ActionType.Default:
            return CupertinoDialogAction(
              onPressed: onPressed,
              child: child,
            );
          case ActionType.Preferred:
            return CupertinoDialogAction(
              onPressed: onPressed,
              isDefaultAction: true,
              child: child,
            );
          case ActionType.Destructive:
            return CupertinoDialogAction(
              onPressed: onPressed,
              isDestructiveAction: true,
              child: child,
            );
        }
    }
  }
}
