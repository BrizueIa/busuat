import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static LocationService? _instance;

  LocationService._();

  factory LocationService() {
    _instance ??= LocationService._();
    return _instance!;
  }

  Stream<Position>? _positionStream;

  /// Verifica si los permisos de ubicación están otorgados
  Future<bool> checkPermissions() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Solicita permisos de ubicación
  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      // Intenta solicitar permisos de ubicación precisa
      final preciseStatus = await Permission.locationWhenInUse.request();
      return preciseStatus.isGranted;
    }
    return status.isGranted;
  }

  /// Verifica si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtiene la ubicación actual del usuario
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Verifica si el servicio está habilitado
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Verifica permisos
      bool hasPermission = await checkPermissions();
      if (!hasPermission) {
        hasPermission = await requestPermissions();
        if (!hasPermission) {
          return null;
        }
      }

      // Obtiene la posición actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Stream de ubicación en tiempo real
  Stream<Position> getLocationStream() {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Actualiza cada 5 metros
        timeLimit: Duration(seconds: 10),
      ),
    );
    return _positionStream!;
  }

  /// Calcula la distancia entre dos puntos en metros
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Verifica si un punto está dentro de un radio específico de otro punto
  bool isWithinRadius(LatLng point1, LatLng point2, double radiusInMeters) {
    final distance = calculateDistance(point1, point2);
    return distance <= radiusInMeters;
  }

  /// Calcula el punto medio de una lista de coordenadas
  LatLng? calculateCentroid(List<LatLng> points) {
    if (points.isEmpty) return null;

    double totalLat = 0;
    double totalLng = 0;

    for (var point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(totalLat / points.length, totalLng / points.length);
  }

  /// Abre la configuración de la aplicación
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Abre la configuración de ubicación del dispositivo
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
