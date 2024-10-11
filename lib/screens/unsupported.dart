import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/barcode_appbar.dart';
import 'package:simple_barcode_scanner/enum.dart';

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
  const BarcodeScanner(
      {super.key,
      this.lineColor = "#ff6666",
      this.cancelButtonText = "Cancel",
      this.isShowFlashIcon = false,
      this.scanType = ScanType.barcode,
      required this.onScanned,
      this.appBarTitle,
      this.child,
      this.centerTitle,
      this.barcodeAppBar,
      this.delayMillis});

  @override
  Widget build(BuildContext context) {
    throw 'Platform not supported';
  }
}
