import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/window.dart';

/// Barcode scanner for mobile and desktop devices
class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;

  const BarcodeScanner({
    Key? key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      ///Get Window barcode Scanner UI
      return WindowBarcodeScanner(
        lineColor: lineColor,
        cancelButtonText: cancelButtonText,
        isShowFlashIcon: isShowFlashIcon,
        scanType: scanType,
        onScanned: onScanned,
      );
    } else {
      /// Scan Android and ios barcode scanner with flutter_barcode_scanner
      _scanBarcodeForMobileAndTabDevices();
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  _scanBarcodeForMobileAndTabDevices() async {
    /// Scan barcode for mobile devices
    ScanMode scanMode;
    switch (scanType) {
      case ScanType.BARCODE:
        scanMode = ScanMode.barcode;
        break;
      case ScanType.QR:
        scanMode = ScanMode.qr;
        break;
      default:
        scanMode = ScanMode.defaultMode;
        break;
    }
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        lineColor, cancelButtonText, isShowFlashIcon, scanMode);
    onScanned(barcode);
  }
}
