import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusLocation {
  final LatLng position;
  final DateTime timestamp;
  final int userCount;
  final bool isActive;

  const BusLocation({
    required this.position,
    required this.timestamp,
    required this.userCount,
    this.isActive = true,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      position: LatLng(json['latitude'] as double, json['longitude'] as double),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userCount: json['user_count'] as int,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': timestamp.toIso8601String(),
      'user_count': userCount,
      'is_active': isActive,
    };
  }

  BusLocation copyWith({
    LatLng? position,
    DateTime? timestamp,
    int? userCount,
    bool? isActive,
  }) {
    return BusLocation(
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      userCount: userCount ?? this.userCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
