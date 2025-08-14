import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'background_location_fetch_platform_interface.dart';
import 'location_data_model.dart';

typedef LocationUpdateCallback = void Function(LocationDataModel locationData);

class BackgroundLocationFetch extends BackgroundLocationFetchPlatform {
  /// Channel that receives location updates from native side
  static const MethodChannel _locationChannel = MethodChannel(
    'location_updates',
  );

  /// Channel to send service start/stop commands to native side
  static const MethodChannel _serviceChannel = MethodChannel(
    'com.example.background_location_fetch/service',
  );

  LocationUpdateCallback? onLocationUpdate;

  BackgroundLocationFetch() {
    // Listen for incoming location updates from native
    _locationChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onLocationUpdate') {
      final latitude = (call.arguments['latitude'] as num).toDouble();
      final longitude = (call.arguments['longitude'] as num).toDouble();
      final timestampMs = call.arguments['timestamp'] as int;

      final locationData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestampMs,
      };

      final locationDataModel = LocationDataModel.fromMap(locationData);

      if (onLocationUpdate != null) {
        onLocationUpdate!(locationDataModel);
      }
    }
    return null;
  }

  Future<bool> _requestPermissions() async {
    // Request notification permission (for foreground service notification)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request location permissions
    var whenInUse = await Permission.locationWhenInUse.request();
    if (!whenInUse.isGranted) return false;

    var always = await Permission.locationAlways.request();
    return always.isGranted;
  }

  /// Starts the foreground location service
  Future<void> startService() async {
    final ok = await _requestPermissions();
    if (!ok) {
      print('Location permissions not granted');
      return;
    }

    try {
      await _serviceChannel.invokeMethod('startLocationService');
      print('Service running');
    } on PlatformException catch (e) {
      print('Error starting service: ${e.message}');
    }
  }

  /// Stops the foreground location service
  Future<void> stopService() async {
    try {
      await _serviceChannel.invokeMethod('stopLocationService');
      print('Service stopped');
    } on PlatformException catch (e) {
      print('Error stopping service: ${e.message}');
    }
  }
}
