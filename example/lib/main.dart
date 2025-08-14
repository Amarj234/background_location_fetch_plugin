import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LocationTrackerScreen());
  }
}

class LocationTrackerScreen extends StatefulWidget {
  const LocationTrackerScreen({super.key});

  @override
  State<LocationTrackerScreen> createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  final _serviceChannel = const MethodChannel(
    'com.example.background_location_fetch/service',
  );
  final _locationChannel = const MethodChannel('location_updates');

  String _serviceStatus = 'Service not running';
  List<Map<String, dynamic>> _locationHistory = [];

  @override
  void initState() {
    super.initState();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    try {
      _locationChannel.setMethodCallHandler((call) async {
        if (call.method == 'onLocationUpdate' && mounted) {
          final latitude = (call.arguments['latitude'] as num).toDouble();
          final longitude = (call.arguments['longitude'] as num).toDouble();
          final timestampMs = call.arguments['timestamp'] as int;
          final locationData = {
            'latitude': latitude,
            'longitude': longitude,
            'timestamp': DateTime.fromMillisecondsSinceEpoch(timestampMs),
          };

          setState(() {
            _locationHistory.insert(0, locationData);
            if (_locationHistory.length > 20) _locationHistory.removeLast();
          });
        }
      });
    } catch (e) {
      print("object $e");
    }
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request When In Use first
    var whenInUse = await Permission.locationWhenInUse.request();
    if (!whenInUse.isGranted) return false;

    // Request Always (might need manual settings change)
    var always = await Permission.locationAlways.request();
    if (!always.isGranted) {
      // Direct user to Settings
      openAppSettings();
      return false;
    }

    return true;
  }

  Future<void> _startService() async {
    final ok = await _requestPermissions();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please allow "Always" location permission.'),
        ),
      );
      return;
    }

    try {
      await _serviceChannel.invokeMethod('startLocationService');
      setState(() {
        _serviceStatus = 'Service running';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location service started')));
    } on PlatformException catch (e) {
      setState(() {
        _serviceStatus = 'Failed to start service';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _stopService() async {
    try {
      await _serviceChannel.invokeMethod('stopLocationService');
      setState(() {
        _serviceStatus = 'Service stopped';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location service stopped')));
    } on PlatformException catch (e) {
      setState(() {
        _serviceStatus = 'Failed to stop service';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Background Location Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Service Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_serviceStatus),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _startService,
                          child: const Text('Start Service'),
                        ),
                        ElevatedButton(
                          onPressed: _stopService,
                          child: const Text('Stop Service'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Locations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _locationHistory.length,
                itemBuilder: (context, index) {
                  final loc = _locationHistory[index];
                  final dt = loc['timestamp'] as DateTime;
                  return ListTile(
                    title: Text(
                      'Lat: ${(loc['latitude'] as double).toStringAsFixed(6)}, Lng: ${(loc['longitude'] as double).toStringAsFixed(6)}',
                    ),
                    subtitle: Text('Time: $dt'),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
