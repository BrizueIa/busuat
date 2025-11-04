import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../map/map_controller.dart';
import '../../map/map_binding.dart';
import '../../map/widgets/platform_map_widget.dart';
import '../../map/widgets/marker_type_dropdown.dart';
import '../../map/widgets/recenter_button.dart';

class GuestMapView extends StatelessWidget {
  const GuestMapView({super.key});

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
      ),
      body: Stack(
        children: [
          // Mapa
          PlatformMapWidget(mapController: mapController),

          // Dropdown de marcadores - posicionado en la esquina superior derecha
          Positioned(
            top: 16,
            right: 16,
            child: Obx(
              () => MarkerTypeDropdown(
                selectedType: mapController.selectedMarkerType.value,
                onChanged: mapController.changeMarkerType,
              ),
            ),
          ),

          // Botón de re-centrar - posicionado en la esquina superior izquierda
          Positioned(
            top: 16,
            left: 16,
            child: RecenterButton(onPressed: mapController.centerOnCampus),
          ),

          // Información del bus (si está activo) - Solo visualización
          Obx(() {
            final bus = mapController.busLocation.value;
            if (bus == null) {
              return const SizedBox.shrink();
            }

            return Positioned(
              top: 80,
              left: 16,
              child: _BuildBusInfoCard(busLocation: bus),
            );
          }),
        ],
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
