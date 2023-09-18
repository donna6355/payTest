import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../custom_nav.dart';
import '../repo/serial_board_repo.dart';

class SerialBoard {
  static SerialPort? _boardPort;
  static SerialPortReader? _boardReader;
  SerialBoard._();

  static dynamic init(int port) {
    try {
      CustomNavigator.log('[PCB_RMK] initialize serial board COM$port');
      _boardPort = SerialPort("COM$port");

      _boardPort!.config.baudRate = 38400;
      _boardPort!.config.stopBits = 1;
      _boardPort!.config.bits = 8;

      _boardReader = SerialPortReader(_boardPort!);
      return true;
    } catch (e) {
      return e;
    }
  }

  static Stream<Uint8List>? readBoardStream() {
    if (!_boardPort!.openReadWrite()) {
      _boardPort?.close();
      return null;
    } else {
      return _boardReader?.stream;
    }
  }

  static void wirteBoard(List<int> cmd) {
    try {
      _boardPort!.write(Uint8List.fromList(cmd));
    } catch (e) {
      SerialBoardRepo.errorHandler(e);
    }
  }

  static void closeBoard() {
    _boardReader?.close();
    _boardPort?.close();
  }
}
