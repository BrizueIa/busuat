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
        onCameraIdle: () {
          // Cuando la cámara deja de moverse, verificar y corregir bearing
          mapController.ensureCorrectBearing();
        },
        initialCameraPosition: CameraPosition(
          target: MapController.CENTRAL_POINT,
          zoom: kIsWeb ? MapController.DEFAULT_ZOOM : MapController.MOBILE_ZOOM,
          bearing:
              MapController.BEARING, // Usar el bearing correcto de 270 grados
          tilt: 0, // Sin inclinación
        ),
        markers: mapController.markers.toSet(),
        mapType: MapType.normal,

        // Restricciones de cámara - Ajustado para permitir ver toda la facultad
        minMaxZoomPreference: const MinMaxZoomPreference(15.5, 17.5),
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            southwest: const LatLng(22.2745, -97.8660),
            northeast: const LatLng(22.2800, -97.8590),
          ),
        ),

        // Deshabilitar gestos - El usuario NO puede rotar el mapa manualmente
        zoomGesturesEnabled: true, // Permitir zoom con pellizco
        scrollGesturesEnabled: kIsWeb, // Solo permitir mover el mapa en web
        tiltGesturesEnabled: false, // No inclinar
        rotateGesturesEnabled: false, // NO permitir rotación manual
        // Controles UI - Todos desactivados para interfaz limpia
        myLocationEnabled: !kIsWeb, // Deshabilitar en web por compatibilidad
        myLocationButtonEnabled: false, // Sin botón de ubicación
        zoomControlsEnabled: false, // Sin botones de zoom +/-
        mapToolbarEnabled:
            false, // Sin toolbar (direcciones, abrir en Google Maps, etc)
        compassEnabled: false, // Sin brújula
        indoorViewEnabled: false, // Sin vista interior de edificios
        trafficEnabled: false, // Sin tráfico
        buildingsEnabled: true, // Mantener edificios 3D
        // Configuraciones específicas para web
        // La web puede tener diferentes comportamientos de gestos
        liteModeEnabled: false,
      ),
    );
  }
}
