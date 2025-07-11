package com.amolg.flutterbarcodescanner;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.amolg.flutterbarcodescanner.widget.BarcodeViewFactory;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.vision.barcode.Barcode;

import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;


/**
 * FlutterBarcodeScannerPlugin
 */
public class FlutterBarcodeScannerPlugin implements MethodCallHandler, ActivityResultListener, StreamHandler, FlutterPlugin, ActivityAware {
    private static final String CHANNEL = "flutter_barcode_scanner";

    private static FlutterActivity activity;
    private static Result pendingResult;
    private Map<String, Object> arguments;

    private static final String TAG = FlutterBarcodeScannerPlugin.class.getSimpleName();
    private static final int RC_BARCODE_CAPTURE = 9001;
    public static String lineColor = "";
    public static boolean isShowFlashIcon = false;
    public static boolean isContinuousScan = false;
    public static String cameraFacingText = "";
    public static int delayMillis = 0;
    static EventChannel.EventSink barcodeStream;
    private EventChannel eventChannel;

    /**
     * V2 embedding
     *
     * @param activity
     */
    private MethodChannel channel;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application applicationContext;
    // This is null when not using v2 embedding;
    private Lifecycle lifecycle;
    private LifeCycleObserver observer;

    public FlutterBarcodeScannerPlugin() {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            pendingResult = result;

            if (call.method.equals("scanBarcode")) {
                if (!(call.arguments instanceof Map)) {
                    throw new IllegalArgumentException("Plugin not passing a map as parameter: " + call.arguments);
                }
                arguments = (Map<String, Object>) call.arguments;
                lineColor = (String) arguments.get("lineColor");
                isShowFlashIcon = (boolean) arguments.get("isShowFlashIcon");
                if (null == lineColor || lineColor.equalsIgnoreCase("")) {
                    lineColor = "#DC143C";
                }
                if (null != arguments.get("scanMode")) {
                    if ((int) arguments.get("scanMode") == BarcodeCaptureActivity.SCAN_MODE_ENUM.DEFAULT.ordinal()) {
                        BarcodeCaptureActivity.SCAN_MODE = BarcodeCaptureActivity.SCAN_MODE_ENUM.QR.ordinal();
                    } else {
                        BarcodeCaptureActivity.SCAN_MODE = (int) arguments.get("scanMode");
                    }
                } else {
                    BarcodeCaptureActivity.SCAN_MODE = BarcodeCaptureActivity.SCAN_MODE_ENUM.QR.ordinal();
                }

                setScanFormat();

                isContinuousScan = (boolean) arguments.get("isContinuousScan");

                cameraFacingText = (String) arguments.get("cameraFacingText");

                if (null != arguments.get("delayMillis"))
                    delayMillis = (int) arguments.get("delayMillis");


                startBarcodeScannerActivityView((String) arguments.get("cancelButtonText"), isContinuousScan,cameraFacingText);
            }
        } catch (Exception e) {
            Log.e(TAG, "onMethodCall: " + e.getLocalizedMessage());
        }
    }

    private void setScanFormat() {
        BarcodeCaptureActivity.SCAN_FORMAT_ENUM format = BarcodeCaptureActivity.SCAN_FORMAT_ENUM.ALL_FORMATS;
        if (null != arguments.get("scanFormat")) {
            String scanFormat = (String) arguments.get("scanFormat");

            assert scanFormat != null;
            switch (scanFormat.toUpperCase()) {
                case "ONLY_QR_CODE":
                    format = BarcodeCaptureActivity.SCAN_FORMAT_ENUM.ONLY_QR_CODE;
                    break;
                case "ONLY_BARCODE":
                    format = BarcodeCaptureActivity.SCAN_FORMAT_ENUM.ONLY_BARCODE;
                    break;
            }
        }
        BarcodeCaptureActivity.SCAN_FORMAT = format;
    }

    private void startBarcodeScannerActivityView(String buttonText, boolean isContinuousScan, String cameraFacingText) {
        try {
            Intent intent = new Intent(activity, BarcodeCaptureActivity.class).putExtra("cancelButtonText", buttonText)
                    .putExtra("delayMillis", delayMillis)
                    .putExtra("cameraFacingText", cameraFacingText);
            if (isContinuousScan) {
                activity.startActivity(intent);
            } else {
                activity.startActivityForResult(intent, RC_BARCODE_CAPTURE);
            }
        } catch (Exception e) {
            Log.e(TAG, "startView: " + e.getLocalizedMessage());
        }
    }


    /**
     * Get the barcode scanning results in onActivityResult
     *
     * @param requestCode
     * @param resultCode
     * @param data
     * @return
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == RC_BARCODE_CAPTURE) {
            if (resultCode == CommonStatusCodes.SUCCESS) {
                if (data != null) {
                    try {
                        Barcode barcode = data.getParcelableExtra(BarcodeCaptureActivity.BarcodeObject);
                        String barcodeResult = barcode.rawValue;
                        pendingResult.success(barcodeResult);
                    } catch (Exception e) {
                        pendingResult.success("-1");
                    }
                } else {
                    pendingResult.success("-1");
                }
                pendingResult = null;
                arguments = null;
                return true;
            } else {
                pendingResult.success("-1");
            }
        }
        return false;
    }


    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        try {
            barcodeStream = eventSink;
        } catch (Exception e) {
        }
    }

    @Override
    public void onCancel(Object o) {
        try {
            barcodeStream = null;
        } catch (Exception e) {

        }
    }

    /**
     * Continuous receive barcode
     *
     * @param barcode
     */
    public static void onBarcodeScanReceiver(final Barcode barcode) {
        try {
            if (barcode != null && !barcode.displayValue.isEmpty()) {
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        barcodeStream.success(barcode.rawValue);
                    }
                });
            }
        } catch (Exception e) {
            Log.e(TAG, "onBarcodeScanReceiver: " + e.getLocalizedMessage());
        }
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        pluginBinding = binding;
        binding.getPlatformViewRegistry().registerViewFactory(
                "plugins.codingwithtashi/barcode_scanner_view",
                new BarcodeViewFactory(binding.getBinaryMessenger())
        );
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        pluginBinding = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    /**
     * Setup method
     * Created after Embedding V2 API release
     *
     * @param messenger
     * @param applicationContext
     * @param activity
     * @param activityBinding
     */
    private void createPluginSetup(
            final BinaryMessenger messenger,
            final Application applicationContext,
            final Activity activity,
            final ActivityPluginBinding activityBinding) {


        this.activity = (FlutterActivity) activity;
        eventChannel =
                new EventChannel(messenger, "flutter_barcode_scanner_receiver");
        eventChannel.setStreamHandler(this);


        this.applicationContext = applicationContext;
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler(this);
        // V2 embedding setup for activity listeners.
        activityBinding.addActivityResultListener(this);
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityBinding);
        observer = new LifeCycleObserver(activity);
        lifecycle.addObserver(observer);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activityBinding = binding;
        createPluginSetup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                activityBinding.getActivity(),
                activityBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        clearPluginSetup();
    }

    /**
     * Clear plugin setup
     */
    private void clearPluginSetup() {
        activity = null;
        activityBinding.removeActivityResultListener(this);
        activityBinding = null;
        lifecycle.removeObserver(observer);
        lifecycle = null;
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        channel = null;
        applicationContext.unregisterActivityLifecycleCallbacks(observer);
        applicationContext = null;
    }

    /**
     * Activity lifecycle observer
     */
    private class LifeCycleObserver
            implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
        private final Activity thisActivity;

        LifeCycleObserver(Activity activity) {
            this.thisActivity = activity;
        }

        @Override
        public void onCreate(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStart(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onResume(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onPause(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStop(@NonNull LifecycleOwner owner) {
            onActivityStopped(thisActivity);
        }

        @Override
        public void onDestroy(@NonNull LifecycleOwner owner) {
            onActivityDestroyed(thisActivity);
        }

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        }

        @Override
        public void onActivityStarted(Activity activity) {
        }

        @Override
        public void onActivityResumed(Activity activity) {
        }

        @Override
        public void onActivityPaused(Activity activity) {
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (thisActivity == activity && activity.getApplicationContext() != null) {
                ((Application) activity.getApplicationContext())
                        .unregisterActivityLifecycleCallbacks(
                                this);
            }
        }

        @Override
        public void onActivityStopped(Activity activity) {

        }
    }
}