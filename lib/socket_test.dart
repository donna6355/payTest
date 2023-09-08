import 'dart:io';
import 'dart:async';

const String fs = '\u001c';
const  String sp = '\u0020';
class SocketTest{
  static  Socket? _socket;
  static Future<Socket?> init()async {
    _socket = await Socket.connect('211.33.136.19', 47520);
    // _socket = await Socket.connect('211.33.136.19', 8101);//prod
    // _socket = await Socket.connect('15.164.231.190', 9000); // test return tcp
    return _socket;
  }

  static void dispose(){
      _socket?.destroy();
  }
}