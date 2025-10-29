import 'package:flutter/material.dart';
import '../map_controller.dart';

class MarkerTypeDropdown extends StatelessWidget {
  final MarkerType selectedType;
  final Function(MarkerType) onChanged;

  const MarkerTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<MarkerType>(
          value: selectedType,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          elevation: 8,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          onChanged: (MarkerType? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: [
            DropdownMenuItem<MarkerType>(
              value: MarkerType.ninguno,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ninguno',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            DropdownMenuItem<MarkerType>(
              value: MarkerType.facultades,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 20, color: Colors.purple.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Facultades',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            DropdownMenuItem<MarkerType>(
              value: MarkerType.paradas,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Paradas',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            DropdownMenuItem<MarkerType>(
              value: MarkerType.accesos,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Accesos',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
