library simple_barcode_scanner;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/barcode_appbar.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/shared.dart';

export 'package:simple_barcode_scanner/barcode_appbar.dart';
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

  final BarcodeAppBar? barcodeAppBar;

  /// Delay in milliseconds to start the scanner
  final int? delayMillis;

  /// Specify a child widget to be positioned beneath the scanner.
  /// This is beneficial when you need to include a customized text field
  /// for manual entry of barcode/QR code.
  /// example:
  ///  ```dart
  /// child: Column(
  ///   children: [
  ///     SizedBox(
  ///       height: 20,
  ///     ),
  ///    TextField(
  ///       decoration: InputDecoration(
  ///         labelText: 'Enter Barcode manually',
  ///         border: OutlineInputBorder(),
  ///       ),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final Widget? child;

  /// appBatTitle and centerTitle support in web and window only
  /// Remaining field support in only mobile devices
  const SimpleBarcodeScannerPage(
      {super.key,
      this.lineColor = "#ff6666",
      this.cancelButtonText = "Cancel",
      this.isShowFlashIcon = false,
      this.scanType = ScanType.barcode,
      @Deprecated(
          'Use BarcodeAppBar instead. This field will be removed in future versions.')
      this.appBarTitle,
      @Deprecated(
          'Use BarcodeAppBar instead. This field will be removed in future versions.')
      this.centerTitle,
      this.child,
      this.barcodeAppBar,
      this.delayMillis});

  @override
  Widget build(BuildContext context) {
    assert(
        (appBarTitle == null && centerTitle == null) ||
            barcodeAppBar == null ||
            (appBarTitle != null &&
                centerTitle != null &&
                barcodeAppBar == null),
        'Either provide both appBarTitle and centerTitle together, or provide barcodeAppBar, but not both.');
    return BarcodeScanner(
      lineColor: lineColor,
      cancelButtonText: cancelButtonText,
      isShowFlashIcon: isShowFlashIcon,
      scanType: scanType,
      appBarTitle: appBarTitle,
      centerTitle: centerTitle,
      barcodeAppBar: barcodeAppBar,
      delayMillis: delayMillis,
      child: child,
      onScanned: (res) {
        Navigator.pop(context, res);
      },
    );
  }
}
