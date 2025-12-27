import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

import 'generated_carpcconnector.dart';

const String _libName = 'carpcconnector';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final CarPCNativeLibrary _bindings = CarPCNativeLibrary(_dylib);

class CarPcConnector {
  String get version {
    try {
      return _bindings.library_version.toString();
    } catch (exp) {
      debugPrint("CarPcConnector Error $exp");
      return "Error";
    }
  }
}
