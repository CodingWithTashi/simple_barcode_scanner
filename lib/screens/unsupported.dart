import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';

class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
    /// Properties only added to standardize the implementation of the BarcodeScanner class
  final int scanWidth;
  final int scanHeight;

  const BarcodeScanner(
      {Key? key,
      this.lineColor = "#ff6666",
      this.cancelButtonText = "Cancel",
      this.isShowFlashIcon = false,
      this.scanType = ScanType.barcode,
      required this.onScanned,
      this.appBarTitle,
      this.centerTitle,
      this.scanWidth = 0,
      this.scanHeight= 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw 'Platform not supported';
  }
}
