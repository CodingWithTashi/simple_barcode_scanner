library simple_barcode_scanner;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/barcode_appbar.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/shared.dart';

export 'package:simple_barcode_scanner/barcode_appbar.dart';
export 'package:simple_barcode_scanner/enum.dart';
export 'package:simple_barcode_scanner/screens/barcode_controller.dart';
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
        if (context.mounted) Navigator.pop(context, res);
      },
    );
  }
}

/// A utility class for barcode scanning functionality.
/// Can be used both as a widget and through static methods.
///
/// Example usage as a widget:
/// ```dart
/// SimpleBarcodeScanner(
///   onScanned: (code) {
///     print('Scanned: $code');
///   },
///   continuous: true,
/// )
/// ```
///
/// Example usage as static method:
/// ```dart
/// final result = await SimpleBarcodeScanner.scanBarcode(context);
/// ```
///

class SimpleBarcodeScanner extends StatelessWidget {
  /// Callback function called when the scanner view is created.
  final BarcodeScannerViewCreated onBarcodeViewCreated;

  /// The format of the barcode to scan. Default is ALL_FORMATS (e.g., ONLY_QR_CODE, ONLY_BARCODE). Only works on Android and iOS. Web will scan all formats.
  final ScanFormat scanFormat;

  /// The width of the scanner view.
  final double? scaleWidth;

  /// The height of the scanner view.
  final double? scaleHeight;

  /// The color of the scanning line in hex format.
  final String lineColor;

  /// Whether to show the flash toggle icon.
  final bool isShowFlashIcon;

  /// The type of barcode to scan (e.g., barcode, QR code).
  final ScanType scanType;

  /// Which camera to use for scanning.
  final CameraFace cameraFace;

  /// Delay in milliseconds between consecutive scans.
  final int? delayMillis;

  /// Optional widget to display in the scanner interface.
  final Widget? child;

  /// Callback function called when a barcode is successfully scanned.
  /// Provides the scanned string value.
  final Function(String)? onScanned;

  /// Whether to continuously scan barcodes (true) or stop after first scan (false).
  final bool continuous;

  /// Callback function called when the scanner is closed.
  final VoidCallback? onClose;

  /// Creates a new SimpleBarcodeScanner widget.
  const SimpleBarcodeScanner(
      {this.scaleWidth,
      this.scaleHeight,
      super.key,
      this.lineColor = "#ff6666",
      this.isShowFlashIcon = false,
      this.scanType = ScanType.barcode,
      this.cameraFace = CameraFace.back,
      this.delayMillis,
      this.child,
      this.onScanned,
      this.continuous = false,
      this.onClose,
      this.scanFormat = ScanFormat.ALL_FORMATS,
      required this.onBarcodeViewCreated});

  /// Launches the barcode scanner interface and returns the scanned value.
  ///
  /// This is a one-time scan that will return after successfully scanning a barcode
  /// or when the user cancels the scan.
  ///
  /// Parameters:
  /// - [context]: The BuildContext required for navigation.
  /// - [lineColor]: The color of the scanning line (default: "#ff6666").
  /// - [cancelButtonText]: Text for the cancel button (default: "Cancel").
  /// - [isShowFlashIcon]: Whether to show the flash toggle icon (default: false).
  /// - [scanType]: The type of barcode to scan (default: ScanType.barcode).
  /// - [cameraFace]: Which camera to use (default: CameraFace.back).
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
    CameraFace cameraFace = CameraFace.back,
    BarcodeAppBar? barcodeAppBar,
    int? delayMillis,
    Widget? child,
    ScanFormat scanFormat = ScanFormat.ALL_FORMATS,
  }) async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          lineColor: lineColor,
          cancelButtonText: cancelButtonText,
          isShowFlashIcon: isShowFlashIcon,
          scanType: scanType,
          cameraFace: cameraFace,
          barcodeAppBar: barcodeAppBar,
          delayMillis: delayMillis,
          scanFormat: scanFormat,
          onScanned: (res) => Navigator.pop(context, res),
          child: child,
        ),
      ),
    );
  }

  /// Continuously scans barcodes and emits results through a stream.
  ///
  /// This method will continue scanning and emitting barcode values until
  /// the scanner is closed or manually stopped.
  ///
  /// Parameters:
  /// - [context]: The BuildContext required for navigation.
  /// - [lineColor]: The color of the scanning line (default: "#ff6666").
  /// - [cancelButtonText]: Text for the cancel button (default: "Cancel").
  /// - [isShowFlashIcon]: Whether to show the flash toggle icon (default: false).
  /// - [scanType]: The type of barcode to scan (default: ScanType.barcode).
  /// - [cameraFace]: Which camera to use (default: CameraFace.back).
  /// - [barcodeAppBar]: Custom app bar configuration.
  /// - [delayMillis]: Delay in milliseconds between scans.
  /// - [child]: Optional widget to display in the scanner interface.
  ///
  /// Returns a [Stream<String>] that emits scanned barcode values.
  /// The stream is closed when the scanner is closed.
  static Stream<String> streamBarcode(
    BuildContext context, {
    String lineColor = "#ff6666",
    String cancelButtonText = "Cancel",
    bool isShowFlashIcon = false,
    ScanType scanType = ScanType.barcode,
    CameraFace cameraFace = CameraFace.back,
    BarcodeAppBar? barcodeAppBar,
    int? delayMillis,
    ScanFormat scanFormat = ScanFormat.ALL_FORMATS,
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
          cameraFace: cameraFace,
          barcodeAppBar: barcodeAppBar,
          delayMillis: delayMillis,
          scanFormat: scanFormat,
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
          child: child,
        ),
      ),
    );

    return streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return BarcodeScannerView(
      scannerHeight: scaleHeight,
      scannerWidth: scaleWidth,
      scanType: scanType,
      cameraFace: cameraFace,
      delayMillis: delayMillis,
      onScanned: onScanned,
      continuous: continuous,
      onClose: onClose,
      onBarcodeViewCreated: onBarcodeViewCreated,
      scanFormat: scanFormat,
      child: child,
    );
  }
}
