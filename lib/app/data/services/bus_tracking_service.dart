import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_location.dart';
import '../../modules/map/map_controller.dart';

class BusTrackingService {
  // Control de logging desde MapController
  static bool get _debug => MapController.ENABLE_DEBUG_LOGS;
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

      print('📥 RESPUESTA DE EDGE FUNCTION user-location-change:');
      print('   Status: ${response.status}');
      print('   Data completa: ${response.data}');

      if (response.status != 200) {
        print('❌ Error en Edge Function: ${response.status}');
        print('   Response data: ${response.data}');
        return false;
      }

      final data = response.data as Map<String, dynamic>?;
      final nearbyCount = data?['nearby_count'] ?? 0;
      final userCount = data?['user_count'] ?? 0; // ← Ver si viene user_count

      print('✅ Ubicación reportada exitosamente');
      print('   nearby_count de respuesta: $nearbyCount');
      print('   user_count de respuesta: $userCount');
      print('   ⚠️ NOTA: La tabla buses debería tener user_count = $userCount');

      return true;
    } catch (e) {
      print('❌ Error reportando ubicación del usuario: $e');
      if (_debug) print('   Stack trace: ${StackTrace.current}');
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

      print('📥 RESPUESTA DE disconnect-user:');
      print('   Status: ${response.status}');
      print('   Data: ${response.data}');

      if (response.status == 200 || response.status == 404) {
        print('✅ Usuario desconectado correctamente');
        print('⏳ Esperando evento DELETE de Realtime...');
        return true;
      }

      print('❌ Error desconectando usuario: ${response.status}');
      return false;
    } catch (e) {
      print('❌ Error removiendo usuario del bus: $e');
      if (_debug) print('   Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Stream de actualizaciones de la ubicación del bus desde la tabla 'buses'
  /// ✅ USANDO .channel().onPostgresChanges() (Supabase Flutter v2.9.1)
  Stream<BusLocation?> getBusLocationStream() {
    if (_debug) {
      print('📡 Iniciando Realtime Channel para tabla buses...');
      print('   Bus number: $BUS_NUMBER');
      print('   Método: .channel().onPostgresChanges() ✅');
    }

    final controller = StreamController<BusLocation?>.broadcast();

    // ✅ SINTAXIS CORRECTA para supabase_flutter v2.9.1
    // ⚠️ SIN FILTRO porque en DELETE solo viene el ID, no el bus_number
    _realtimeChannel = _supabase
        .channel('public:buses')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'buses',
          // ❌ NO FILTRAR por bus_number porque DELETE solo trae {id: X}
          // Si filtramos por bus_number, los DELETE no pasan el filtro
          callback: (payload) {
            print('📡 REALTIME CALLBACK EJECUTADO');
            print('   eventType: ${payload.eventType}');
            print('   oldRecord: ${payload.oldRecord}');
            print('   newRecord: ${payload.newRecord}');

            if (payload.eventType == PostgresChangeEvent.delete) {
              print('🗑️ DELETE EVENT DETECTADO - Enviando null al stream');
              controller.add(null);
              return;
            }

            // ✅ Para INSERT/UPDATE, verificar que sea el bus correcto
            final busData = payload.newRecord;

            if (busData.isEmpty) {
              controller.add(null);
              return;
            }

            // ✅ Verificar que sea el bus número 1 (ya que quitamos el filtro)
            final busNumber = busData['bus_number'] as int?;
            if (busNumber != BUS_NUMBER) {
              print(
                '⚠️ Evento ignorado: bus_number=$busNumber (esperado: $BUS_NUMBER)',
              );
              return;
            }

            try {
              final lat = busData['lat'];
              final lng = busData['lng'];

              // Leer userCount desde la base de datos
              final userCount = (busData['user_count'] as int?) ?? 0;
              final isActive = userCount >= MapController.MIN_USERS_TO_SHOW_BUS;

              print('📡 REALTIME: Evento recibido de la tabla buses');
              print('   Evento: ${payload.eventType}');
              print('   lat: $lat, lng: $lng');
              print('   user_count (de DB): $userCount');
              print(
                '   MIN_USERS_TO_SHOW_BUS: ${MapController.MIN_USERS_TO_SHOW_BUS}',
              );
              print(
                '   isActive calculado: $isActive ($userCount >= ${MapController.MIN_USERS_TO_SHOW_BUS})',
              );

              final busLocation = BusLocation(
                position: LatLng(
                  (lat as num).toDouble(),
                  (lng as num).toDouble(),
                ),
                timestamp: DateTime.now(),
                userCount: userCount,
                isActive: isActive,
              );

              print('✅ BusLocation creado y enviado al stream:');
              print('   position: ${busLocation.position}');
              print('   userCount: ${busLocation.userCount}');
              print('   isActive: ${busLocation.isActive}');

              // ✅ Agregar al stream
              controller.add(busLocation);
              print('✅ BusLocation agregado al stream controller\n');
            } catch (e, stackTrace) {
              print('❌ ERROR PARSEANDO: $e');
              if (_debug) print('   Stack: $stackTrace');

              controller.add(null);
            }
          },
        )
        .subscribe((status, error) {
          if (_debug) {
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
          }
        });

    if (_debug) {
      print('✅ Channel suscrito exitosamente');
      print('   Esperando eventos INSERT, UPDATE, DELETE...');
    }

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
