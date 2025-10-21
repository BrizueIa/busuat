import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller.dart';

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

            // Controles superiores
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Botón para mostrar/ocultar marcadores fijos
                  _BuildControlButton(
                    icon: controller.showFixedMarkers.value
                        ? Icons.location_on
                        : Icons.location_off,
                    label: 'Marcadores',
                    isActive: controller.showFixedMarkers.value,
                    onPressed: controller.toggleFixedMarkers,
                  ),
                  // Botón "Mi ubicación" eliminado - Google Maps muestra el punto azul automáticamente
                ],
              ),
            ),

            // Botón "Estoy en el bus"
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: _BuildInBusButton(
                  isInBus: controller.isInBus.value,
                  onPressed: controller.toggleInBus,
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
          ],
        );
      }),
    );
  }
}

class _BuildControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _BuildControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.black87,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildInBusButton extends StatelessWidget {
  final bool isInBus;
  final VoidCallback onPressed;

  const _BuildInBusButton({required this.isInBus, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isInBus
                  ? [Colors.red.shade400, Colors.red.shade600]
                  : [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isInBus ? Icons.cancel : Icons.directions_bus,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isInBus ? 'Dejar de reportar' : 'Estoy en el bus',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: Descomentar cuando se implemente Supabase
// class _BuildBusInfoCard extends StatelessWidget {
//   final busLocation;

//   const _BuildBusInfoCard({required this.busLocation});

//   @override
//   Widget build(BuildContext context) {
//     final age = DateTime.now().difference(busLocation.timestamp);
//     final ageText = age.inMinutes < 1
//         ? 'Hace ${age.inSeconds}s'
//         : 'Hace ${age.inMinutes}m';

//     return Material(
//       elevation: 4,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.directions_bus,
//                     color: Colors.green.shade700,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Autobús activo',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       ageText,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Icon(Icons.people, size: 16, color: Colors.grey.shade600),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${busLocation.userCount} usuario${busLocation.userCount != 1 ? "s" : ""} reportando',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
