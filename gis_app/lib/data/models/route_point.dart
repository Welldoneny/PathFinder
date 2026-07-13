class RoutePoint {
  final double latitude;
  final double longitude;
  double? altitude;

  RoutePoint({required this.latitude, required this.longitude, this.altitude});

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lng': longitude,
    'alt': altitude,
  };
  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lng'] as num).toDouble(),
    altitude: json['alt'] != null ? (json['alt'] as num).toDouble() : null,
  );
}
