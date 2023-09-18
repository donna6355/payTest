import 'dart:async';
import 'dart:typed_data';

import '../custom_nav.dart';
import '../data/serial_board.dart';

enum Phase {
  standby([0x02, 0x57, 0x30, 0x03, 0x66], null),
  doorOpen([0x02, 0x57, 0x31, 0x03, 0x67], null),
  doorClose([0x02, 0x57, 0x32, 0x03, 0x64], null);

  final List<int> cmd;
  final Function(int)? cb;
  const Phase(this.cmd, this.cb);
}

class SerialBoardRepo {
  SerialBoardRepo._();
  static Stream<Uint8List>? _boardStream;
  static Phase _phase = Phase.standby;
  static Phase? _nextPhase;
  static String _lastRes = '';
  static final List<int> _res = [];
  static Timer? _timer;
  static int _port = 1;

  static bool standbyBoard(int port) {
    _port = port;
    dynamic initDone = SerialBoard.init(port);
    if (initDone != true) {
      CustomNavigator.log(
          '[PCB_ERR] failed to init main board ${initDone.toString()}');
      return false;
    }
    _boardStream = SerialBoard.readBoardStream();
    if (_boardStream == null) {
      CustomNavigator.log('[PCB_ERR] failed to open main board stream');
      return false;
    }
    _boardStream!.listen(_handleBoardStream, onError: errorHandler);
    CustomNavigator.log('[PCB_RMK] good to read main board');
    _startBoardCommunication();
    return true;
  }

  static Future<void> errorHandler(dynamic e) async {
    bool res = false;

    CustomNavigator.log('[PCB_ERR] ${e.toString()}');
    terminate();
    await Future.delayed(const Duration(seconds: 5));
    // await portOpenClose();
    res = standbyBoard(_port);
    CustomNavigator.log(
      res
          ? '[PCB_RMK] succeded to re-init port'
          : '[PCB_ERR] failed to re-init port',
    );
  }

  static void _handleBoardStream(Uint8List data) async {
    _res.addAll(data);
    if (_res.length < 21) return;

    final List<int> currentRes = _res.sublist(0, 21);
    final String converted = String.fromCharCodes(currentRes);

    if (converted != _lastRes) {
      CustomNavigator.log('[PCB_RCV] $converted');
      updatePhase(Phase.standby);

      _lastRes = converted;
    }
    _res.removeRange(0, 21);
  }

  static void _startBoardCommunication() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (_nextPhase != null) {
          SerialBoard.wirteBoard(_nextPhase!.cmd);
          _phase = _nextPhase!;
          CustomNavigator.log('[PCB_SND] ${_nextPhase!.cmd.toString()}');
          _nextPhase = null;
        } else {
          SerialBoard.wirteBoard(_phase.cmd);
        }
      },
    );
  }

  static void updatePhase(Phase? next) {
    _nextPhase = next;
  }

  static void terminate() {
    _timer?.cancel();
    SerialBoard.closeBoard();
  }
}

//pc => board
// [0x02, 0x57, 0x30, 0x03, 0x66]
// [STX,   W,   CMD,  ETX,   XOR]

//board => pc
// [0x02, 0x52, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30 ~ 0x30, 0x31, 0x03, 0x00]
// [ STX,  R,  CMD(2), 인렛도어(3), 손감지(4), 하단sw(5), sw1~12(6~17), 펌버전(18),  ETX(19),  XOR(20)]
//0x33 door open done // 0x34 open error
//0x37 door close done // 0x38 close error
