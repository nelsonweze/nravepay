import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

enum ActionType {
  Default,
  Preferred,
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
