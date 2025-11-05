import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/location_service.dart';
import '../../data/services/bus_tracking_service.dart';
import '../../data/models/bus_location.dart';
import '../../data/models/point_of_interest.dart';
import '../../data/models/poi_type.dart';
import 'constants/map_markers_consts.dart';

// Enum para los tipos de marcadores
enum MarkerType { facultades, paradas, accesos, ninguno }

class MapController extends GetxController {
  static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
  static const double DEFAULT_ZOOM = 16.4; // Reducido para ver toda la facultad
  static const double MOBILE_ZOOM = 16.5; // +.1 zoom para móvil
  static const double BEARING = 270.0;

  // Mínimo de usuarios requeridos para mostrar el bus en el mapa
  static const int MIN_USERS_TO_SHOW_BUS = 1;

  // Control de logging (false en producción para mejor rendimiento)
  static const bool ENABLE_DEBUG_LOGS = false;

  // Estilo personalizado del mapa
  static const String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          { "color": "#F9F5E9" }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          { "color": "#F9F5E9" }
        ]
      },
      {
        "featureType": "landscape.man_made",
        "elementType": "geometry",
        "stylers": [
          { "color": "#F9F5E9" }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          { "color": "#FEFEFE" }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          { "color": "#0575FD" }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "labels",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
          { "color": "#ECEDEF" }
        ]
      }
    ]
  ''';

  // Services
  final _locationService = LocationService();
  final _busTrackingService = BusTrackingService();
  final _supabase = Supabase.instance.client;

  // Map controller
  Completer<GoogleMapController> mapControllerCompleter = Completer();
  GoogleMapController? mapController;

  // Observable states
  final RxBool isLoading = true.obs;
  final RxBool showFixedMarkers = true.obs;
  final Rx<MarkerType> selectedMarkerType = MarkerType.ninguno.obs;
  final RxBool isInBus = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final Rx<BusLocation?> busLocation = Rx<BusLocation?>(null);

  // Lock para evitar múltiples llamadas simultáneas
  bool _isTogglingBus = false;

  // Bandera para controlar si se están enviando ubicaciones activamente
  bool _isReportingActive = false;

  // Markers
  final markers = <Marker>{}.obs;
  final RxList<PointOfInterest> pointsOfInterest = <PointOfInterest>[].obs;

  // Cache de íconos personalizados
  final Map<String, BitmapDescriptor> _customIcons = {};

  // Cache de última posición del bus para evitar actualizaciones innecesarias
  LatLng? _lastBusPosition;

  // Streams
  StreamSubscription? _locationSubscription;
  StreamSubscription? _busLocationSubscription;

  // Timer para mantener el bearing correcto
  Timer? _bearingEnforcer;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isLoading.value = true;

    // Verifica permisos
    await _checkLocationPermission();

    // Carga íconos personalizados
    await _loadCustomIcons();

    // Carga puntos de interés (estáticos por ahora)
    await _loadPointsOfInterest();

    // Carga marcadores fijos
    _updateMarkers();

    // Suscribirse a ubicación del bus
    _subscribeToBusLocation();

    isLoading.value = false;
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await _locationService.checkPermissions();
    hasLocationPermission.value = hasPermission;

    if (!hasPermission) {
      final granted = await _locationService.requestPermissions();
      hasLocationPermission.value = granted;
    }
  }

  Future<void> _loadCustomIcons() async {
    try {
      // Determinar tamaños según plataforma
      // Móvil: 48x48 (cuadrados)
      // Web: 33x50 (rectangulares, mantener proporción original)
      final int width = kIsWeb ? 33 : 75;
      final int height = kIsWeb ? 50 : 80;

      // Cargar íconos de facultades
      _customIcons['FET'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FET.png',
        width,
        height,
      );
      _customIcons['FMA'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FMA.png',
        width,
        height,
      );
      _customIcons['FIT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FIT.png',
        width,
        height,
      );
      _customIcons['FADYCS'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADYCS.png',
        width,
        height,
      );
      _customIcons['FADU'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADU.png',
        width,
        height,
      );
      _customIcons['FCAT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FCAT.png',
        width,
        height,
      );
      _customIcons['FO'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FO.png',
        width,
        height,
      );
      _customIcons['FMT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FMT.png',
        width,
        height,
      );
      _customIcons['FADYCS'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADYCS.png',
        width,
        height,
      );
      _customIcons['FADU'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADU.png',
        width,
        height,
      );
      _customIcons['FCAT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FCAT.png',
        width,
        height,
      );

      // Cargar íconos de paradas
      _customIcons['BusStop_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/BusStop_cuted.png',
        width,
        height,
      );
      _customIcons['Entrada_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Entrada_cuted.png',
        width,
        height,
      );
      _customIcons['FIT_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FIT_cuted.png',
        width,
        height,
      );
      _customIcons['Colera'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Colera.png',
        width,
        height,
      );
      _customIcons['GYM'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/GYM.png',
        width,
        height,
      );

      // Cargar íconos de accesos
      _customIcons['Peatones'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Peatones.png',
        width,
        height,
      );
      _customIcons['Carros_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Carros_cuted.png',
        width,
        height,
      );

      // Cargar ícono del bus - Marcador genérico naranja
      _customIcons['bus'] = await _createGenericBusMarker();
    } catch (e) {
      print('Error cargando íconos personalizados: $e');
      // Si falla, los marcadores usarán los íconos por defecto
    }
  }

  /// Crea un marcador de ícono de bus en una burbuja estilo marker
  Future<BitmapDescriptor> _createGenericBusMarker() async {
    final int size = kIsWeb ? 50 : 90;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final center = Offset(size / 2, size / 2.2);
    final bubbleRadius = size / 2.5;

    // 1. Dibujar sombra
    paint.color = Colors.black.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), bubbleRadius, paint);
    paint.maskFilter = null;

    // 2. Dibujar círculo blanco (fondo de la burbuja)
    paint.color = Colors.white;
    canvas.drawCircle(center, bubbleRadius, paint);

    // 3. Dibujar borde negro
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, bubbleRadius, paint);

    // 4. Dibujar el pico del marcador
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;
    final pikePath = Path();
    final pikeBottom = Offset(center.dx, size - 5);
    final pikeLeft = Offset(center.dx - 6, center.dy + bubbleRadius - 2);
    final pikeRight = Offset(center.dx + 6, center.dy + bubbleRadius - 2);
    pikePath.moveTo(pikeBottom.dx, pikeBottom.dy);
    pikePath.lineTo(pikeLeft.dx, pikeLeft.dy);
    pikePath.lineTo(pikeRight.dx, pikeRight.dy);
    pikePath.close();
    canvas.drawPath(pikePath, paint);

    // Borde del pico
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(pikePath, paint);

    // 5. Dibujar el ícono de bus
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.directions_bus.codePoint),
      style: TextStyle(
        fontSize: bubbleRadius * 1.3,
        fontFamily: Icons.directions_bus.fontFamily,
        color: Colors.orange,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Convertir a imagen
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromAsset(
    String assetPath,
    int width,
    int height,
  ) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedData = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedData);
  }

  Future<void> _loadPointsOfInterest() async {
    try {
      // Carga POIs desde Supabase o define algunos por defecto
      // Usando coordenadas reales del campus
      pointsOfInterest.value = [
        // Paradas del autobús
        const PointOfInterest(
          id: 'punto03',
          name: 'Entrada Principal',
          position: LatLng(22.278027, -97.861074),
          type: PoiType.parada,
          description: 'Parada - Entrada Principal',
        ),
        const PointOfInterest(
          id: 'punto11',
          name: 'Cólera',
          position: LatLng(22.278241, -97.865206),
          type: PoiType.parada,
          description: 'Parada - Cólera',
        ),
        const PointOfInterest(
          id: 'punto13',
          name: 'Ingeniería',
          position: LatLng(22.277044, -97.865414),
          type: PoiType.parada,
          description: 'Parada - Facultad de Ingeniería',
        ),
        const PointOfInterest(
          id: 'punto16',
          name: 'Derecho',
          position: LatLng(22.275550, -97.865424),
          type: PoiType.parada,
          description: 'Parada - Facultad de Derecho',
        ),
        const PointOfInterest(
          id: 'punto20',
          name: 'FADU',
          position: LatLng(22.275074, -97.863472),
          type: PoiType.parada,
          description: 'Parada - Facultad de Arquitectura, Diseño y Urbanismo',
        ),
        const PointOfInterest(
          id: 'punto22',
          name: 'Comercio',
          position: LatLng(22.275131, -97.862650),
          type: PoiType.parada,
          description: 'Parada - Facultad de Comercio',
        ),
        const PointOfInterest(
          id: 'punto28',
          name: 'Gimnasio',
          position: LatLng(22.275939, -97.859484),
          type: PoiType.parada,
          description: 'Parada - Gimnasio Universitario',
        ),
      ];

      // Alternativamente, carga desde Supabase:
      // final response = await _supabase.from('points_of_interest').select();
      // pointsOfInterest.value = (response as List)
      //     .map((json) => PointOfInterest.fromJson(json))
      //     .toList();
    } catch (e) {
      print('Error cargando puntos de interés: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar los puntos de interés',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateMarkers() {
    final Set<Marker> newMarkers = {};

    // Agrega marcadores según el tipo seleccionado
    if (selectedMarkerType.value != MarkerType.ninguno) {
      Map<String, dynamic> selectedMarkers = {};

      switch (selectedMarkerType.value) {
        case MarkerType.facultades:
          selectedMarkers = MapMarkersConsts.FAC_MARKERS;
          break;
        case MarkerType.paradas:
          selectedMarkers = MapMarkersConsts.STOPS_MARKERS;
          break;
        case MarkerType.accesos:
          selectedMarkers = MapMarkersConsts.ACCES_MARKERS;
          break;
        case MarkerType.ninguno:
          break;
      }

      selectedMarkers.forEach((key, value) {
        final LatLng coordinate = value['coordinate'] as LatLng;
        String? title;
        String? snippet;
        BitmapDescriptor icon;

        if (selectedMarkerType.value == MarkerType.facultades) {
          title = value['name'] as String;
          snippet = 'Facultad';
          // Obtener ícono personalizado de la facultad
          final facLogo = value['fac_logo'] as String?;
          final iconKey = facLogo
              ?.split('/')
              .last
              .split('.')
              .first; // Extrae el nombre del archivo
          icon =
              _customIcons[iconKey] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        } else if (selectedMarkerType.value == MarkerType.paradas) {
          title = value['name'] as String? ?? 'Parada de Autobús';
          snippet = key;
          // Usar ícono de parada personalizado
          final stopLogo = value['stop_logo'] as String?;
          final iconKey = stopLogo
              ?.split('/')
              .last
              .split('.')
              .first; // Extrae el nombre del archivo (con _cuted)
          icon =
              _customIcons[iconKey] ??
              _customIcons['BusStop_cuted'] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
        } else if (selectedMarkerType.value == MarkerType.accesos) {
          final isForPedestrian = value['isForPedestrian'] as bool;
          title = isForPedestrian ? 'Entrada Peatonal' : 'Entrada Automóvil';
          snippet = key;
          // Usar ícono según el tipo de acceso
          icon =
              _customIcons[isForPedestrian ? 'Peatones' : 'Carros_cuted'] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        } else {
          icon = BitmapDescriptor.defaultMarker;
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(key),
            position: coordinate,
            infoWindow: InfoWindow(title: title ?? key, snippet: snippet),
            icon: icon,
          ),
        );
      });
    }

    // Agrega marcador del autobús si está disponible y tiene usuarios
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 EVALUANDO SI MOSTRAR EL BUS:');
    print('   busLocation.value != null: ${busLocation.value != null}');

    if (busLocation.value != null) {
      print('   busLocation.value!.isActive: ${busLocation.value!.isActive}');
      print('   busLocation.value!.userCount: ${busLocation.value!.userCount}');
      print('   MIN_USERS_TO_SHOW_BUS: $MIN_USERS_TO_SHOW_BUS');
      print(
        '   userCount >= MIN_USERS_TO_SHOW_BUS: ${busLocation.value!.userCount >= MIN_USERS_TO_SHOW_BUS}',
      );
    }

    final shouldShowBus =
        busLocation.value != null &&
        busLocation.value!.isActive &&
        busLocation.value!.userCount >= MIN_USERS_TO_SHOW_BUS;

    print('   RESULTADO: shouldShowBus = $shouldShowBus');

    if (shouldShowBus) {
      print(
        '✅ ✅ ✅ MOSTRANDO MARCADOR DEL BUS EN POSICIÓN: ${busLocation.value!.position}',
      );

      final busMarker = Marker(
        markerId: const MarkerId('bus'),
        position: busLocation.value!.position,
        infoWindow: InfoWindow(
          title: 'Autobús Universitario',
          snippet: '${busLocation.value!.userCount} usuarios reportados',
        ),
        icon:
            _customIcons['bus'] ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      newMarkers.add(busMarker);
      print(
        '✅ Marcador del bus agregado a newMarkers (total: ${newMarkers.length})',
      );
    } else {
      print('❌ NO SE MUESTRA EL BUS (condiciones no cumplidas)');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    markers.assignAll(newMarkers);
  }

  void _subscribeToBusLocation() {
    _busLocationSubscription?.cancel();
    _busLocationSubscription = _busTrackingService.getBusLocationStream().listen(
      (location) {
        print('🎯 STREAM LISTENER RECIBIÓ UPDATE:');
        print(
          '   location: ${location != null ? "BusLocation(${location.position}, count=${location.userCount}, active=${location.isActive})" : "NULL"}',
        );

        if (location != null) {
          final newPosition = location.position;
          bool shouldUpdate = false;

          if (_lastBusPosition == null) {
            shouldUpdate = true;
          } else {
            final latDiff = (_lastBusPosition!.latitude - newPosition.latitude)
                .abs();
            final lngDiff =
                (_lastBusPosition!.longitude - newPosition.longitude).abs();

            // 0.00005 grados ≈ 5 metros
            if (latDiff > 0.00005 || lngDiff > 0.00005) {
              shouldUpdate = true;
            }
          }

          if (shouldUpdate) {
            if (ENABLE_DEBUG_LOGS) print('📍 Bus moved: $newPosition');
            _lastBusPosition = newPosition;
            busLocation.value = location;
            _updateMarkers();
          }
        } else {
          print('🗑️ LOCATION ES NULL - Limpiando marcador del bus');
          _lastBusPosition = null;
          busLocation.value = null;
          _updateMarkers();
        }
      },
      onError: (error, stackTrace) {
        print('❌ Realtime error: $error');
      },
    );
  }

  Future<void> toggleInBus() async {
    // ✅ Prevenir múltiples llamadas simultáneas
    if (_isTogglingBus) {
      if (ENABLE_DEBUG_LOGS) {
        print('⚠️ toggleInBus ya está en ejecución, ignorando llamada...');
      }
      return;
    }

    _isTogglingBus = true;
    if (ENABLE_DEBUG_LOGS) print('🔒 Lock activado para toggleInBus');

    try {
      if (!hasLocationPermission.value) {
        Get.snackbar(
          'Permiso requerido',
          'Necesitas otorgar permisos de ubicación',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        await _checkLocationPermission();
        return;
      }

      if (isInBus.value) {
        await _stopReportingLocation();
      } else {
        await _startReportingLocation();
      }
    } finally {
      _isTogglingBus = false;
      if (ENABLE_DEBUG_LOGS) print('🔓 Lock liberado para toggleInBus');
    }
  }

  Future<void> _startReportingLocation() async {
    try {
      if (ENABLE_DEBUG_LOGS) print('🚀 Iniciando reporte de ubicación...');

      // Obtener o crear un usuario anónimo
      String? tempUserId = _supabase.auth.currentUser?.id;

      if (tempUserId == null) {
        if (ENABLE_DEBUG_LOGS) {
          print('⚠️ No hay usuario actual, creando sesión anónima...');
        }
        // Crear sesión anónima
        final response = await _supabase.auth.signInAnonymously();
        tempUserId = response.user?.id;

        if (tempUserId == null) {
          print('❌ Error: No se pudo crear sesión anónima');
          Get.snackbar(
            'Error',
            'No se pudo crear una sesión de usuario',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        if (ENABLE_DEBUG_LOGS) print('✅ Usuario anónimo creado: $tempUserId');
      } else {
        if (ENABLE_DEBUG_LOGS) {
          print('✅ Usuario existente encontrado: $tempUserId');
        }
      }

      // Ahora userId es definitivamente no-null
      final String userId = tempUserId;

      if (ENABLE_DEBUG_LOGS) print('📍 Obteniendo ubicación actual...');
      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        print('❌ Error: No se pudo obtener ubicación');
        Get.snackbar(
          'Error',
          'No se pudo obtener tu ubicación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (ENABLE_DEBUG_LOGS) {
        print('✅ Ubicación obtenida: $location');
        print('🔄 Llamando a BusTrackingService...');
      }

      final success = await _busTrackingService.reportUserInBus(
        userId, // Ahora es String no-nullable
        location,
        0.0,
      );

      if (ENABLE_DEBUG_LOGS) {
        print('📊 Resultado de reportUserInBus: $success');
      }

      if (success) {
        isInBus.value = true;
        _isReportingActive = true; // Activar bandera

        if (ENABLE_DEBUG_LOGS) print('🎧 Iniciando stream de ubicación...');
        _locationSubscription = _locationService.getLocationStream().listen((
          position,
        ) async {
          // Verificar que sigue activo antes de reportar
          if (!_isReportingActive) {
            if (ENABLE_DEBUG_LOGS)
              print('⏹️ Reporte inactivo - ignorando ubicación');
            return;
          }

          final newLocation = LatLng(position.latitude, position.longitude);
          if (ENABLE_DEBUG_LOGS) {
            print('📍 Nueva ubicación detectada: $newLocation');
          }
          await _busTrackingService.reportUserInBus(
            userId, // String no-nullable
            newLocation,
            position.accuracy,
          );
        });

        _busTrackingService.startTracking(userId); // String no-nullable

        Get.snackbar(
          'Activado',
          'Estás reportando tu ubicación en el autobús',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        if (ENABLE_DEBUG_LOGS) {
          print('❌ Error: reportUserInBus retornó false');
        }
        Get.snackbar(
          'Error',
          'No se pudo reportar tu ubicación al servidor',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ ERROR CRÍTICO iniciando reporte de ubicación: $e');
      if (ENABLE_DEBUG_LOGS) print('   Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'No se pudo iniciar el reporte de ubicación',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _stopReportingLocation() async {
    try {
      print('🔴🔴🔴 INICIANDO PROCESO DE DESCONEXIÓN 🔴🔴🔴');
      final userId = _supabase.auth.currentUser?.id;
      print('   User ID: $userId');

      // PASO 1: Desactivar bandera INMEDIATAMENTE para prevenir nuevos reportes
      print('   ⏹️ Desactivando bandera de reporte...');
      _isReportingActive = false;

      // PASO 2: Cancelar suscripción (esto detiene el listener)
      print('   Cancelando locationSubscription...');
      _locationSubscription?.cancel();
      _locationSubscription = null;

      // PASO 3: Detener el stream periódico
      print('   Deteniendo location stream...');
      _locationService.stopLocationStream();

      // PASO 4: Pequeña espera para que cualquier llamada pendiente termine
      print('   ⏳ Esperando llamadas pendientes...');
      await Future.delayed(const Duration(milliseconds: 100));

      // PASO 5: Ahora sí, desconectar del servidor
      if (userId != null) {
        print('   Llamando a removeUserFromBus...');
        await _busTrackingService.removeUserFromBus(userId);
        print('   ✅ removeUserFromBus completado');
      }

      // PASO 6: Detener tracking de Realtime
      print('   Llamando a stopTracking...');
      _busTrackingService.stopTracking();

      isInBus.value = false;
      print('🔴🔴🔴 PROCESO DE DESCONEXIÓN COMPLETADO 🔴🔴🔴');

      Get.snackbar(
        'Desactivado',
        'Has dejado de reportar tu ubicación',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error deteniendo reporte de ubicación: $e');
    }
  }

  // toggleMyLocation no necesario - Google Maps muestra el punto azul automáticamente
  // Future<void> toggleMyLocation() async {
  //   if (!hasLocationPermission.value) {
  //     await _checkLocationPermission();
  //     if (!hasLocationPermission.value) return;
  //   }

  //   showMyLocation.value = !showMyLocation.value;

  //   if (showMyLocation.value) {
  //     final location = await _locationService.getCurrentLocation();
  //     if (location != null) {
  //       myLocation.value = location;
  //       _moveCamera(location);
  //     }
  //   }

  //   _updateMarkers();
  // }

  void toggleFixedMarkers() {
    showFixedMarkers.value = !showFixedMarkers.value;
    _updateMarkers();
  }

  void changeMarkerType(MarkerType type) {
    selectedMarkerType.value = type;
    _updateMarkers();
  }

  Future<void> _moveCamera(
    LatLng position, {
    double zoom = DEFAULT_ZOOM,
    double? bearing,
  }) async {
    final controller = await mapControllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom, bearing: bearing ?? 0.0),
      ),
    );
  }

  Future<void> centerOnBus() async {
    if (busLocation.value != null) {
      await _moveCamera(busLocation.value!.position);
    } else {
      Get.snackbar(
        'No disponible',
        'El autobús no está siendo rastreado en este momento',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> centerOnCampus() async {
    await _moveCamera(CENTRAL_POINT, bearing: BEARING);

    // Mostrar un feedback al usuario
    Get.snackbar(
      'Mapa reorientado',
      'El mapa ha sido centrado y orientado correctamente',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    // Solo completar si no está ya completado
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
      mapController = controller;
    } else {
      // Si ya existe un controller, solo actualizar la referencia
      mapController = controller;
    }

    // Aplicar estilo personalizado al mapa
    try {
      controller.setMapStyle(mapStyle);
    } catch (e) {
      print('Error aplicando estilo del mapa: $e');
    }

    // Forzar la posición inicial con bearing
    _applyInitialCameraPosition(controller);

    // Aplicar bearing adicional después de un delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mapController != null) {
        _forceCorrectBearing();
      }
    });

    // Cancelar timer anterior si existe
    _bearingEnforcer?.cancel();

    // Timer que verifica y corrige el bearing cada 2 segundos
    _bearingEnforcer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mapController != null) {
        ensureCorrectBearing();
      }
    });
  }

  void _applyInitialCameraPosition(GoogleMapController controller) {
    final targetPosition = CameraPosition(
      target: CENTRAL_POINT,
      zoom: kIsWeb ? DEFAULT_ZOOM : MOBILE_ZOOM,
      bearing: BEARING,
      tilt: 0,
    );

    // Aplicación inicial sin animación
    try {
      controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));
    } catch (e) {
      print('Error aplicando posición inicial: $e');
    }

    // Aplicaciones adicionales con delays para asegurar que se aplique
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mapController != null) {
        try {
          controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));
        } catch (e) {
          print('Error en reintento de posición: $e');
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mapController != null) {
        try {
          controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));
        } catch (e) {
          print('Error en segundo reintento: $e');
        }
      }
    });
  }

  // Método para forzar el bearing correcto
  void _forceCorrectBearing() async {
    if (mapController == null) return;

    try {
      final controller = await mapControllerCompleter.future;
      final targetPosition = CameraPosition(
        target: CENTRAL_POINT,
        zoom: kIsWeb ? DEFAULT_ZOOM : MOBILE_ZOOM,
        bearing: BEARING,
        tilt: 0,
      );

      // Aplicar múltiples veces para asegurar
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(targetPosition),
      );
      await Future.delayed(const Duration(milliseconds: 100));
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(targetPosition),
      );
    } catch (e) {
      print('Error forzando bearing: $e');
    }
  }

  // Método público para asegurar que el bearing sea correcto
  void ensureCorrectBearing() async {
    if (mapController == null) return;

    try {
      final controller = await mapControllerCompleter.future;

      // Siempre re-aplicar el bearing correcto cuando la cámara deja de moverse
      final targetPosition = CameraPosition(
        target: CENTRAL_POINT,
        zoom: kIsWeb ? DEFAULT_ZOOM : MOBILE_ZOOM,
        bearing: BEARING,
        tilt: 0,
      );

      controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));
    } catch (e) {
      print('Error asegurando bearing: $e');
    }
  }

  @override
  void onClose() {
    // Cancelar todas las suscripciones
    _locationSubscription?.cancel();
    _locationSubscription = null;

    _bearingEnforcer?.cancel();
    _bearingEnforcer = null;

    _busLocationSubscription?.cancel();
    _busLocationSubscription = null;

    // Limpiar el tracking service
    try {
      _busTrackingService.dispose();
    } catch (e) {
      print('Error en dispose de BusTrackingService: $e');
    }

    // Limpiar el map controller
    mapController = null;

    // No es necesario hacer dispose del mapController
    // GoogleMapController se limpia automáticamente cuando el widget se destruye
    super.onClose();
  }
}
