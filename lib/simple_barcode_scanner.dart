library simple_barcode_scanner;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/shared.dart';

export 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class SimpleBarcodeScannerPage extends StatelessWidget {
  ///Barcode line color default set to #ff6666
  final String lineColor;

  ///Cancel button text while scanning
  final String cancelButtonText;

  ///Flag to show flash icon while scanning or not
  final bool isShowFlashIcon;

  ///Enter enum scanType, It can be BARCODE, QR, DEFAULT
  final ScanType scanType;

  ///AppBar Title
  final String? appBarTitle;

  ///center Title
  final bool? centerTitle;

  /// appBatTitle and centerTitle support in web and window only
  /// Remaining field support in only mobile devices
  const SimpleBarcodeScannerPage({
    Key? key,
    this.lineColor = "#ff6666",
    this.cancelButtonText = "Cancel",
    this.isShowFlashIcon = false,
    this.scanType = ScanType.barcode,
    this.appBarTitle,
    this.centerTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(
      lineColor: lineColor,
      cancelButtonText: cancelButtonText,
      isShowFlashIcon: isShowFlashIcon,
      scanType: scanType,
      appBarTitle: appBarTitle,
      centerTitle: centerTitle,
      onScanned: (res) {
        Navigator.pop(context, res);
      },
    );
  }
}
