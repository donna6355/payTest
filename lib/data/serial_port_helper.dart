
import 'package:serial_port_win32/serial_port_win32.dart';

import '../custom_nav.dart';

Future<void> portOpenClose() async {
  try {
    final port = SerialPort('COM1');
    if (port.isOpened) port.close();
    port.openWithSettings(BaudRate: 38400);
    await Future.delayed(const Duration(seconds: 1), () => port.close());
  } catch (e) {
      CustomNavigator.log(
          '[PCB_ERR] serial_port_win32 error :${e.toString()}');
  }
}
