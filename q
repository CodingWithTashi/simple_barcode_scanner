[1mdiff --git a/lib/assets/barcode.html b/lib/assets/barcode.html[m
[1mindex eae8e57..8263a8e 100644[m
[1m--- a/lib/assets/barcode.html[m
[1m+++ b/lib/assets/barcode.html[m
[36m@@ -51,7 +51,7 @@[m
                 height: 250,[m
             },[m
             videoConstraints: {[m
[31m-                facingMode: "environment",[m
[32m+[m[32m                facingMode: { exact: "environment"},[m
                 focusMode: { exact: "continuous" },[m
                 width: { ideal: 1920 },[m
                 height: { ideal: 1080 }[m
[36m@@ -59,7 +59,7 @@[m
         };[m
 [m
         html5QrCode.start({[m
[31m-            facingMode: "environment"[m
[32m+[m[32m            facingMode: {exact: "environment"}[m
         }, config, qrCodeSuccessCallback);[m
 [m
         //Window event listener[m
