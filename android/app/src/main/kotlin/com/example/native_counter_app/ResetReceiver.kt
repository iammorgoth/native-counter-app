package com.example.native_counter_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ResetReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val serviceIntent = Intent(context, CounterService::class.java).apply {
            action = CounterService.ACTION_RESET
        }
        context.startService(serviceIntent)
    }
}
