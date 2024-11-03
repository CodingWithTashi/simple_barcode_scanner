package com.amolg.flutterbarcodescanner.widget;

import java.util.Map;


public class ParamData {
    private final String key;
    private final Integer scanType;
    private final Integer cameraFace;
    private final Long delayMillis;
    private final Boolean continuous;
    private final Integer scannerWidth;
    private final Integer scannerHeight;

    // Constructor
    public ParamData(String key, Integer scanType, Integer cameraFace, Long delayMillis, Boolean continuous, Integer scannerWidth, Integer scannerHeight) {
        this.key = key;
        this.scanType = scanType;
        this.cameraFace = cameraFace;
        this.delayMillis = delayMillis;
        this.continuous = continuous;
        this.scannerWidth = scannerWidth;
        this.scannerHeight = scannerHeight;
    }

    // Getters
    public String getKey() {
        return key;
    }

    public Integer getScanType() {
        return scanType;
    }

    public Integer getCameraFace() {
        return cameraFace;
    }

    public Long getDelayMillis() {
        return delayMillis;
    }

    public Boolean isContinuous() {
        return continuous;
    }

    public Integer getScannerWidth() {
        return scannerWidth;
    }

    public Integer getScannerHeight() {
        return scannerHeight;
    }

    // Method to create an instance from a Map
    public static ParamData fromMap(Map<String, Object> map) {
        String key = (String) map.get("key");
        Integer scanType = (Integer) map.get("scanType");
        Integer cameraFace = (Integer) map.get("cameraFace");
        Long delayMillis = (Long) map.get("delayMillis");
        Boolean continuous = (Boolean) map.get("continuous");
        Integer scannerWidth = (Integer) map.get("scannerWidth");
        Integer scannerHeight = (Integer) map.get("scannerHeight");
        return new ParamData(key, scanType, cameraFace, delayMillis, continuous, scannerWidth, scannerHeight);
    }
}