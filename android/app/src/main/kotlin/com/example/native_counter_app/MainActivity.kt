package com.example.native_counter_app

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.native_counter_app/counter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        CounterService.setChannel(channel)

        channel.setMethodCallHandler { call, result ->
            val serviceIntent = Intent(this, CounterService::class.java)
            when (call.method) {
                "startService" -> {
                    startService(serviceIntent)
                    result.success(null)
                }
                "getValue" -> {
                    result.success(CounterService.counter)
                }
                "increment" -> {
                    serviceIntent.action = CounterService.ACTION_INCREMENT
                    startService(serviceIntent)
                    result.success(null) 
                }
                "decrement" -> {
                    serviceIntent.action = CounterService.ACTION_DECREMENT
                    startService(serviceIntent)
                    result.success(null) 
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

