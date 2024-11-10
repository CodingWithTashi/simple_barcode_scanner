import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BarcodeWidgetPage extends StatefulWidget {
  const BarcodeWidgetPage({super.key});

  @override
  State<BarcodeWidgetPage> createState() => _BarcodeWidgetPageState();
}

class _BarcodeWidgetPageState extends State<BarcodeWidgetPage> {
  BarcodeViewController? controller;
  String result = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: SimpleBarcodeScanner(
                  scaleHeight: 200,
                  scaleWidth: 400,
                  onScanned: (code) {
                    setState(() {
                      result = code;
                    });
                  },
                  continuous: true,
                  onBarcodeViewCreated: (BarcodeViewController controller) {
                    this.controller = controller;
                  },
                )),
            const SizedBox(height: 20),
            Text(result),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller?.toggleFlash();
              },
              child: const Text("Toogle Flash"),
            ),
            ElevatedButton(
              onPressed: () {
                controller?.pauseScanning();
              },
              child: const Text("Pause Scanning"),
            ),
            ElevatedButton(
              onPressed: () {
                controller?.resumeScanning();
              },
              child: const Text("Resume Scanning"),
            ),
          ],
        ),
      ),
    );
  }
}
