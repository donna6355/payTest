import 'dart:typed_data';
import 'package:provider/provider.dart';

import '../data/serial_barcode.dart';

enum VerifyCode {
  admin,
  rental,
  refill,
}

class SerialBarcodeRepo {
  SerialBarcodeRepo._();
  static bool _activated = true;
  static Stream<Uint8List>? _barcodeStream;
  static List<int> _combine = [];
  // static VerifyCode _mode = VerifyCode.admin;
  static int _port = 2;

  static bool readBarcode(int port) {
    _port = port;
    dynamic initDone = SerialBarcode.init(port);
    if (initDone != true) {
      // LogController.writeLog(
      //   level: LogLevel.bcd,
      //   tag: LogTag.err,
      //   msg: 'failed to init barcode ${initDone.toString()}',
      // );
      return false;
    }
    _barcodeStream = SerialBarcode.readBarcodeStream();
    if (_barcodeStream == null) {
      // LogController.writeLog(
      //   level: LogLevel.bcd,
      //   tag: LogTag.err,
      //   msg: 'failed to open barcode stream',
      // );
      return false;
    }
    _barcodeStream!.listen(
      handleBarcodeStream,
      onError: errorHandler,
    );
    // LogController.writeLog(
    //   level: LogLevel.bcd,
    //   tag: LogTag.rmk,
    //   msg: 'good to read barcode',
    // );
    return true;
  }

  static Future<void> errorHandler(dynamic e) async {
    bool res = false;
    // LogController.writeLog(
    //   level: LogLevel.bcd,
    //   tag: LogTag.err,
    //   msg: e.toString(),
    // );
    terminate();
    await Future.delayed(
      const Duration(seconds: 3),
      () => res = readBarcode(_port),
    );
    // LogController.writeLog(
    //   level: LogLevel.bcd,
    //   tag: res ? LogTag.rmk : LogTag.err,
    //   msg: res ? 'succeded to re-init port' : 'failed to re-init port',
    // );
    if (!res) {
      // ErrHandler.updateErr(key: Err.barcode, hasError: true);
    } else {
      // Provider.of<LayoutState>(CustomNavigator.ctx, listen: false)
      //     .toggleDialog(toShow: false);
    }
  }

  static void activate(
    bool activate, {
    VerifyCode mode = VerifyCode.admin,
  }) {
    _activated = activate;
    // _mode = mode;
  }

  static void handleBarcodeStream(Uint8List data) {
    if (!_activated) return;
    _combine += data;
    if (_combine.last != 10) return;
    final String converted = String.fromCharCodes(_combine).trim();
    // LogController.writeLog(
    //   level: LogLevel.bcd,
    //   tag: LogTag.rcv,
    //   msg: converted,
    // );
    _activated = false;
    _combine = [];
  }

  static void terminate() {
    SerialBarcode.closeBarcode();
  }
}
