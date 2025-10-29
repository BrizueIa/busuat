import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'poi_type.dart';

class PointOfInterest {
  final String id;
  final String name;
  final LatLng position;
  final PoiType type;
  final String? description;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    this.description,
  });

  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      id: json['id'] as String,
      name: json['name'] as String,
      position: LatLng(json['latitude'] as double, json['longitude'] as double),
      type: PoiType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PoiType.facultad,
      ),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'type': type.name,
      'description': description,
    };
  }
}
