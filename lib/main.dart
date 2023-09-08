import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'socket_test.dart';
import 'dll_test.dart';

void main() {

    
  final String sample ='0363VCAT0000035102101000000000000010040000000000000000000000000011212272 22012111211502KB국민카드 02KB국민카드 00040793408 2393300001  IC카드 정상승인 11212272356415**********023933000010121112112NS220121112115D55718IC';
  
List<String> split(String string) {
  const String separator = '\u001c';
  List<String> result =[];


  while (true) {
    int index = string.indexOf(separator, 0);
    if (index == -1 ) {
      result.add(string);
      break;
    }

    result.add(string.substring(0, index));
    string = string.substring(index + separator.length);
  }

  return result;
}
  final res = split(sample);
  print(res);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket? _socket; 
  StreamSubscription<Uint8List>? _socketSubscribe;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init()async{
    _socket = await SocketTest.init();
    try {
    _socketSubscribe = _socket!.listen((Uint8List res) {
    final decRes = utf8.decode(res);
      print('socekt receive!!!!!!!!!!!!!!!$decRes');
    });
    } catch (e) {
      _socketSubscribe?.cancel();
      _socket!.close();
      SocketTest.dispose();
    }

  }

  void _socketPay(int amount){
    final String payData = 'NICEVCAT\u00070200${fs}10${fs}C$fs$amount$fs$fs${fs}00$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs\u0007';
    final int dataLen =payData.length;
    final String data= '00${dataLen+12}VCAT$sp$sp$sp${sp}00${payData.length}$payData';
    _socket?.add(utf8.encode(data));
  }

  void _dllPay(int amount){
    final Pointer<Char> sendData = '0200${fs}10${fs}C$fs$amount$fs$fs${fs}00$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs$fs'.toNativeUtf8().cast<Char>();
    final Pointer<Char> recvData = calloc.allocate(256);


    final result = DllTest.payment(sendData, recvData);
    if (result == 0) {
      final receivedString = recvData.toString();
      print('Received data: $receivedString');
    } else {
      print('NICEVCAT failed with error code: $result');
    }

    // Don't forget to free the allocated memory
    malloc.free(recvData);
  }

  @override
  void dispose() {
    SocketTest.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PAYMENT TEST'),),
      body: Column(children: [
        ElevatedButton(
          onPressed: ()=>_socketPay(3000), 
          child: const Text('try socekt payment'),
        ),
        ElevatedButton(
          onPressed: ()=>_socket?.add(utf8.encode('\u0002S00000000050NMJSSC-16h818u9k04257gko02023-09-07_15:49:22CRC4\u0003')), 
          child: const Text('try socekt nmjs'),
        ),
        ElevatedButton(
          onPressed: ()=>_dllPay(3000), 
          child: const Text('try DLL payment'),
        ),
        ElevatedButton(
          onPressed: (){
            _socketSubscribe?.cancel();
            SocketTest.dispose();
            exit(0);
          }, 
          child: const Text('Exit'),
        ),
      ],),
    );
  }
}