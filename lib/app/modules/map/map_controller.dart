import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/location_service.dart';
import '../../data/models/point_of_interest.dart';
import '../../data/models/poi_type.dart';
import 'constants/map_markers_consts.dart';

// Enum para los tipos de marcadores
enum MarkerType { facultades, paradas, accesos, ninguno }

class MapController extends GetxController {
  static const CENTRAL_POINT = LatLng(22.277125, -97.862299);
  static const double DEFAULT_ZOOM = 16.9;
  static const double BEARING = 270.0;

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
  // TODO: Descomentar cuando se implemente Supabase
  // final _busTrackingService = BusTrackingService();
  // final _supabase = Supabase.instance.client;

  // Map controller
  Completer<GoogleMapController> mapControllerCompleter = Completer();
  GoogleMapController? mapController;

  // Observable states
  final RxBool isLoading = true.obs;
  final RxBool showFixedMarkers = true.obs;
  final Rx<MarkerType> selectedMarkerType = MarkerType.ninguno.obs;
  // final RxBool showMyLocation = false.obs; // No necesario, Google Maps muestra el punto azul automáticamente
  final RxBool isInBus = false.obs;
  final RxBool hasLocationPermission = false.obs;
  // final Rx<LatLng?> myLocation = Rx<LatLng?>(null); // No necesario, Google Maps muestra el punto azul automáticamente
  // TODO: Descomentar cuando se implemente Supabase
  // final Rx<BusLocation?> busLocation = Rx<BusLocation?>(null);

  // Markers
  final markers = <Marker>{}.obs;
  final RxList<PointOfInterest> pointsOfInterest = <PointOfInterest>[].obs;

  // Cache de íconos personalizados
  final Map<String, BitmapDescriptor> _customIcons = {};

  // Streams
  StreamSubscription? _locationSubscription;
  // StreamSubscription? _busLocationSubscription;

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

    // TODO: Descomentar cuando se implemente Supabase
    // _subscribeToBusLocation();

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
      // Cargar íconos de facultades (33x50 px - rectangulares)
      _customIcons['FET'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FET.png',
        33,
        50,
      );
      _customIcons['FMA'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FMA.png',
        33,
        50,
      );
      _customIcons['FIT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FIT.png',
        33,
        50,
      );
      _customIcons['FADYCS'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADYCS.png',
        33,
        50,
      );
      _customIcons['FADU'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FADU.png',
        33,
        50,
      );
      _customIcons['FCAT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FCAT.png',
        33,
        50,
      );
      _customIcons['FO'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FO.png',
        33,
        50,
      );
      _customIcons['FMT'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FMT.png',
        33,
        50,
      );

      // Cargar íconos de paradas (33x50 px - rectangulares)
      _customIcons['BusStop_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/BusStop_cuted.png',
        33,
        50,
      );
      _customIcons['Entrada_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Entrada_cuted.png',
        33,
        50,
      );
      _customIcons['FIT_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/FIT_cuted.png',
        33,
        50,
      );
      _customIcons['Colera'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Colera.png',
        33,
        50,
      );
      _customIcons['GYM'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/GYM.png',
        33,
        50,
      );

      // Cargar íconos de accesos (33x50 px - rectangulares)
      _customIcons['Peatones'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Peatones.png',
        33,
        50,
      );
      _customIcons['Carros_cuted'] = await _getBitmapDescriptorFromAsset(
        'assets/markers/Carros_cuted.png',
        33,
        50,
      );
    } catch (e) {
      print('Error cargando íconos personalizados: $e');
      // Si falla, los marcadores usarán los íconos por defecto
    }
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
          title = 'Parada de Autobús';
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

    // Marcador de ubicación personal no necesario - Google Maps lo muestra automáticamente con myLocationEnabled: true

    // TODO: Descomentar cuando se implemente Supabase
    // Agrega marcador del autobús si está disponible
    // if (busLocation.value != null && busLocation.value!.isActive) {
    //   newMarkers.add(
    //     Marker(
    //       markerId: const MarkerId('bus'),
    //       position: busLocation.value!.position,
    //       infoWindow: InfoWindow(
    //         title: 'Autobús Universitario',
    //         snippet: '${busLocation.value!.userCount} usuarios reportados',
    //       ),
    //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    //     ),
    //   );
    // }

    markers.assignAll(newMarkers);
  }

  // TODO: Descomentar cuando se implemente Supabase
  // void _subscribeToBusLocation() {
  //   _busLocationSubscription?.cancel();
  //   _busLocationSubscription = _busTrackingService
  //       .getBusLocationStream()
  //       .listen((location) {
  //     busLocation.value = location;
  //     _updateMarkers();
  //   });
  // }

  Future<void> toggleInBus() async {
    // TODO: Implementar con Supabase en el futuro
    Get.snackbar(
      'Función no disponible',
      'Esta función estará disponible cuando se configure Supabase',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

    // Por ahora solo muestra un mensaje
    // Descomentar cuando se implemente Supabase:
    /*
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
    */
  }

  // TODO: Descomentar cuando se implemente Supabase
  /*
  Future<void> _startReportingLocation() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'No se pudo identificar el usuario',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final location = await _locationService.getCurrentLocation();
      if (location == null) {
        Get.snackbar(
          'Error',
          'No se pudo obtener tu ubicación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final success = await _busTrackingService.reportUserInBus(
        userId,
        location,
        0.0,
      );

      if (success) {
        isInBus.value = true;
        
        _locationSubscription = _locationService.getLocationStream().listen(
          (position) async {
            final newLocation = LatLng(position.latitude, position.longitude);
            await _busTrackingService.reportUserInBus(
              userId,
              newLocation,
              position.accuracy,
            );
          },
        );

        _busTrackingService.startTracking(userId);

        Get.snackbar(
          'Activado',
          'Estás reportando tu ubicación en el autobús',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error iniciando reporte de ubicación: $e');
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
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _busTrackingService.removeUserFromBus(userId);
      }

      _locationSubscription?.cancel();
      _locationSubscription = null;
      _busTrackingService.stopTracking();
      
      isInBus.value = false;

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
  */

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
    // TODO: Implementar cuando se configure Supabase
    Get.snackbar(
      'No disponible',
      'Esta función estará disponible cuando se configure el tracking del autobús',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

    // Descomentar cuando se implemente:
    /*
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
    */
  }

  Future<void> centerOnCampus() async {
    await _moveCamera(CENTRAL_POINT, bearing: BEARING);
  }

  void onMapCreated(GoogleMapController controller) {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
    }
    mapController = controller;

    // Aplicar estilo personalizado al mapa
    controller.setMapStyle(mapStyle);

    // Forzar la posición inicial con bearing de manera más agresiva
    _applyInitialCameraPosition(controller);
  }

  void _applyInitialCameraPosition(GoogleMapController controller) {
    const targetPosition = CameraPosition(
      target: CENTRAL_POINT,
      zoom: DEFAULT_ZOOM,
      bearing: BEARING,
      tilt: 0,
    );

    // Aplicación inmediata sin animación
    controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));

    // Aplicaciones adicionales con delays incrementales
    for (int i = 1; i <= 5; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mapController != null) {
          controller.moveCamera(CameraUpdate.newCameraPosition(targetPosition));
        }
      });
    }
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    // TODO: Descomentar cuando se implemente Supabase
    // _busLocationSubscription?.cancel();
    // _busTrackingService.dispose();
    mapController?.dispose();
    super.onClose();
  }
}
