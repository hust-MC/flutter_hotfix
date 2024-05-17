package com.example.dyna_flutter;

import android.util.Log;

import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;

public class JsExecutor {
    private final String TAG = "DynaFlutterNative";
    private final String INVOKE_JS_FUNC = "invokeJSFunc";
    private final V8 v8;

    public JsExecutor() {
        v8 = V8.createV8Runtime();
        V8Object console = new V8Object(v8);

        // JS console日志环境添加
        v8.add("console", console);
        console.registerJavaMethod((receiver, parameters) -> {
            Log.d(TAG, "JSLog-" + parameters.get(0));
        }, "log");
    }

    public Object executeFunction(Object src) {
        try {
            V8Array array = new V8Array(v8);
            array.push(src.toString());
            return v8.executeFunction(INVOKE_JS_FUNC, array);
        } catch (Exception e) {
            Log.e(TAG, "Invoke js func error: " + e.getMessage());
            return null;
        }
    }

    public String executeJs(String jsCode) {
        try {
            return v8.executeScript(jsCode).toString();
        } catch (Exception e) {
            Log.e(TAG, "Invoke js error: " + e.getMessage());
            return null;
        }
    }

}
