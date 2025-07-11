import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/barcode_controller.dart';
// import 'package:simple_barcode_scanner/screens/window.dart';

import '../barcode_appbar.dart';
import '../constant.dart';
import '../flutter_barcode_scanner.dart';

/// Barcode scanner for mobile and desktop devices
class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final Widget? child;
  final BarcodeAppBar? barcodeAppBar;
  final int? delayMillis;
  final Function? onClose;
  final ScanFormat scanFormat;

  const BarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    this.cameraFace = CameraFace.back,
    required this.onScanned,
    this.child,
    this.appBarTitle,
    this.centerTitle,
    this.barcodeAppBar,
    this.delayMillis,
    this.onClose,
    this.scanFormat = ScanFormat.ALL_FORMATS,
  });

  @override
  Widget build(BuildContext context) {

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


  _scanBarcodeForMobileAndTabDevices(ScanMode scanMode) async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      lineColor,
      cancelButtonText,
      isShowFlashIcon,
      scanMode,
      delayMillis,
      cameraFace.name.toUpperCase(),
      scanFormat,
    );
    onScanned(barcode);
  }

  void _streamBarcodeForMobileAndTabDevices(ScanMode scanMode) {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
      lineColor,
      cancelButtonText,
      isShowFlashIcon,
      scanMode,
      delayMillis,
      cameraFace.name.toUpperCase(),
      scanFormat,
    )?.listen((barcode) {
      if (barcode != null) {
        barcode == kCancelValue ? onClose?.call() : onScanned(barcode);
      }
    });
  }
}

// This is for scanner Widget, which is used to scan the barcode.

typedef BarcodeScannerViewCreated = void Function(
    BarcodeViewController controller);

/// for widgets
class BarcodeScannerView extends StatelessWidget {
  final BarcodeScannerViewCreated onBarcodeViewCreated;
  final double? scannerWidth;
  final double? scannerHeight;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String)? onScanned;
  final Widget? child;
  final int? delayMillis;
  final Function? onClose;
  final bool continuous;
  final ScanFormat scanFormat;
  const BarcodeScannerView(
      {super.key,
      this.scannerWidth,
      this.scannerHeight,
      required this.scanType,
      this.cameraFace = CameraFace.back,
      required this.onScanned,
      this.continuous = false,
      this.child,
      this.delayMillis,
      this.onClose,
      this.scanFormat = ScanFormat.ALL_FORMATS,
      required this.onBarcodeViewCreated});

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'plugins.codingwithtashi/barcode_scanner_view',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'scanType': scanType.index,
            'cameraFace': cameraFace.index,
            'delayMillis': delayMillis,
            'continuous': continuous,
            'scannerWidth': scannerWidth?.toInt(),
            'scannerHeight': scannerHeight?.toInt(),
            'scanFormat': scanFormat.name,
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'plugins.codingwithtashi/barcode_scanner_view',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'scanType': scanType.index,
            'cameraFace': cameraFace.index,
            'delayMillis': delayMillis,
            'continuous': continuous,
            'scannerWidth': scannerWidth?.toInt(),
            'scannerHeight': scannerHeight?.toInt(),
            'scanFormat': scanFormat.name,
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by the web_view plugin');
    }
  }

  // Callback method when platform view is created

  void _onPlatformViewCreated(int id) {
    final controller = BarcodeViewController.data(id);
    if (onScanned != null) {
      controller.setOnScanned(onScanned!);
    }
    onBarcodeViewCreated(controller);
  }
}
