import 'flutter_barcode_scanner.dart';

class SimpleBarcodeScanner {
  static Future<String> scanBarcode({
    String lineColor = "#ff6666",
    String cancelButtonText = 'Cancel',
    bool isShowFlashIcon = false,
    ScanMode scanMode = ScanMode.BARCODE,
    int? delayMillis,
  }) async {
    return await FlutterBarcodeScanner.scanBarcode(
      lineColor,
      cancelButtonText,
      isShowFlashIcon,
      scanMode,
      delayMillis,
    );
  }

  static Stream? getBarcodeStreamReceiver({
    String lineColor = "#ff6666",
    String cancelButtonText = 'Cancel',
    bool isShowFlashIcon = false,
    ScanMode scanMode = ScanMode.BARCODE,
    int? delayMillis,
  }) {
    return FlutterBarcodeScanner.getBarcodeStreamReceiver(
      lineColor,
      cancelButtonText,
      isShowFlashIcon,
      scanMode,
      delayMillis,
    );
  }
}
