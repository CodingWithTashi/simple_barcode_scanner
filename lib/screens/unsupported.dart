import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/barcode_appbar.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/barcode_controller.dart';

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
    this.lineColor = "#ff6666",
    this.cancelButtonText = "Cancel",
    this.isShowFlashIcon = false,
    this.scanType = ScanType.barcode,
    this.cameraFace = CameraFace.back,
    required this.onScanned,
    this.appBarTitle,
    this.child,
    this.centerTitle,
    this.barcodeAppBar,
    this.delayMillis,
    this.onClose,
    this.scanFormat = ScanFormat.ALL_FORMATS,
  });

  @override
  Widget build(BuildContext context) {
    throw 'Platform not supported';
  }
}

typedef BarcodeScannerViewCreated = void Function(
    BarcodeViewController controller);

class BarcodeScannerView extends StatelessWidget {
  final BarcodeScannerViewCreated onBarcodeViewCreated;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String)? onScanned;
  final Widget? child;
  final int? delayMillis;
  final Function? onClose;
  final bool continuous;
  final double? scannerWidth;
  final double? scannerHeight;
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
    throw 'Platform not supported';
  }
}
