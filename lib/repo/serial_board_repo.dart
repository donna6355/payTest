import 'dart:async';
import 'dart:typed_data';

import 'package:provider/provider.dart';

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
  static Function(int)? _callBack;
  static int _port = 1;

  static bool standbyBoard(int port) {
    _port = port;
    dynamic initDone = SerialBoard.init(port);
    if (initDone != true) {
      // LogController.writeLog(
      //   level: LogLevel.pcb,
      //   tag: LogTag.err,
      //   msg: 'failed to init main board ${initDone.toString()}',
      // );
      return false;
    }
    _boardStream = SerialBoard.readBoardStream();
    if (_boardStream == null) {
      // LogController.writeLog(
      //   level: LogLevel.pcb,
      //   tag: LogTag.err,
      //   msg: 'failed to open main board stream',
      // );
      return false;
    }
    _boardStream!.listen(_handleBoardStream, onError: errorHandler);
    // LogController.writeLog(
    //   level: LogLevel.pcb,
    //   tag: LogTag.rmk,
    //   msg: 'good to read main board',
    // );
    _startBoardCommunication();
    return true;
  }

  static Future<void> errorHandler(dynamic e) async {
    bool res = false;
    // LogController.writeLog(
    //   level: LogLevel.pcb,
    //   tag: LogTag.err,
    //   msg: e.toString(),
    // );
    terminate();
    await Future.delayed(const Duration(seconds: 5));
    // await portOpenClose();
    res = standbyBoard(_port);
    // LogController.writeLog(
    //   level: LogLevel.pcb,
    //   tag: res ? LogTag.rmk : LogTag.err,
    //   msg: res ? 'succeded to re-init port' : 'failed to re-init port',
    // );
    if (!res) {
    } else {
      // Provider.of<LayoutState>(CustomNavigator.ctx, listen: false)
      //     .toggleDialog(toShow: false);
    }
  }

  static void _handleBoardStream(Uint8List data) async {
    _res.addAll(data);
    if (_res.length < 21) return;

    final List<int> currentRes = _res.sublist(0, 21);
    final String converted = String.fromCharCodes(currentRes);

    if (converted != _lastRes) {
      // Provider.of<AdminState>(CustomNavigator.ctx, listen: false)
      //     .updateSensorList(
      //   door: currentRes[3],
      //   hand: currentRes[4],
      //   fw: converted.substring(18, 19),
      //   switches: currentRes.sublist(6, 18),
      // );
      // LogController.writeLog(
      //   level: LogLevel.pcb,
      //   tag: LogTag.rcv,
      //   msg: '${currentRes.toString()} ($converted)',
      // );
      if (_callBack == null) {
        updatePhase(Phase.standby);
      } else {
        _callBack!(currentRes[3]);
      }
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
          // LogController.writeLog(
          //   level: LogLevel.pcb,
          //   tag: LogTag.snd,
          //   msg: _nextPhase!.cmd.toString(),
          // );
          _nextPhase = null;
        } else {
          SerialBoard.wirteBoard(_phase.cmd);
        }
      },
    );
  }

  static void updatePhase(Phase? next, {bool updateCb = true}) {
    _nextPhase = next;
    if (updateCb) _callBack = _nextPhase!.cb;
  }

  // static void openCallBack(int doorStatus) {
  //   if (doorStatus < 0x33) return;
  //   if (doorStatus == 0x33) CommonMethods.readyToRental(true);

  //   if (doorStatus == 0x34) {
  //     ErrHandler.updateErr(key: Err.board, hasError: true);
  //     CommonMethods.clearNBackToHome();
  //   }
  //   updatePhase(Phase.standby);
  // }

  // static void closeCallBack(int doorStatus) {
  //   if (doorStatus < 0x37) return;

  //   if (doorStatus == 0x38) {
  //     ErrHandler.updateErr(key: Err.board, hasError: true);
  //   }
  //   updatePhase(Phase.standby);
  //   CommonMethods.clearNBackToHome();
  // }

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
