import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';

import '../custom_nav.dart';

class CameraController {
  CameraController._();
  static late CameraDescription _cam;
  static int _camId = -1;
  static int _recoveryTry = 0;
  static StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;

  static Future<bool> fetchCamera() async {
    List<CameraDescription> cameras = <CameraDescription>[];
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      for (var cam in cameras) {
        if (cam.name.contains('CAMERA')) {
          _cam = cam;
          break;
        }
      }

      CustomNavigator.log(
          '[CAM_RMK] good to fetch camera : ${_cam.name}');
      await _initializeCamera();
      return true;
    } catch (e) {
      CustomNavigator.log(
          '[CAM_ERR] failed to fetch available cameras : ${e.toString()}');
      // TcpReqRepo.errorOccur(Constants.errorCam);
      return false;
    }
  }

  static Future<void> _initializeCamera() async {
    try {
      _camId = await CameraPlatform.instance.createCamera(
        _cam,
        ResolutionPreset.low,
        enableAudio: false,
      );

      _errorStreamSubscription?.cancel();
      _errorStreamSubscription =
          CameraPlatform.instance.onCameraError(_camId).listen((e) async {
       
      CustomNavigator.log(
          '[CAM_ERR] ${e.toString()}');
        await disposeCurrentCamera();
      });

      await CameraPlatform.instance.initializeCamera(_camId);
    } on CameraException catch (e) {
      CustomNavigator.log(
          '[CAM_ERR] failed to initialize camera : ${e.code}: ${e.description}',
      );
      // TcpReqRepo.errorOccur(Constants.errorCam);
      if (_recoveryTry == 0) {
        _recoveryTry = 1;
        await disposeCurrentCamera();
        await Future.delayed(const Duration(milliseconds: 500));
        await _initializeCamera();
      }
    }
  }

  static Future<void> startRecording() async {
    try {
      await CameraPlatform.instance.startVideoRecording(_camId);
    } catch (e) {
      CustomNavigator.log(
          '[CAM_ERR] failed to start recording : ${e.toString()}',
      );
    }
  }

  static Future<void> stopRecording() async {
    try {
      final XFile video =
          await CameraPlatform.instance.stopVideoRecording(_camId);
          await File(video.path).rename('C:/Users/oyste/Documents/lala_s_cup_rental/test_video.mp4');
    } catch (e) {
      CustomNavigator.log(
          '[CAM_ERR] failed to stop recording : ${e.toString()}',
      );
    }
  }

  static Future<void> disposeCurrentCamera() async {
    _recoveryTry = 0;
    try {
      await CameraPlatform.instance.dispose(_camId);
    } on CameraException catch (e) {
      CustomNavigator.log(
          '[CAM_ERR] failed to dispose camera: ${e.code}: ${e.description}',
      );
    }
  }
}
