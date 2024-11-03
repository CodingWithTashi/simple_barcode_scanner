package com.amolg.flutterbarcodescanner.widget;

import android.content.Context;
import android.hardware.Camera;
import android.view.View;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.os.Handler;
import android.os.Looper;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.graphics.Color;
import androidx.annotation.NonNull;

import com.google.android.gms.vision.CameraSource;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;


import java.io.IOException;
import java.lang.reflect.Field;

public class FlutterBarcodeView implements PlatformView{


    private static final String TAG = "FlutterBarcodeView";
    private final Context context;
    private final FrameLayout frameLayout;
    private final SurfaceView surfaceView;
    private final ScannerOverlay scannerOverlay;
    private final ImageView scanLine;
    private final MethodChannel methodChannel;
    private CameraSource cameraSource;
    private BarcodeDetector barcodeDetector;
    private boolean isDetecting = true;
    private boolean isFlashOn = false;
    private final Handler mainHandler;
    private final int SCAN_AREA_WIDTH = 800;
    private final int SCAN_AREA_HEIGHT = 800;

    public FlutterBarcodeView(Context context, BinaryMessenger messenger, int id) {
        this.context = context;
        this.mainHandler = new Handler(Looper.getMainLooper());

        // Create main container
        frameLayout = new FrameLayout(context);

        // Create and add surface view
        surfaceView = new SurfaceView(context);
        frameLayout.addView(surfaceView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        // Create and add scanner overlay
        scannerOverlay = new ScannerOverlay(context);
        frameLayout.addView(scannerOverlay, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        // Create and add scan line
        scanLine = new ImageView(context);
        scanLine.setBackgroundColor(Color.RED);
        FrameLayout.LayoutParams scanLineParams = new FrameLayout.LayoutParams(
                SCAN_AREA_WIDTH - 40, // Slightly smaller than scan area
                5); // Line thickness
        frameLayout.addView(scanLine, scanLineParams);

        // Start scan line animation
        startScanLineAnimation();

        methodChannel = new MethodChannel(messenger, "plugins.codingwithtashi/barcode_scanner_view_" + id);
        methodChannel.setMethodCallHandler(this::onMethodCall);

        setupBarcodeDetector();
        setupCameraSource();
        setupSurfaceHolder();
    }

    private void startScanLineAnimation() {
        TranslateAnimation animation = new TranslateAnimation(
                Animation.RELATIVE_TO_PARENT, 0f,
                Animation.RELATIVE_TO_PARENT, 0f,
                Animation.RELATIVE_TO_PARENT, 0f,
                Animation.RELATIVE_TO_PARENT, 0.8f);
        animation.setDuration(3000);
        animation.setRepeatCount(Animation.INFINITE);
        animation.setRepeatMode(Animation.REVERSE);
        scanLine.startAnimation(animation);
    }

    private class ScannerOverlay extends View {
        private final Paint boxPaint;
        private final Paint transparentPaint;
        private final int boxCornerRadius = 20;

        public ScannerOverlay(Context context) {
            super(context);
            boxPaint = new Paint();
            boxPaint.setColor(Color.WHITE);
            boxPaint.setStyle(Paint.Style.STROKE);
            boxPaint.setStrokeWidth(5f);

            transparentPaint = new Paint();
            transparentPaint.setColor(Color.parseColor("#80000000")); // Semi-transparent black
            transparentPaint.setStyle(Paint.Style.FILL);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            int width = getWidth();
            int height = getHeight();

            // Calculate scanner box position (centered)
            int left = (width - SCAN_AREA_WIDTH) / 2;
            int top = (height - SCAN_AREA_HEIGHT) / 2;
            int right = left + SCAN_AREA_WIDTH;
            int bottom = top + SCAN_AREA_HEIGHT;

            // Draw transparent overlay
            canvas.drawRect(0, 0, width, top, transparentPaint); // Top
            canvas.drawRect(0, top, left, bottom, transparentPaint); // Left
            canvas.drawRect(right, top, width, bottom, transparentPaint); // Right
            canvas.drawRect(0, bottom, width, height, transparentPaint); // Bottom

            // Draw scanner box
            RectF boxRect = new RectF(left, top, right, bottom);
            canvas.drawRoundRect(boxRect, boxCornerRadius, boxCornerRadius, boxPaint);
        }
    }

    private void setupBarcodeDetector() {
        barcodeDetector = new BarcodeDetector.Builder(context)
                .setBarcodeFormats(Barcode.ALL_FORMATS)
                .build();

        barcodeDetector.setProcessor(new Detector.Processor<Barcode>() {
            private final Rect scanArea = new Rect();

            @Override
            public void release() {}

            @Override
            public void receiveDetections(@NonNull Detector.Detections<Barcode> detections) {
                if (!isDetecting) return;

                // Calculate scan area boundaries
                int width = surfaceView.getWidth();
                int height = surfaceView.getHeight();
                int left = (width - SCAN_AREA_WIDTH) / 2;
                int top = (height - SCAN_AREA_HEIGHT) / 2;
                scanArea.set(left, top, left + SCAN_AREA_WIDTH, top + SCAN_AREA_HEIGHT);

                final android.util.SparseArray<Barcode> barcodes = detections.getDetectedItems();
                if (barcodes.size() > 0) {
                    final Barcode code = barcodes.valueAt(0);
                    System.out.println("Barcode detected: " + code.rawValue);
                    for (int i = 0; i < barcodes.size(); i++) {
                        Barcode barcode = barcodes.valueAt(i);
                        // Check if barcode is within scan area
                        if (scanArea.contains(barcode.getBoundingBox())) {
                            mainHandler.post(() -> {
                                        methodChannel.invokeMethod("onBarcodeDetected", barcode.rawValue);
                                    }
                            );
                            return;
                        }
                    }
                }

            }
        });
    }

    @Override
    public View getView() {
        return frameLayout;
    }
    private void setupCameraSource() {
        cameraSource = new CameraSource.Builder(context, barcodeDetector)
                .setAutoFocusEnabled(true)
                .setRequestedPreviewSize(1600, 1024)
                .build();
    }

    private void setupSurfaceHolder() {
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                try {
                    cameraSource.start(surfaceView.getHolder());
                } catch (IOException e) {
                    Log.e(TAG, "Error starting camera source: " + e.getMessage());
                    methodChannel.invokeMethod("onError", "Failed to start camera: " + e.getMessage());
                } catch (SecurityException e) {
                    Log.e(TAG, "Camera permission not granted: " + e.getMessage());
                    methodChannel.invokeMethod("onError", "Camera permission not granted");
                }
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                cameraSource.stop();
            }
        });
    }

    private Camera getCamera() {
        try {
            Field[] declaredFields = CameraSource.class.getDeclaredFields();
            for (Field field : declaredFields) {
                if (field.getType() == Camera.class) {
                    field.setAccessible(true);
                    return (Camera) field.get(cameraSource);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error accessing camera: " + e.getMessage());
        }
        return null;
    }

    private void toggleFlash(MethodChannel.Result result) {
        try {
            Camera camera = getCamera();
            if (camera != null) {
                Camera.Parameters parameters = camera.getParameters();
                if (!isFlashOn) {
                    parameters.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
                    isFlashOn = true;
                } else {
                    parameters.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
                    isFlashOn = false;
                }
                camera.setParameters(parameters);
                result.success(isFlashOn);
            } else {
                result.error("CAMERA_ERROR", "Camera not available", null);
            }
        } catch (Exception e) {
            result.error("FLASH_ERROR", "Error toggling flash: " + e.getMessage(), null);
        }
    }



    private void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "pauseScanning":
                isDetecting = false;
                result.success(null);
                break;
            case "resumeScanning":
                isDetecting = true;
                result.success(null);
                break;
            case "toggleFlash":
                toggleFlash(result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void dispose() {
        if (cameraSource != null) {
            cameraSource.release();
            cameraSource = null;
        }
        if (barcodeDetector != null) {
            barcodeDetector.release();
            barcodeDetector = null;
        }
        scanLine.clearAnimation();
    }
}