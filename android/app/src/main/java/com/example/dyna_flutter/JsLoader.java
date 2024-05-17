package com.example.dyna_flutter;

import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class JsLoader {

    private final String TAG = "DynaFlutterNative";
    private final String FLUTTER_METHOD_CHANNEL_NAME = "method_channel";

    private final String METHOD_LOAD_JS = "loadMainJs";
    private final String METHOD_GET_VARIABLE = "getVariable";
    private MethodChannel methodChannel;

    private JsExecutor jsExecutor = new JsExecutor();

    public JsLoader(BinaryMessenger binaryMessenger) {
        methodChannel = new MethodChannel(binaryMessenger, FLUTTER_METHOD_CHANNEL_NAME);
        methodChannel.setMethodCallHandler(methodCallHandler);
    }

    private MethodChannel.MethodCallHandler methodCallHandler = (call, result) -> {
        Log.i(TAG, "method: " + call.method);
        Log.i(TAG, "arguments: " + call.arguments);

        switch (call.method) {
            case METHOD_GET_VARIABLE:
                Object funResult = jsExecutor.executeFunction(call.arguments);
                Log.i(TAG, "funResult: " + funResult);
                result.success(funResult);
                break;
            case METHOD_LOAD_JS:
                // 提前注入JS基础文件，保证JS方法能够调用
                try {
                    JSONObject jsonObject = new JSONObject(String.valueOf(call.arguments));
                    String script = jsonObject.getString("path");
                    jsExecutor.executeJs(script);
                    Log.i(TAG, "Load main js successful");

                    result.success("Load main js successful");
                } catch (JSONException e) {
                    Log.e(TAG, "arguments is not a json String");
                }
            default:
                break;
        }
    };
}
