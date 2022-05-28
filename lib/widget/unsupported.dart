import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';

class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  const BarcodeScanner(
      {Key? key,
      this.lineColor = "#ff6666",
      this.cancelButtonText = "Cancel",
      this.isShowFlashIcon = false,
      this.scanType = ScanType.BARCODE,
      required this.onScanned})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw 'Platform not supported';
  }
}
