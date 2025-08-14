class LocationDataModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationDataModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationDataModel.fromMap(Map<String, dynamic> map) {
    return LocationDataModel(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
