import 'dart:async';
import 'package:flutter/services.dart';

class BackgroundLocationRunner {
  // Channel names kept same as your working example
  static const MethodChannel _serviceChannel = MethodChannel(
    'com.example.background_location_runner/service',
  );
  static const MethodChannel _locationChannel = MethodChannel(
    'location_updates',
  );

  static final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();

  static bool _initialized = false;

  /// Call once (or rely on lazy init via [onLocation]).
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    _locationChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onLocationUpdate') {
        final map = Map<dynamic, dynamic>.from(call.arguments as Map);
        final update = LocationUpdate(
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          timestamp: (map['timestamp'] as num).toInt(),
        );
        _controller.add(update);
      }
    });
  }

  /// Starts the Android foreground service that produces location updates.
  static Future<void> start() async {
    initialize();
    await _serviceChannel.invokeMethod('startLocationService');
  }

  /// Stops the Android foreground service.
  static Future<void> stop() async {
    await _serviceChannel.invokeMethod('stopLocationService');
  }

  /// Listen to location updates.
  static Stream<LocationUpdate> get onLocation {
    initialize();
    return _controller.stream;
  }
}

class LocationUpdate {
  final double latitude;
  final double longitude;
  final int timestamp; // epoch millis

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  String toString() =>
      'LocationUpdate(lat: $latitude, lng: $longitude, ts: $timestamp)';
}
