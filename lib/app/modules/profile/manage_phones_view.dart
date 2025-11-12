import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/phone_storage_service.dart';

class ManagePhonesView extends StatefulWidget {
  const ManagePhonesView({super.key});

  @override
  State<ManagePhonesView> createState() => _ManagePhonesViewState();
}

class _ManagePhonesViewState extends State<ManagePhonesView> {
  final PhoneStorageService _phoneService = PhoneStorageService();
  final RxList<Map<String, String>> phones = <Map<String, String>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadPhones();
  }

  void _loadPhones() {
    phones.value = _phoneService.getSavedPhones();
  }

  void _showAddPhoneDialog() {
    final phoneController = TextEditingController();
    final labelController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Agregar Teléfono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Etiqueta',
                hintText: 'Ej: Personal, Trabajo',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de Teléfono',
                hintText: 'Ej: 8331234567',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isEmpty ||
                  labelController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Por favor completa todos los campos',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final success = await _phoneService.addPhone(
                phone: phoneController.text.trim(),
                label: labelController.text.trim(),
              );

              if (success) {
                Get.back();
                _loadPhones();
                Get.snackbar(
                  'Éxito',
                  'Teléfono agregado correctamente',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Este número ya está registrado',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(Map<String, String> phone) {
    final phoneController = TextEditingController(text: phone['phone']);
    final labelController = TextEditingController(text: phone['label']);

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Teléfono'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Etiqueta',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _phoneService.updatePhone(
                oldPhone: phone['phone']!,
                newPhone: phoneController.text.trim(),
                label: labelController.text.trim(),
              );

              if (success) {
                Get.back();
                _loadPhones();
                Get.snackbar(
                  'Éxito',
                  'Teléfono actualizado',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deletePhone(String phone) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Teléfono'),
        content: const Text('¿Estás seguro de eliminar este número?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _phoneService.removePhone(phone);
              Get.back();
              _loadPhones();
              Get.snackbar(
                'Éxito',
                'Teléfono eliminado',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Teléfonos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (phones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_disabled,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay teléfonos registrados',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega un número para usarlo en tus publicaciones',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: phones.length,
          itemBuilder: (context, index) {
            final phone = phones[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.phone, color: Colors.orange.shade700),
                ),
                title: Text(
                  phone['label']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(phone['phone']!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditPhoneDialog(phone),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePhone(phone['phone']!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPhoneDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
