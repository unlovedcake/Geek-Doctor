import 'package:flutter/cupertino.dart';

class BouncyPageRoute extends PageRouteBuilder {
  final Widget widget;

  BouncyPageRoute({required this.widget})
      : super(
            transitionDuration: Duration(seconds: 1),
            transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation, Widget child) {
              animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

              return ScaleTransition(
                filterQuality: FilterQuality.high,
                alignment: Alignment.center,
                scale: animation,
                child: child,
              );

              // return FadeScaleTransition(
              //   // alignment: Alignment.center,
              //   // scale: animation,
              //   animation: animation,
              //   child: child,
              // );
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return widget;
            });
}
