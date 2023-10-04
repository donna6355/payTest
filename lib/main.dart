import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pay_test/repo/cam_controller.dart';
import 'package:provider/provider.dart';
import 'custom_nav.dart';
import 'data/serial_port_helper.dart';
import 'repo/payment_repo.dart';
import 'repo/serial_barcode_repo.dart';
import 'repo/serial_board_repo.dart';
import 'state/log_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  CustomNavigator.setNavKey(navKey);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LogState()),
    ],
    child: MyApp(navKey: navKey),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.navKey, super.key});
  final GlobalKey<NavigatorState> navKey;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: '랄라루프 대여기 테스트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init()async{
    await portOpenClose();
    SerialBoardRepo.standbyBoard(2);
    SerialBarcodeRepo.readBarcode(5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
                onPressed: () {
                  SerialBarcodeRepo.terminate();
                  SerialBoardRepo.terminate();
                  exit(0);
                },
                child: const Text('종료하기')),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Label('메인보드 테스트'),
              const SizedBox(width: 50),
              ElevatedButton(
                onPressed: () => SerialBoardRepo.updatePhase(Phase.doorOpen),
                child: const Text('도어 열기'),
              ),
              const SizedBox(width: 50),
              ElevatedButton(
                onPressed: () => SerialBoardRepo.updatePhase(Phase.doorClose),
                child: const Text('도어 닫기'),
              ),
            ],
          ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     const Label('카메라 테스트'),
          //     const SizedBox(width: 50),
          //     ElevatedButton(onPressed: CameraController.fetchCamera, child: Text('카메라 오픈')),
          //     const SizedBox(width: 50),
          //     ElevatedButton(onPressed: CameraController.startRecording, child: Text('동영상 녹화')),
          //     const SizedBox(width: 50),
          //     ElevatedButton(onPressed: CameraController.stopRecording, child: Text('녹화 중지')),
          //   ],
          // ),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Label('결제 테스트'),
              SizedBox(width: 50),
              ElevatedButton(
                onPressed: PaymentRepo.ejectNReset,
                child: Text('나이스 페이 리더기 리셋'),
              ),
              SizedBox(width: 50),
              ElevatedButton(
                onPressed: PaymentRepo.checkCardIn,
                child: Text('카드 확인 => 100원 결제'),
              ),
              SizedBox(width: 50),
              ElevatedButton(
                onPressed: PaymentRepo.cancelReq,
                child: Text('직전 취소'),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 400,
            width: double.infinity,
            color: Colors.black,
            child: ListView(
              children: [
                Consumer<LogState>(builder: (_, state, __) {
                  return Text(
                    state.log,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                })
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Label extends StatelessWidget {
  const Label(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 0, 10),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
