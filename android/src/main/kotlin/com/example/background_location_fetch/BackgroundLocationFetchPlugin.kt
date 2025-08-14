package com.example.background_location_fetch

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BackgroundLocationFetchPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

  private lateinit var serviceChannel: MethodChannel
  private lateinit var context: Context

  companion object {
    var locationChannel: MethodChannel? = null
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext

    // Channel for starting/stopping the service
    serviceChannel = MethodChannel(
      binding.binaryMessenger,
      "com.example.background_location_fetch/service"
    )
    serviceChannel.setMethodCallHandler(this)

    // Channel for sending location updates back to Flutter
    locationChannel = MethodChannel(binding.binaryMessenger, "location_updates")
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    serviceChannel.setMethodCallHandler(null)
    locationChannel = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "startLocationService" -> {
        startLocationService()
        result.success(null)
      }
      "stopLocationService" -> {
        stopLocationService()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun startLocationService() {
    val intent = Intent(context, LocationForegroundService::class.java)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      ContextCompat.startForegroundService(context, intent)
    } else {
      context.startService(intent)
    }
  }

  private fun stopLocationService() {
    val intent = Intent(context, LocationForegroundService::class.java)
    context.stopService(intent)
  }
}
