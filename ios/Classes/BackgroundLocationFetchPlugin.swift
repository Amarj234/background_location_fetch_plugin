import Flutter
import UIKit
import CoreLocation

public class BackgroundLocationFetchPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {

  private var locationManager: CLLocationManager?
  private var locationChannel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = BackgroundLocationFetchPlugin()

    // Service control channel (just for API compatibility with Android)
    let serviceChannel = FlutterMethodChannel(
        name: "com.example.background_location_fetch/service",
        binaryMessenger: registrar.messenger()
    )

    serviceChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "startLocationService":
        instance.startLocationService()
        result(nil)
      case "stopLocationService":
        instance.stopLocationService()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Channel for sending location updates
    let locationChannel = FlutterMethodChannel(
        name: "location_updates",
        binaryMessenger: registrar.messenger()
    )
    instance.locationChannel = locationChannel
  }

  private func startLocationService() {
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      locationManager?.allowsBackgroundLocationUpdates = true
      locationManager?.pausesLocationUpdatesAutomatically = false
    }

    DispatchQueue.main.async {
      self.locationManager?.requestAlwaysAuthorization()
      self.locationManager?.startUpdatingLocation()
    }
  }


  private func stopLocationService() {
    locationManager?.stopUpdatingLocation()
    print("iOS Location Service Stopped")
  }

  // CLLocationManagerDelegate
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }

    let args: [String: Any] = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
      "timestamp": Int(location.timestamp.timeIntervalSince1970 * 1000)
    ]

    DispatchQueue.main.async {
      self.locationChannel?.invokeMethod("onLocationUpdate", arguments: args)
    }
  }

  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("iOS Location error: \(error.localizedDescription)")
  }
}
