import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../map_controller.dart';

/// Widget multiplataforma que renderiza el mapa de Google Maps
/// tanto en web como en móvil (Android/iOS)
class PlatformMapWidget extends StatelessWidget {
  final MapController mapController;

  const PlatformMapWidget({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    // En web, el mapa funciona pero con algunas limitaciones
    // Por ejemplo, myLocationEnabled puede no funcionar igual
    return Obx(
      () => GoogleMap(
        onMapCreated: mapController.onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: MapController.CENTRAL_POINT,
          zoom: MapController.DEFAULT_ZOOM,
          bearing:
              MapController.BEARING, // Usar el bearing correcto de 270 grados
          tilt: 0, // Sin inclinación
        ),
        markers: mapController.markers.toSet(),
        mapType: MapType.normal,

        // Restricciones de cámara
        minMaxZoomPreference: const MinMaxZoomPreference(16, 17),
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            southwest: const LatLng(22.2745, -97.8660),
            northeast: const LatLng(22.2800, -97.8590),
          ),
        ),

        // Deshabilitar gestos - El usuario NO puede rotar el mapa manualmente
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled:
            false, // Deshabilitado para evitar que el usuario rote el mapa
        // Controles UI
        // En web, myLocationEnabled puede requerir permisos del navegador
        myLocationEnabled: !kIsWeb, // Deshabilitar en web por compatibilidad
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        indoorViewEnabled: false,
        trafficEnabled: false,
        buildingsEnabled: true,

        // Configuraciones específicas para web
        // La web puede tener diferentes comportamientos de gestos
        liteModeEnabled: false,
      ),
    );
  }
}
