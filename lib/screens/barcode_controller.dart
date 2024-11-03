import 'dart:developer';

import 'package:flutter/services.dart';

class BarcodeViewController {
  BarcodeViewController.data(int id)
      : _channel =
            MethodChannel('plugins.codingwithtashi/barcode_scanner_view_$id') {
    log("Initializing BarcodeViewController with id: $id");
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final MethodChannel _channel;
  Function(String)? _onScanned;

  void setOnScanned(Function(String) callback) {
    log("Setting onScanned callback");
    _onScanned = callback;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    print("Received method call: ${call.method}"); // Debug log
    switch (call.method) {
      case 'onBarcodeDetected':
        if (_onScanned != null) {
          _onScanned!(call.arguments as String);
        }
        break;
      case 'onError':
        log('Barcode Scanner Error: ${call.arguments}');
        break;
      default:
        log('Unhandled method: ${call.method}');
        break;
    }
  }

  Future<void> toggleFlash() {
    return _channel.invokeMethod('toggleFlash');
  }

  Future<void> pauseScanning() {
    return _channel.invokeMethod('pauseScanning');
  }

  Future<void> resumeScanning() {
    return _channel.invokeMethod('resumeScanning');
  }
}
