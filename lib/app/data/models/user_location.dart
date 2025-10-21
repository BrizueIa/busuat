import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String userId;
  final LatLng position;
  final DateTime timestamp;
  final bool isInBus;
  final double accuracy;

  const UserLocation({
    required this.userId,
    required this.position,
    required this.timestamp,
    this.isInBus = false,
    this.accuracy = 0.0,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['user_id'] as String,
      position: LatLng(json['latitude'] as double, json['longitude'] as double),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isInBus: json['is_in_bus'] as bool? ?? false,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': timestamp.toIso8601String(),
      'is_in_bus': isInBus,
      'accuracy': accuracy,
    };
  }

  UserLocation copyWith({
    String? userId,
    LatLng? position,
    DateTime? timestamp,
    bool? isInBus,
    double? accuracy,
  }) {
    return UserLocation(
      userId: userId ?? this.userId,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      isInBus: isInBus ?? this.isInBus,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}
