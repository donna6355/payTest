import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart';

typedef DartFn = int Function(Pointer<Char> sendData, Pointer<Char> recvData);
typedef FfiFn = Int64 Function(Pointer<Char> sendData, Pointer<Char> recvData);

class DllTest {

  static final String _libPath = normalize(join(Directory.current.path, 'dlls', 'NVCAT.dll'));

  //production
  // static final _libPath = normalize(join(Directory.current.path, 'data',
  //     'flutter_assets', 'assets', 'dlls', 'NVCAT.dll'));

  static final DynamicLibrary lalaDll = DynamicLibrary.open(_libPath);
  static final DartFn payment =
      lalaDll.lookupFunction<FfiFn, DartFn>('NICEVCAT');
}
