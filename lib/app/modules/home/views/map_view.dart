import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../map/map_controller.dart';
import '../../map/map_binding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el MapController si no existe
    if (!Get.isRegistered<MapController>()) {
      MapBinding().dependencies();
    }

    final MapController mapController = Get.find<MapController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del Campus'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // Botón para mostrar/ocultar marcadores
          Obx(
            () => IconButton(
              icon: Icon(
                mapController.showFixedMarkers.value
                    ? Icons.location_on
                    : Icons.location_off,
              ),
              tooltip: mapController.showFixedMarkers.value
                  ? 'Ocultar marcadores'
                  : 'Mostrar marcadores',
              onPressed: mapController.toggleFixedMarkers,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          Obx(
            () => GoogleMap(
              onMapCreated: mapController.onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: MapController.CENTRAL_POINT,
                zoom: MapController.DEFAULT_ZOOM,
                bearing: MapController.BEARING,
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

              // Deshabilitar gestos
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,

              // Controles UI
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: true,
            ),
          ),

          // TODO: Descomentar cuando se implemente Supabase
          // Información del bus (si está activo)
          // Obx(() {
          //   final bus = controller.busLocation.value;
          //   if (bus == null || !bus.isActive) {
          //     return const SizedBox.shrink();
          //   }

          //   return Positioned(
          //     top: 16,
          //     left: 16,
          //     child: _BuildBusInfoCard(busLocation: bus),
          //   );
          // }),

          // Botones de control
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'in_bus',
              onPressed: mapController.toggleInBus,
              icon: const Icon(Icons.directions_bus),
              label: const Text('Estoy en el bus'),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
