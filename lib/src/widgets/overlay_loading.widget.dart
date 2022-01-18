import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayLoading extends StatelessWidget {
  final bool active;
  final Widget child;

  OverlayLoading({
    Key? key,
    required this.active,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    widgetList.add(child);
    if (active) {
      Widget layOutProgressIndicator = Center(
          child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: Theme.of(context).platform == TargetPlatform.android
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                ),
              )));

      final modal = [
        Opacity(
          opacity: 0.7,
          child: ModalBarrier(
              dismissible: false,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white),
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return Stack(
      children: widgetList,
    );
  }
}
