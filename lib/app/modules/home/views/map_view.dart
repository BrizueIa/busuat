import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../map/map_controller.dart';
import '../../map/map_binding.dart';
import '../../map/widgets/platform_map_widget.dart';
import '../../map/widgets/marker_type_dropdown.dart';

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

          // Switch "Estoy en el bus" - pegado al bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => _BuildInBusSwitchBar(
                isInBus: mapController.isInBus.value,
                onChanged: (value) {
                  mapController.isInBus.value = value;
                  Get.snackbar(
                    value ? 'Activado' : 'Desactivado',
                    value
                        ? 'Función disponible cuando se configure la base de datos'
                        : 'Has dejado de reportar tu ubicación',
                    backgroundColor: value ? Colors.green : Colors.orange,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ),
          ),
        ],
      ),
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
