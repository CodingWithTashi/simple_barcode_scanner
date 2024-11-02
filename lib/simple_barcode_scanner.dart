library simple_barcode_scanner;

import 'dart:async';

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
  @Deprecated(
      'Use SimpleBarcodeScanner followed by scanBarcode instead. This field will be removed in future versions.')
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

/// A utility class for barcode scanning functionality.
class SimpleBarcodeScanner {
  /// Launches the barcode scanner interface and returns the scanned value.
  ///
  /// Parameters:
  /// - [context]: The BuildContext required for navigation.
  /// - [lineColor]: The color of the scanning line (default: "#ff6666").
  /// - [cancelButtonText]: Text for the cancel button (default: "Cancel").
  /// - [isShowFlashIcon]: Whether to show the flash toggle icon (default: false).
  /// - [scanType]: The type of barcode to scan (default: ScanType.barcode).
  /// - [barcodeAppBar]: Custom app bar configuration.
  /// - [delayMillis]: Delay in milliseconds between scans.
  /// - [child]: Optional widget to display in the scanner interface.
  ///
  /// Returns a [Future<String?>] that completes with the scanned value,
  /// or null if scanning was cancelled.
  static Future<String?> scanBarcode(
    BuildContext context, {
    String lineColor = "#ff6666",
    String cancelButtonText = "Cancel",
    bool isShowFlashIcon = false,
    ScanType scanType = ScanType.barcode,
    BarcodeAppBar? barcodeAppBar,
    int? delayMillis,
    Widget? child,
  }) async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          lineColor: lineColor,
          cancelButtonText: cancelButtonText,
          isShowFlashIcon: isShowFlashIcon,
          scanType: scanType,
          barcodeAppBar: barcodeAppBar,
          delayMillis: delayMillis,
          child: child,
          onScanned: (res) => Navigator.pop(context, res),
        ),
      ),
    );
  }

  /// Continuously scans barcodes and emits results through a stream.
  ///
  /// The stream continues until the scanner is closed or [stopScanning] is called.
  /// Returns a [Stream<String>] of scanned barcode values.
  static Stream<String> streamBarcode(
    BuildContext context, {
    String lineColor = "#ff6666",
    String cancelButtonText = "Cancel",
    bool isShowFlashIcon = false,
    ScanType scanType = ScanType.barcode,
    BarcodeAppBar? barcodeAppBar,
    int? delayMillis,
    Widget? child,
  }) {
    final streamController = StreamController<String>();
    bool isPopped = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          lineColor: lineColor,
          cancelButtonText: cancelButtonText,
          isShowFlashIcon: isShowFlashIcon,
          scanType: scanType,
          barcodeAppBar: barcodeAppBar,
          delayMillis: delayMillis,
          child: child,
          onScanned: (res) {
            streamController.add(res);
            // Don't pop the navigator - keep scanning
          },
          onClose: () {
            if (!isPopped) {
              isPopped = true;
              streamController.close();
              Navigator.pop(context);
            }
          },
        ),
      ),
    );

    return streamController.stream;
  }
}
