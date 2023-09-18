import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/log_state.dart';

class CustomNavigator {
  CustomNavigator._();
  static late GlobalKey<NavigatorState> _navKey;

  static void setNavKey(GlobalKey<NavigatorState> key) => _navKey = key;
  static void log(String log) {
    Provider.of<LogState>(ctx, listen: false)
        .updateLog('${DateTime.now()} $log\n');
  }

  static BuildContext get ctx => _navKey.currentContext!;
}
