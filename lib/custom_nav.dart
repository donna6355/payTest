import 'package:flutter/material.dart';

class CustomNavigator {
  CustomNavigator._();
  static late GlobalKey<NavigatorState> _navKey;

  static void setNavKey(GlobalKey<NavigatorState> key) => _navKey = key;

  static BuildContext get ctx => _navKey.currentContext!;
}
