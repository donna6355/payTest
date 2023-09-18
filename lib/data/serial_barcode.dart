import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../custom_nav.dart';

class SerialBarcode {
  static SerialPort? _barcodePort;
  static SerialPortReader? _barcodeReader;
  SerialBarcode._();

  static dynamic init(int port) {
    try {
      CustomNavigator.log('[BCD_RMK] initialize serial barcode COM$port');
      _barcodePort = SerialPort("COM$port");

      _barcodePort!.config.baudRate = 9600;
      _barcodePort!.config.stopBits = 1;
      _barcodePort!.config.bits = 8;

      _barcodeReader = SerialPortReader(_barcodePort!);
      return true;
    } catch (e) {
      return e;
    }
  }

  static Stream<Uint8List>? readBarcodeStream() {
    if (!_barcodePort!.openRead()) {
      _barcodePort!.close();
      return null;
    } else {
      return _barcodeReader?.stream;
    }
  }

  static void closeBarcode() {
    _barcodeReader?.close();
    _barcodePort?.close();
  }
}
