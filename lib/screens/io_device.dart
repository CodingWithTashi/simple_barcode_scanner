import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';
// import 'package:simple_barcode_scanner/screens/window.dart';

import '../barcode_appbar.dart';
import '../flutter_barcode_scanner.dart';

/// Barcode scanner for mobile and desktop devices
class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final Widget? child;
  final BarcodeAppBar? barcodeAppBar;
  final int? delayMillis;

  const BarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
    this.child,
    this.appBarTitle,
    this.centerTitle,
    this.barcodeAppBar,
    this.delayMillis,
  });

  @override
  Widget build(BuildContext context) {
    /// Scan Android and ios barcode scanner with flutter_barcode_scanner
    _scanBarcodeForMobileAndTabDevices();
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  _scanBarcodeForMobileAndTabDevices() async {
    /// Scan barcode for mobile devices
    ScanMode scanMode;
    switch (scanType) {
      case ScanType.barcode:
        scanMode = ScanMode.BARCODE;
        break;
      case ScanType.qr:
        scanMode = ScanMode.QR;
        break;
      default:
        scanMode = ScanMode.DEFAULT;
        break;
    }
    String barcode =
        await FlutterBarcodeScanner.scanBarcode(lineColor, cancelButtonText, isShowFlashIcon, scanMode, delayMillis);
    onScanned(barcode);
  }
}
