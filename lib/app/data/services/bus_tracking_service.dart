import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_location.dart';

class BusTrackingService {
  static BusTrackingService? _instance;

  BusTrackingService._();

  factory BusTrackingService() {
    _instance ??= BusTrackingService._();
    return _instance!;
  }

  final _supabase = Supabase.instance.client;

  // Configuración
  static const int BUS_NUMBER = 1; // Número del bus
  static const Duration UPDATE_INTERVAL = Duration(seconds: 5);

  Timer? _updateTimer;
  StreamSubscription? _busLocationSubscription;

  /// Reporta la ubicación del usuario llamando a la Edge Function
  Future<bool> reportUserInBus(
    String userId,
    LatLng position,
    double accuracy,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'user-location-change',
        body: {
          'user_id': userId,
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );

      if (response.status != 200) {
        print('Error en Edge Function: ${response.status}');
        return false;
      }

      final data = response.data as Map<String, dynamic>?;
      final nearbyCount = data?['nearby_count'] ?? 0;

      print('✅ Ubicación reportada. Usuarios cercanos: $nearbyCount');
      return true;
    } catch (e) {
      print('❌ Error reportando ubicación del usuario: $e');
      return false;
    }
  }

  /// Elimina el reporte del usuario llamando a la Edge Function
  Future<bool> removeUserFromBus(String userId) async {
    try {
      final response = await _supabase.functions.invoke(
        'disconnect-user',
        body: {'user_id': userId, 'radius_meters': 50},
      );

      if (response.status == 200 || response.status == 404) {
        print('✅ Usuario desconectado correctamente');
        return true;
      }

      print('Error desconectando usuario: ${response.status}');
      return false;
    } catch (e) {
      print('❌ Error removiendo usuario del bus: $e');
      return false;
    }
  }

  /// Stream de actualizaciones de la ubicación del bus desde la tabla 'buses'
  Stream<BusLocation?> getBusLocationStream() {
    return _supabase
        .from('buses')
        .stream(primaryKey: ['bus_number'])
        .eq('bus_number', BUS_NUMBER)
        .map((data) {
          if (data.isEmpty) {
            print('ℹ️ No hay datos del bus en este momento');
            return null;
          }

          final busData = data.first;

          // Convertir de la estructura de tu tabla 'buses' a BusLocation
          final busLocation = BusLocation(
            position: LatLng(
              busData['lat'] as double,
              busData['lng'] as double,
            ),
            timestamp: busData['updated_at'] != null
                ? DateTime.parse(busData['updated_at'] as String)
                : DateTime.now(),
            userCount: busData['user_count'] as int? ?? 0,
            isActive: true,
          );

          print('🚌 Bus actualizado: ${busLocation.position}');
          return busLocation;
        });
  }

  /// Inicia el monitoreo automático del bus (envía actualizaciones periódicas)
  void startTracking(String userId) {
    print('🟢 Iniciando tracking para usuario: $userId');
    // El tracking se maneja con el stream de ubicación en el MapController
    // No necesitamos timer aquí ya que la Edge Function se encarga del cálculo
  }

  /// Detiene el monitoreo del bus
  void stopTracking() {
    print('🔴 Deteniendo tracking');
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void dispose() {
    _updateTimer?.cancel();
    _busLocationSubscription?.cancel();
  }
}
