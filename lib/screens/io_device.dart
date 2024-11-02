import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/window.dart';

import '../barcode_appbar.dart';
import '../constant.dart';
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
  final Function? onClose;
  const BarcodeScanner(
      {super.key,
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
      this.onClose});

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
        appBarTitle: appBarTitle,
        centerTitle: centerTitle,
        delayMillis: delayMillis,
      );
    } else {
      /// Scan Android and ios barcode scanner with flutter_barcode_scanner
      /// If onClose is not null then stream barcode otherwise scan barcode
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
      onClose != null
          ? _streamBarcodeForMobileAndTabDevices(scanMode)
          : _scanBarcodeForMobileAndTabDevices(scanMode);

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  _scanBarcodeForMobileAndTabDevices(ScanMode scanMode) async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        lineColor, cancelButtonText, isShowFlashIcon, scanMode, delayMillis);
    onScanned(barcode);
  }

  void _streamBarcodeForMobileAndTabDevices(ScanMode scanMode) {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            lineColor, cancelButtonText, isShowFlashIcon, scanMode, delayMillis)
        ?.listen((barcode) {
      if (barcode != null) {
        barcode == kCancelValue ? onClose?.call() : onScanned(barcode);
      }
    });
  }
}
