import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigateRoute {
  static gotoPage(BuildContext context, Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }
}
