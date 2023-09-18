import 'package:flutter/material.dart';

class LogState extends ChangeNotifier {
  String _log = '';
  void updateLog(String log) {
    _log += log;
    notifyListeners();
  }

  void reset() {
    _log = '';
    notifyListeners();
  }

  String get log => _log;
}
