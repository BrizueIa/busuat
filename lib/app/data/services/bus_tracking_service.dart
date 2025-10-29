import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_location.dart';
import '../models/user_location.dart';
import '../../core/services/location_service.dart';

class BusTrackingService {
  static BusTrackingService? _instance;

  BusTrackingService._();

  factory BusTrackingService() {
    _instance ??= BusTrackingService._();
    return _instance!;
  }

  final _supabase = Supabase.instance.client;
  final _locationService = LocationService();

  // Configuración
  static const double BUS_DETECTION_RADIUS = 8.0; // metros
  static const int MIN_USERS_FOR_BUS =
      3; // mínimo de usuarios para considerar que hay un bus
  static const Duration UPDATE_INTERVAL = Duration(seconds: 5);
  static const Duration USER_TIMEOUT = Duration(
    minutes: 2,
  ); // timeout para considerar usuario inactivo

  Timer? _updateTimer;
  StreamSubscription? _busLocationSubscription;

  /// Reporta la ubicación del usuario indicando que está en el bus
  Future<bool> reportUserInBus(
    String userId,
    LatLng position,
    double accuracy,
  ) async {
    try {
      final userLocation = UserLocation(
        userId: userId,
        position: position,
        timestamp: DateTime.now(),
        isInBus: true,
        accuracy: accuracy,
      );

      await _supabase
          .from('user_locations')
          .upsert(userLocation.toJson(), onConflict: 'user_id');

      return true;
    } catch (e) {
      print('Error reportando ubicación del usuario: $e');
      return false;
    }
  }

  /// Elimina el reporte del usuario (ya no está en el bus)
  Future<bool> removeUserFromBus(String userId) async {
    try {
      await _supabase.from('user_locations').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error removiendo usuario del bus: $e');
      return false;
    }
  }

  /// Obtiene todos los usuarios que reportan estar en el bus
  Future<List<UserLocation>> getUsersInBus() async {
    try {
      final cutoffTime = DateTime.now().subtract(USER_TIMEOUT);

      final response = await _supabase
          .from('user_locations')
          .select()
          .eq('is_in_bus', true)
          .gte('timestamp', cutoffTime.toIso8601String());

      return (response as List)
          .map((json) => UserLocation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios en el bus: $e');
      return [];
    }
  }

  /// Calcula la ubicación del bus basándose en los usuarios reportados
  Future<BusLocation?> calculateBusLocation() async {
    try {
      final users = await getUsersInBus();

      if (users.length < MIN_USERS_FOR_BUS) {
        // No hay suficientes usuarios para determinar la ubicación del bus
        return null;
      }

      // Agrupa usuarios que están cerca entre sí (dentro del radio)
      final clusters = _clusterUsers(users, BUS_DETECTION_RADIUS);

      // Encuentra el cluster más grande
      if (clusters.isEmpty) return null;

      final largestCluster = clusters.reduce(
        (a, b) => a.length > b.length ? a : b,
      );

      if (largestCluster.length < MIN_USERS_FOR_BUS) {
        return null;
      }

      // Calcula el centroide del cluster
      final positions = largestCluster.map((u) => u.position).toList();
      final busPosition = _locationService.calculateCentroid(positions);

      if (busPosition == null) return null;

      final busLocation = BusLocation(
        position: busPosition,
        timestamp: DateTime.now(),
        userCount: largestCluster.length,
        isActive: true,
      );

      // Guarda la ubicación del bus en Supabase
      await _supabase.from('bus_locations').upsert(busLocation.toJson());

      return busLocation;
    } catch (e) {
      print('Error calculando ubicación del bus: $e');
      return null;
    }
  }

  /// Agrupa usuarios que están cerca entre sí
  List<List<UserLocation>> _clusterUsers(
    List<UserLocation> users,
    double radius,
  ) {
    final List<List<UserLocation>> clusters = [];
    final Set<String> processed = {};

    for (var user in users) {
      if (processed.contains(user.userId)) continue;

      final cluster = <UserLocation>[user];
      processed.add(user.userId);

      for (var otherUser in users) {
        if (processed.contains(otherUser.userId)) continue;

        final distance = _locationService.calculateDistance(
          user.position,
          otherUser.position,
        );

        if (distance <= radius) {
          cluster.add(otherUser);
          processed.add(otherUser.userId);
        }
      }

      clusters.add(cluster);
    }

    return clusters;
  }

  /// Stream de actualizaciones de la ubicación del bus
  Stream<BusLocation?> getBusLocationStream() {
    return _supabase
        .from('bus_locations')
        .stream(primaryKey: ['timestamp'])
        .order('timestamp', ascending: false)
        .limit(1)
        .map((data) {
          if (data.isEmpty) return null;

          final busLocation = BusLocation.fromJson(data.first);

          // Verifica si la ubicación es reciente
          final age = DateTime.now().difference(busLocation.timestamp);
          if (age > USER_TIMEOUT) {
            return null;
          }

          return busLocation;
        });
  }

  /// Inicia el monitoreo automático del bus
  void startTracking(String userId) {
    _updateTimer?.cancel();

    _updateTimer = Timer.periodic(UPDATE_INTERVAL, (timer) async {
      await calculateBusLocation();
    });
  }

  /// Detiene el monitoreo del bus
  void stopTracking() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Limpia ubicaciones antiguas
  Future<void> cleanOldLocations() async {
    try {
      final cutoffTime = DateTime.now().subtract(USER_TIMEOUT);

      await _supabase
          .from('user_locations')
          .delete()
          .lt('timestamp', cutoffTime.toIso8601String());
    } catch (e) {
      print('Error limpiando ubicaciones antiguas: $e');
    }
  }

  void dispose() {
    _updateTimer?.cancel();
    _busLocationSubscription?.cancel();
  }
}
