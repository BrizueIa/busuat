import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller.dart';
import 'widgets/marker_type_dropdown.dart';

class MapPage extends GetView<MapController> {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa del Campus'),
        actions: [
          // Botón para centrar en el campus
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: controller.centerOnCampus,
            tooltip: 'Centrar en el campus',
          ),
          // TODO: Descomentar cuando se implemente Supabase
          // Botón para centrar en el bus
          // Obx(() => controller.busLocation.value != null
          //     ? IconButton(
          //         icon: const Icon(Icons.directions_bus),
          //         onPressed: controller.centerOnBus,
          //         tooltip: 'Centrar en el autobús',
          //       )
          //     : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Mapa
            GoogleMap(
              onMapCreated: controller.onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: MapController.CENTRAL_POINT,
                zoom: MapController.DEFAULT_ZOOM,
                bearing: MapController.BEARING,
              ),
              markers: controller.markers.toSet(),
              mapType: MapType.normal,

              // Restricciones de cámara
              minMaxZoomPreference: const MinMaxZoomPreference(16, 17),
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(22.2745, -97.8660),
                  northeast: const LatLng(22.2800, -97.8590),
                ),
              ),

              // Deshabilitar gestos de rotación/inclinación pero permitir zoom y scroll
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,

              // Controles web - Deshabilitar TODOS
              webGestureHandling: WebGestureHandling.greedy,

              // Controles UI - Todos desactivados
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: true,
            ),

            // Controles superiores
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Dropdown para seleccionar tipo de marcadores
                  Obx(
                    () => MarkerTypeDropdown(
                      selectedType: controller.selectedMarkerType.value,
                      onChanged: controller.changeMarkerType,
                    ),
                  ),
                ],
              ),
            ),

            // Switch "Estoy en el bus" - pegado al bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => _BuildInBusSwitchBar(
                  isInBus: controller.isInBus.value,
                  onChanged: (value) {
                    controller.toggleInBus();
                  },
                ),
              ),
            ),

            // Información del bus (si está activo)
            Obx(() {
              final bus = controller.busLocation.value;
              if (bus == null || !bus.isActive) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: 80,
                left: 16,
                child: _BuildBusInfoCard(busLocation: bus),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _BuildInBusSwitchBar extends StatelessWidget {
  final bool isInBus;
  final ValueChanged<bool> onChanged;

  const _BuildInBusSwitchBar({required this.isInBus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isInBus ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: isInBus ? Colors.green.shade700 : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estoy en el bus',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isInBus ? 'Reportando ubicación' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isInBus,
                onChanged: onChanged,
                activeThumbColor: Colors.green.shade600,
                activeTrackColor: Colors.green.shade200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildBusInfoCard extends StatelessWidget {
  final dynamic busLocation;

  const _BuildBusInfoCard({required this.busLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_bus,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bus en servicio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${busLocation.userCount} usuarios reportados',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
