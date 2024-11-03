package com.amolg.flutterbarcodescanner.widget;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.StandardMessageCodec;

public class BarcodeViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public BarcodeViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object creationParams) {
        return new FlutterBarcodeView(context, messenger, id,creationParams);
    }
}