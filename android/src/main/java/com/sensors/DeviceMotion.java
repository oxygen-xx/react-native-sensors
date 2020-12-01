package com.sensors;

import android.os.Bundle;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class DeviceMotion extends ReactContextBaseJavaModule implements SensorEventListener {

  private final ReactApplicationContext reactContext;
  private final SensorManager sensorManager;
//  private final Sensor sensor;

  private final Sensor aSensor;
  private final Sensor mSensor;
  private double lastReading = (double) System.currentTimeMillis();
  private int interval;
  private Arguments arguments;

  float[] accelerometerValues = new float[3];
  float[] magneticFieldValues = new float[3];

  public DeviceMotion(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.sensorManager = (SensorManager)reactContext.getSystemService(reactContext.SENSOR_SERVICE);
//    this.sensor = this.sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY);
    aSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
    mSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
  }

  // RN Methods
  @ReactMethod
  public void setUpdateInterval(int newInterval) {
    this.interval = newInterval;
  }

  @ReactMethod
  public void startUpdates(Promise promise) {
    if (this.aSensor == null || this.mSensor == null) {
      // No sensor found, throw error
      promise.reject(new RuntimeException("No DeviceMotion found"));
      return;
    }
    promise.resolve(null);
    // Milisecond to Mikrosecond conversion
//    sensorManager.registerListener(this, sensor, this.interval * 1000);
    sensorManager.registerListener(this, aSensor, this.interval * 1000);
    sensorManager.registerListener(this, mSensor,this.interval * 1000);
  }

  @ReactMethod
  public void stopUpdates() {
    sensorManager.unregisterListener(this);
  }

  @Override
  public String getName() {
    return "DeviceMotion";
  }

  // SensorEventListener Interface
  private void sendEvent(String eventName, @Nullable WritableMap params) {
    try {
      this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
              .emit(eventName, params);
    } catch (RuntimeException e) {
      Log.e("ERROR", "java.lang.RuntimeException: Trying to invoke Javascript before CatalystInstance has been set!");
    }
  }

  @Override
  public void onSensorChanged(SensorEvent sensorEvent) {
    double tempMs = (double) System.currentTimeMillis();
    if (tempMs - lastReading >= interval){
      lastReading = tempMs;

      Sensor mySensor = sensorEvent.sensor;
      WritableMap map = arguments.createMap();

      if (mySensor.getType() == Sensor.TYPE_MAGNETIC_FIELD || sensorEvent.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
        if(sensorEvent.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
          magneticFieldValues = sensorEvent.values;
        else if (sensorEvent.sensor.getType() == Sensor.TYPE_ACCELEROMETER){
          accelerometerValues = sensorEvent.values;

        }
        WritableMap attitude = arguments.createMap();
        float[] values = new float[3];
        float[] R = new float[9];
        SensorManager.getRotationMatrix(R, null, accelerometerValues, magneticFieldValues);
        SensorManager.getOrientation(R, values);
        float[] ori = SensorManager.getOrientation(R,values);
        attitude.putDouble("pitch", ori[1]);
        attitude.putDouble("roll", ori[2]);
        attitude.putDouble("yaw", ori[0]);
        map.putMap("attitude",attitude);
        map.putDouble("timestamp", (double) System.currentTimeMillis());
        System.out.println("pitch:"+ori[1]+",roll:"+ori[2]+",yaw:"+ori[0]);
        sendEvent("DeviceMotion", map);
      }


    }
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }
}
