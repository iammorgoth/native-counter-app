package com.example.native_counter_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel

class CounterService : Service() {

    private val binder = null

    companion object {
        const val CHANNEL_ID = "CounterServiceChannel"
        const val ACTION_RESET = "com.example.native_counter_app.ACTION_RESET"
        const val ACTION_INCREMENT = "com.example.native_counter_app.ACTION_INCREMENT"
        const val ACTION_DECREMENT = "com.example.native_counter_app.ACTION_DECREMENT"

        var counter = 0
        private var channel: MethodChannel? = null

        fun setChannel(methodChannel: MethodChannel) {
            channel = methodChannel
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_RESET -> {
                counter = 0
            }
            ACTION_INCREMENT -> {
                counter++
            }
            ACTION_DECREMENT -> {
                counter--
            }
            else -> {
                val notification = createNotification()
                startForeground(1, notification)
            }
        }

        updateNotification()
        sendCounterUpdateToFlutter()

        return START_STICKY
    }

    private fun sendCounterUpdateToFlutter() {
        channel?.invokeMethod("updateCounter", counter)
    }

    private fun updateNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(1, createNotification())
    }

    private fun createNotification(): Notification {
        val resetIntent = Intent(this, ResetReceiver::class.java)
        val resetPendingIntent = PendingIntent.getBroadcast(this, 0, resetIntent, PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Native Counter")
            .setContentText("Current value: $counter")
            .setSmallIcon(R.mipmap.ic_launcher) 
            .addAction(R.mipmap.ic_launcher, "Reset", resetPendingIntent) 
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Counter Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent): IBinder? {
        return binder
    }
}

