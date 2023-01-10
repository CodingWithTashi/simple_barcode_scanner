// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';

/// Barcode scanner for web using iframe
class BarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final int scanWidth;
  final int scanHeight;

  const BarcodeScanner({
    Key? key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
    this.scanWidth = 288,
    this.scanHeight = 120    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String createdViewId = DateTime.now().microsecondsSinceEpoch.toString();
    String? barcodeNumber;

    final html.IFrameElement iframe = html.IFrameElement()
      ..src = PackageConstant.barcodeFileWebPath
      ..style.border = 'none'
      ..onLoad.listen((event) async {
        html.window.onMessage.listen((event) {
        /// Create reader setting qrBox width and height
        html.CustomEvent event = new html.CustomEvent("reader", detail : {
          "qrBoxWidth": scanWidth,
          "qrBoxHeight": scanHeight
        });
        html.window.document.dispatchEvent(event);

        /// Barcode listener on success barcode scanned
          /// If barcode is null then assign scanned barcode
          /// and close the screen otherwise keep scanning
          if (barcodeNumber == null) {
            barcodeNumber = event.data;
            onScanned(barcodeNumber!);
          }
        });
      });
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle ?? kScanPageTitle),
        centerTitle: centerTitle,
      ),
      body: HtmlElementView(
        viewType: createdViewId,
      ),
    );
  }
}
