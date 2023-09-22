import 'dart:typed_data';

import 'package:pay_test/custom_nav.dart';

import '../data/serial_barcode.dart';

enum VerifyCode {
  admin,
  rental,
  refill,
}

class SerialBarcodeRepo {
  SerialBarcodeRepo._();
  static Stream<Uint8List>? _barcodeStream;
  static int _port = 2;

  static bool readBarcode(int port) {
    _port = port;
    dynamic initDone = SerialBarcode.init(port);
    if (initDone != true) {
      CustomNavigator.log(
          '[BCD_ERR] failed to init barcode ${initDone.toString()}');
      return false;
    }
    _barcodeStream = SerialBarcode.readBarcodeStream();
    if (_barcodeStream == null) {
      CustomNavigator.log('[BCD_ERR] failed to open barcode stream');
      return false;
    }
    _barcodeStream!.listen(
      handleBarcodeStream,
      onError: errorHandler,
    );
    CustomNavigator.log('[BCD_RMK] good to read barcode');
    return true;
  }

  static Future<void> errorHandler(dynamic e) async {
    bool res = false;
    CustomNavigator.log('[BCD_ERR] ${e.toString()}');
    terminate();
    await Future.delayed(
      const Duration(seconds: 3),
      () => res = readBarcode(_port),
    );

    CustomNavigator.log(
      res
          ? '[BCD_RMK] succeded to re-init port'
          : '[BCD_ERR] failed to re-init port',
    );
  }

  static void handleBarcodeStream(Uint8List data) {
    final String converted = String.fromCharCodes(data).trim();
    CustomNavigator.log('[BCD_RCV] $converted');
  }

  static void terminate() {
    SerialBarcode.closeBarcode();
  }
}
