# simple_barcode_scanner 

simple_barcode_scanner that let you scan barcode and qr code in mobile,web and windows.

## Demo


Android         |  IOS
:-------------------------:|:-------------------------:
<img src="https://github.com/CodingWithTashi/simple_barcode_scanner/blob/main/example/demo/scanner_android.gif?raw=true" alt="drawing" width="350" height="650"/>  |  <img src="https://github.com/CodingWithTashi/simple_barcode_scanner/blob/main/example/demo/barcode_mobile.gif?raw=true" width="400" height="600" alt="drawing"/>
      
Window         |  Web
:-------------------------:|:-------------------------:
<img src="https://github.com/CodingWithTashi/simple_barcode_scanner/blob/main/example/demo/window_scanner.gif?raw=true" alt="drawing" width="600" height="550"/>  |  <img src="https://github.com/CodingWithTashi/simple_barcode_scanner/blob/main/example/demo/barcode_web.gif?raw=true" width="550" height="600" alt="drawing"/>
      

## Features

* Scan barcode in mobile devices using flutter_barcode_scanner
* Scan barcode in web/window using html5-qrcode package   

## Installation and configuration       
* Mobile device uses flutter_barcode_scanner. refer [flutter_barcode_scanner](https://pub.dev/packages/flutter_barcode_scanner) for installation and setup
* Web uses html5-qrcode on [IFrameElement](https://api.flutter.dev/flutter/dart-html/IFrameElement-class.html). Setup is not required. For more you can read [html5-qrcode](https://github.com/mebjas/html5-qrcode)
* Window uses html5-qrcode on [webview_windows](https://pub.dev/packages/webview_windows).

## Getting started

```dart
simple_barcode_scanner: ^0.0.8

```   
Import the library:
```dart
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

```
## Usage   

```dart
   ElevatedButton(
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ));
                setState(() {
                  if (res is String) {
                    result = res;
                  }
                });
              },
              child: const Text('Open Scanner'),
            )
```   
## Todo   
* Flash and switch camera are only available in mobile devices
* Enhancement

## Note
Feel free to fork and send pull request.
If you have any questions, feedback or ideas,You can [create an
issue](https://github.com/CodingWithTashi/simple_barcode_scanner/issues/new). If you enjoy this
project, I'd appreciate your [🌟 on GitHub](https://github.com/CodingWithTashi/simple_barcode_scanner/).   

## You can also buy me a cup of coffee   
<a href="https://www.buymeacoffee.com/codingwithtashi"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width=200px></a>
