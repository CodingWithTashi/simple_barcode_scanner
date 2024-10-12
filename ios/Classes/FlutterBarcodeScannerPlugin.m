#import "FlutterBarcodeScannerPlugin.h"
#import <simple_barcode_scanner/simple_barcode_scanner-Swift.h>

@implementation FlutterBarcodeScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBarcodeScannerPlugin registerWithRegistrar:registrar];
}
@end
