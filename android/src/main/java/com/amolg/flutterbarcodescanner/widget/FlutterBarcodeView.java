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
import java.util.Map;

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

    // Make scan area smaller than camera view
    /// 400, 200 for barcode
    private static  int SCAN_AREA_WIDTH = 400;
    private static  int SCAN_AREA_HEIGHT = 200;
    private ParamData paramData;

    public FlutterBarcodeView(Context context, BinaryMessenger messenger, int id, Object creationParams) {
        this.context = context;
        this.mainHandler = new Handler(Looper.getMainLooper());
         this.paramData = ParamData.fromMap((Map<String, Object>) creationParams);
        setDefaultData();
        // Main container
        frameLayout = new FrameLayout(context);
        frameLayout.setLayoutParams(new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        // Camera preview
        surfaceView = new SurfaceView(context);
        frameLayout.addView(surfaceView, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        // Scanner overlay with rectangle and opacity
        scannerOverlay = new ScannerOverlay(context);
        frameLayout.addView(scannerOverlay, new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        // Scanning line
        scanLine = new ImageView(context);
        scanLine.setBackgroundColor(Color.RED);
        FrameLayout.LayoutParams lineParams = new FrameLayout.LayoutParams(
                SCAN_AREA_WIDTH - 40, // Slightly smaller than scan area
                5); // Height of the line
        frameLayout.addView(scanLine, lineParams);

        // Start scanning animation
        startScanLineAnimation();

        methodChannel = new MethodChannel(messenger, "plugins.codingwithtashi/barcode_scanner_view_" + id);
        methodChannel.setMethodCallHandler(this::onMethodCall);

        setupBarcodeDetector();
        setupCameraSource();
        setupSurfaceHolder();
    }

    private void setDefaultData() {
        SCAN_AREA_WIDTH = paramData.getScannerWidth()!=null?paramData.getScannerWidth():SCAN_AREA_WIDTH;
        SCAN_AREA_HEIGHT = paramData.getScannerHeight()!=null?paramData.getScannerHeight():SCAN_AREA_HEIGHT;
    }

    private int getScreenWidth() {
        return context.getResources().getDisplayMetrics().widthPixels;
    }

    private int getScreenHeight() {
        return context.getResources().getDisplayMetrics().heightPixels;
    }

    private void startScanLineAnimation() {
        scanLine.post(() -> {
            // Position the line at the top of scan area
            int scanAreaTop = (surfaceView.getHeight() - SCAN_AREA_HEIGHT) / 2;
            int scanAreaLeft = (surfaceView.getWidth() - SCAN_AREA_WIDTH) / 2;

            scanLine.setX(scanAreaLeft + 20); // 20px margin from the sides
            scanLine.setY(scanAreaTop);

            // Create the animation
            TranslateAnimation animation = new TranslateAnimation(
                    0, 0, // X axis - no movement
                    0, SCAN_AREA_HEIGHT - 5); // Y axis - move down by scan area height

            animation.setDuration(3000); // 3 seconds for one sweep
            animation.setRepeatCount(Animation.INFINITE);
            animation.setRepeatMode(Animation.REVERSE);

            scanLine.startAnimation(animation);
        });
    }

    private class ScannerOverlay extends View {
        private final Paint boxPaint;
        private final Paint overlayPaint;

        public ScannerOverlay(Context context) {
            super(context);

            // Paint for the white rectangle
            boxPaint = new Paint();
            boxPaint.setColor(Color.WHITE);
            boxPaint.setStyle(Paint.Style.STROKE);
            boxPaint.setStrokeWidth(5f);

            // Paint for the semi-transparent overlay
            overlayPaint = new Paint();
            overlayPaint.setColor(Color.parseColor("#80000000")); // Semi-transparent black
            overlayPaint.setStyle(Paint.Style.FILL);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            int width = getWidth();
            int height = getHeight();

            // Calculate the position of scan area (centered)
            int left = (width - SCAN_AREA_WIDTH) / 2;
            int top = (height - SCAN_AREA_HEIGHT) / 2;
            int right = left + SCAN_AREA_WIDTH;
            int bottom = top + SCAN_AREA_HEIGHT;

            // Draw semi-transparent overlay outside scan area
            canvas.drawRect(0, 0, width, top, overlayPaint); // Top
            canvas.drawRect(0, top, left, bottom, overlayPaint); // Left
            canvas.drawRect(right, top, width, bottom, overlayPaint); // Right
            canvas.drawRect(0, bottom, width, height, overlayPaint); // Bottom

            // Draw white rectangle for scan area
            canvas.drawRect(left, top, right, bottom, boxPaint);
        }
    }



    private void setupBarcodeDetector() {
        barcodeDetector = new BarcodeDetector.Builder(context)
                .setBarcodeFormats(Barcode.ALL_FORMATS)
                .build();

        barcodeDetector.setProcessor(new Detector.Processor<Barcode>() {
            @Override
            public void release() {}

            @Override
            public void receiveDetections(Detector.Detections<Barcode> detections) { if (!isDetecting) return;

                final android.util.SparseArray<Barcode> barcodes = detections.getDetectedItems();

                if (barcodes.size() > 0) {
                    // Get the preview size from camera parameters
                    Camera camera = getCamera();
                    Camera.Parameters parameters = camera.getParameters();
                    Camera.Size previewSize = parameters.getPreviewSize();

                    // Calculate scaling factors
                    float scaleX = (float) surfaceView.getWidth() / previewSize.width;
                    float scaleY = (float) surfaceView.getHeight() / previewSize.height;

                    // Calculate scan area in normalized coordinates
                    int scanAreaLeft = (surfaceView.getWidth() - SCAN_AREA_WIDTH) / 2;
                    int scanAreaTop = (surfaceView.getHeight() - SCAN_AREA_HEIGHT) / 2;

                    RectF scanArea = new RectF(
                            scanAreaLeft,
                            scanAreaTop,
                            scanAreaLeft + SCAN_AREA_WIDTH,
                            scanAreaTop + SCAN_AREA_HEIGHT
                    );

                    for (int i = 0; i < barcodes.size(); i++) {
                        Barcode barcode = barcodes.valueAt(i);

                        // Scale the barcode coordinates to match the preview view
                        RectF scaledBarcodeRect = new RectF(
                                barcode.getBoundingBox().left * scaleX,
                                barcode.getBoundingBox().top * scaleY,
                                barcode.getBoundingBox().right * scaleX,
                                barcode.getBoundingBox().bottom * scaleY
                        );

                        // Check if the scaled barcode intersects with the scan area
                        if (RectF.intersects(scanArea, scaledBarcodeRect)) {
                            // Calculate overlap percentage
                            RectF intersection = new RectF();
                            intersection.setIntersect(scanArea, scaledBarcodeRect);
                            float overlapArea = intersection.width() * intersection.height();
                            float barcodeArea = scaledBarcodeRect.width() * scaledBarcodeRect.height();
                            float overlapPercentage = (overlapArea / barcodeArea) * 100;
                            System.out.println("Overlap percentage: " + overlapPercentage);
                            // If more than 100% of the barcode is within the scan area
                            if (overlapPercentage >= 100) {

                                mainHandler.post(() ->
                                        methodChannel.invokeMethod("onBarcodeDetected", barcode.rawValue)
                                );
                                return;
                            }
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
                    Log.e(TAG, "Error starting camera: " + e.getMessage());
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