import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:path/path.dart' as p;

class WindowBarcodeScanner extends StatelessWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;

  const WindowBarcodeScanner({
    Key? key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebviewController controller = WebviewController();

    return Scaffold(
      body: FutureBuilder<bool>(
          future: initPlatformState(controller: controller),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Webview(
                controller,
                permissionRequested: (url, permissionKind, isUserInitiated) =>
                    _onPermissionRequested(
                        url: url,
                        kind: permissionKind,
                        isUserInitiated: isUserInitiated,
                        context: context),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      {required String url,
      required WebviewPermissionKind kind,
      required bool isUserInitiated,
      required BuildContext context}) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission requested'),
        content:
            Text('\'${kind.name}\' permission is require to scan qr/barcode'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  String getAssetFileUrl({required String asset}) {
    final assetsDirectory = p.join(p.dirname(Platform.resolvedExecutable),
        'data', 'flutter_assets', asset);
    print(assetsDirectory);
    return Uri.file(assetsDirectory).toString();
  }

  Future<bool> initPlatformState(
      {required WebviewController controller}) async {
    String? barcodeNumber;

    try {
      await controller.initialize();
      await controller
          .loadUrl(getAssetFileUrl(asset: PackageConstant.barcodeFilePath));
      controller.webMessage.listen((event) {
        if (event['methodName'] == "submitCallback") {
          if (event['data'] is String && event['data'].isNotEmpty) {
            if (barcodeNumber == null) {
              barcodeNumber = event['data'];
              onScanned(barcodeNumber!);
            }
          }
        }
      });
    } catch (e) {
      rethrow;
    }
    return true;
  }
}
