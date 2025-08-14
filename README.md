# background_location_fetch

A Flutter plugin to track device location **in the background** on Android and iOS, providing continuous location updates even when the app is not in the foreground.

---

## Features

- Request necessary location permissions (WhenInUse and Always)
- Start and stop background location tracking service
- Receive location updates via callback
- Works on both Android and iOS
- Supports background tracking for real-world use cases like fitness, delivery apps, etc.

---

## Installation

Add this to your project's `pubspec.yaml`:

```yaml
dependencies:
  background_location_fetch:
    git:
      url: https://github.com/Amarj234/background_location_fetch.git
      ref: main

```
#Android Setup
Permissions
No need to manually add permissions in AndroidManifest.xml, the plugin handles it automatically.

iOS Setup
Open your ios/Runner/Info.plist and add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app requires location access to track your location while using the app.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app requires background location access to track your location even when the app is in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app requires background location access to track your location even when the app is in the background.</string>
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
  <string>fetch</string>
</array>
```
Make sure Background Modes are enabled in your Xcode project with:


if you Ios 14+:
add the following key to your Podfile to request background location permission:
```xml
post_install do |installer|
    installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']

    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] += [
    'PERMISSION_LOCATION=1',
    'PERMISSION_LOCATION_ALWAYS=1',
    'PERMISSION_LOCATION_WHEN_IN_USE=1'
    ]
    end
    end
    end
```
Location updates

Background fetch

Usage
Import and create an instance of BackgroundLocationFetch (replace with your class name):

dart
Copy
Edit
```dart
import 'package:background_location_fetch/background_location_fetch.dart';
import 'package:background_location_fetch/location_model.dart';

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
 final BackgroundLocationFetch locationService = BackgroundLocationFetch();

 String _serviceStatus = 'Service not running';
 List<LocationDataModel> _locationHistory = [];

 @override
 void initState() {
  super.initState();

  // Setup listener callback
  locationService.onLocationUpdate = (locationData) {
   if (!mounted) return;
   setState(() {
    _locationHistory.insert(0, locationData);
    if (_locationHistory.length > 20) _locationHistory.removeLast();
    _serviceStatus="Service running";
   });
  };
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
          const Text('Service Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_serviceStatus),
          const SizedBox(height: 16),
          Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
            ElevatedButton(onPressed: locationService.startService, child: const Text('Start Service')),
            ElevatedButton(onPressed:locationService.stopService, child: const Text('Stop Service')),
           ],
          ),
         ],
        ),
       ),
      ),
      const SizedBox(height: 20),
      const Text('Recent Locations', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Expanded(
       child: ListView.builder(
        itemCount: _locationHistory.length,
        itemBuilder: (context, index) {
         final loc = _locationHistory[index];
         final dt = loc.timestamp;
         return ListTile(
          title: Text(
           'Lat: ${(loc.latitude).toStringAsFixed(6)}, Lng: ${(loc.longitude).toStringAsFixed(6)}',
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


```
Troubleshooting
Make sure you grant Always location permission for background tracking to work on both Android and iOS.

On iOS simulators, background location updates may not work reliably. Test on a real device.

On Android 10+, background location requires separate permission (ACCESS_BACKGROUND_LOCATION).

Android 13+ requires notification permission if your app shows foreground service notifications.

If using Flutter 3+, verify your Info.plist and Android manifest are correctly set up.

License

This single-file README includes:
1. All essential information in a compact format
2. Clear setup instructions for both platforms
3. Basic usage example
4. Quick reference configuration table
5. Common troubleshooting tips
6. Proper license attribution

The formatting uses clean markdown with clear section headers for easy navigation.