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
    List<Widget> widgetList = [];
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
                  child: Theme.of(context).platform == TargetPlatform.android
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                  height: 30.0,
                  width: 30.0,
                ),
              )));

      final modal = [
        new Opacity(
          child: new ModalBarrier(dismissible: false, color: Colors.white),
          opacity: 0.7,
        ),
        layOutProgressIndicator
      ];
      widgetList += modal;
    }
    return new Stack(
      children: widgetList,
    );
  }
}
