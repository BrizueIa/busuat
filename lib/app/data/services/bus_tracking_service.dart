import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_location.dart';
import '../../modules/map/map_controller.dart';

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
  RealtimeChannel? _realtimeChannel; // ✅ Para guardar referencia al channel

  /// Reporta la ubicación del usuario llamando a la Edge Function
  /// Solo reporta la ubicación, NO retorna las coordenadas del bus
  /// El bus se obtiene vía Realtime stream
  Future<bool> reportUserInBus(
    String userId,
    LatLng position,
    double accuracy,
  ) async {
    try {
      print('🔵 Llamando a Edge Function user-location-change...');
      print('   User ID: $userId');
      print('   Lat: ${position.latitude}, Lng: ${position.longitude}');

      final response = await _supabase.functions.invoke(
        'user-location-change',
        body: {
          'user_id': userId,
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );

      print('📥 Respuesta recibida:');
      print('   Status: ${response.status}');
      print('   Data: ${response.data}');

      if (response.status != 200) {
        print('❌ Error en Edge Function: ${response.status}');
        print('   Response data: ${response.data}');
        return false;
      }

      final data = response.data as Map<String, dynamic>?;
      final nearbyCount = data?['nearby_count'] ?? 0;

      print('✅ Ubicación reportada. Usuarios cercanos: $nearbyCount');
      return true;
    } catch (e) {
      print('❌ Error reportando ubicación del usuario: $e');
      print('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Elimina el reporte del usuario llamando a la Edge Function
  Future<bool> removeUserFromBus(String userId) async {
    try {
      print('🔵 Llamando a Edge Function disconnect-user...');
      print('   User ID: $userId');

      final response = await _supabase.functions.invoke(
        'disconnect-user',
        body: {'user_id': userId, 'radius_meters': 50},
      );

      print('📥 Respuesta recibida:');
      print('   Status: ${response.status}');
      print('   Data: ${response.data}');

      if (response.status == 200 || response.status == 404) {
        print('✅ Usuario desconectado correctamente');
        return true;
      }

      print('❌ Error desconectando usuario: ${response.status}');
      return false;
    } catch (e) {
      print('❌ Error removiendo usuario del bus: $e');
      print('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Stream de actualizaciones de la ubicación del bus desde la tabla 'buses'
  /// ✅ USANDO .channel().onPostgresChanges() (Supabase Flutter v2.9.1)
  Stream<BusLocation?> getBusLocationStream() {
    print('📡 Iniciando Realtime Channel para tabla buses...');
    print('   Bus number: $BUS_NUMBER');
    print('   Método: .channel().onPostgresChanges() ✅');

    final controller = StreamController<BusLocation?>.broadcast();

    // ✅ SINTAXIS CORRECTA para supabase_flutter v2.9.1
    _realtimeChannel = _supabase
        .channel('public:buses')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'bus_number',
            value: BUS_NUMBER,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.delete) {
              controller.add(null);
              return;
            }

            // ✅ Para INSERT/UPDATE
            final busData = payload.newRecord;

            if (busData.isEmpty) {
              controller.add(null);
              return;
            }

            try {
              final lat = busData['lat'];
              final lng = busData['lng'];

              print('   lat: $lat');
              print('   lng: $lng');

              // Leer userCount desde la base de datos
              final userCount = (busData['user_count'] as int?) ?? 0;
              print('   userCount: $userCount');

              final busLocation = BusLocation(
                position: LatLng(
                  (lat as num).toDouble(),
                  (lng as num).toDouble(),
                ),
                timestamp: DateTime.now(),
                userCount: userCount,
                isActive: userCount >= MapController.MIN_USERS_TO_SHOW_BUS,
              );

              // ✅ Agregar al stream
              controller.add(busLocation);
            } catch (e, stackTrace) {
              print('❌ ERROR PARSEANDO: $e');
              print('   Stack: $stackTrace');

              controller.add(null);
            }
          },
        )
        .subscribe((status, error) {
          print('🔌 REALTIME CHANNEL STATUS CHANGE');

          print('   Status: $status');
          print('   Error: $error');
          print('   Timestamp: ${DateTime.now()}');

          if (status == RealtimeSubscribeStatus.subscribed) {
            print('✅ ✅ ✅ CHANNEL CONECTADO EXITOSAMENTE ✅ ✅ ✅\n');
          } else if (status == RealtimeSubscribeStatus.channelError) {
            print('❌ ❌ ❌ ERROR EN CHANNEL: $error ❌ ❌ ❌\n');
          } else if (status == RealtimeSubscribeStatus.timedOut) {
            print('⏰ ⏰ ⏰ TIMEOUT EN CHANNEL ⏰ ⏰ ⏰\n');
          } else if (status == RealtimeSubscribeStatus.closed) {
            print('🔒 🔒 🔒 CHANNEL CERRADO 🔒 🔒 🔒\n');
          }
        });

    print('✅ Channel suscrito exitosamente');
    print('   Esperando eventos INSERT, UPDATE, DELETE...');

    return controller.stream;
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
    print('🧹 Limpiando BusTrackingService...');
    _updateTimer?.cancel();

    // ✅ Remover el channel de Realtime
    if (_realtimeChannel != null) {
      print('   Removiendo channel de Realtime...');
      _supabase.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }
}
