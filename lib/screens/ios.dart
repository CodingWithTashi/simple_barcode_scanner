import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:simple_barcode_scanner/helpers/debouncer.dart';

class IosBarcodeScanner extends StatefulWidget {
  const IosBarcodeScanner({
    super.key,
    required this.widthCamera,
    required this.heightCamera,
    required this.onScanned,
  });

  final double widthCamera;
  final double heightCamera;
  final void Function(String) onScanned;

  @override
  State<IosBarcodeScanner> createState() => _IosBarcodeScannerState();
}

class _IosBarcodeScannerState extends State<IosBarcodeScanner>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();

  late final StreamSubscription<Object?>? _subscription;
  List<Offset>? corners;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initializeController();
  }

  void initializeController() async {
    _subscription = controller.barcodes.listen(_handleBarcode);
    controller.start();
  }

  void _handleBarcode(BarcodeCapture event) {
    final barcode = event.barcodes.firstOrNull?.rawValue;
    if (barcode == null) {
      debugPrint('SIMPLE SCANNER : barcode is null');
      return;
    }
    debugPrint('SIMPLE SCANNER : Barcode detected: $barcode');
    showScannedElement(event);
    widget.onScanned(barcode);
  }

  final debouncer = Debouncer(milliseconds: 500);

  showScannedElement(BarcodeCapture event) {
    setState(() {
      corners = event.barcodes.firstOrNull?.corners;
    });
    debouncer.run(() {
      setState(() {
        corners = null;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        debugPrint('SIMPLE SCANNER : App is resumed');
        initializeController();

      case AppLifecycleState.inactive:
        debugPrint('SIMPLE SCANNER : App is inactive');
        // Stop the scanner when the app is paused.
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double widthFullScreen = 400;
    const double heightFullScreen = 600;

    const coordA = Offset(150, 200);
    const coordB = Offset(250, 400);

    return RotatedBox(
      quarterTurns: 3,
      child: SizedBox(
        height: heightFullScreen,
        width: widthFullScreen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CupertinoActivityIndicator(),
            Container(
              color: Colors.black26,
              child: MobileScanner(
                scanWindow: Rect.fromPoints(coordA, coordB),
                controller: controller,
                errorBuilder: (context, error) {
                  return Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.brown),
                  );
                },
              ),
            ),
            _buildScanWindow(Rect.fromPoints(coordA, coordB)),
            if (corners != null)
              Positioned.fromRect(
                rect: Rect.fromPoints(
                  Offset(corners![3].dx / 4, corners![3].dy / 4),
                  Offset(corners![1].dx / 4, corners![1].dy / 4),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    disposeAll();
  }

  Future<void> disposeAll() async {
    await controller.stop();
    await controller.dispose();
    await _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('SIMPLE SCANNER : IOS Barcode controller is disposed');
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;
  final fullRect = Rect.fromPoints(const Offset(0, 0), const Offset(400, 600));

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()..addRect(fullRect);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withAlpha(128)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
