# simple_barcode_scanner 

simple_barcode_scanner let you scan barcode and qr code.

## Demo
![Image](https://github.com/CodingWithTashi/simple_barcode_scanner/blob/master/example/demo/search.png?raw=true)

## Features

* Scan barcode in mobile devices using flutter_barcode_scanner
* Scan barcode in web/window using html5-qrcode package

## Getting started

```dart
simple_barcode_scanner: ^0.0.1

```   
Import the library:
```dart
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

```
## Usage   

```dart
** ElevatedButton(
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
            ),**
```   
## Todo   
* Flash and switch camera are only available in mobile devices
* Enhancement

If you have any questions, feedback or ideas, feel free to [create an
issue](https://github.com/CodingWithTashi/simple_barcode_scanner/issues/new). If you enjoy this
project, I'd appreciate your [🌟 on GitHub](https://github.com/CodingWithTashi/simple_barcode_scanner/).   

## You can also buy me a cup of coffee   
<a href="https://www.buymeacoffee.com/codingwithtashi"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width=200px></a>
