import 'package:get_storage/get_storage.dart';

class PhoneStorageService {
  static const String _phoneKey = 'user_phones';
  final GetStorage _storage = GetStorage();

  /// Obtiene la lista de teléfonos guardados
  List<Map<String, String>> getSavedPhones() {
    try {
      final List<dynamic>? phones = _storage.read<List<dynamic>>(_phoneKey);
      if (phones == null || phones.isEmpty) {
        return [];
      }
      return phones.map((phone) => Map<String, String>.from(phone)).toList();
    } catch (e) {
      print('❌ Error al obtener teléfonos: $e');
      return [];
    }
  }

  /// Agrega un nuevo teléfono
  Future<bool> addPhone({required String phone, required String label}) async {
    try {
      final phones = getSavedPhones();

      // Verificar si ya existe
      if (phones.any((p) => p['phone'] == phone)) {
        return false;
      }

      phones.add({'phone': phone, 'label': label});

      await _storage.write(_phoneKey, phones);
      return true;
    } catch (e) {
      print('❌ Error al agregar teléfono: $e');
      return false;
    }
  }

  /// Elimina un teléfono
  Future<bool> removePhone(String phone) async {
    try {
      final phones = getSavedPhones();
      phones.removeWhere((p) => p['phone'] == phone);
      await _storage.write(_phoneKey, phones);
      return true;
    } catch (e) {
      print('❌ Error al eliminar teléfono: $e');
      return false;
    }
  }

  /// Actualiza un teléfono existente
  Future<bool> updatePhone({
    required String oldPhone,
    required String newPhone,
    required String label,
  }) async {
    try {
      final phones = getSavedPhones();
      final index = phones.indexWhere((p) => p['phone'] == oldPhone);

      if (index == -1) {
        return false;
      }

      phones[index] = {'phone': newPhone, 'label': label};

      await _storage.write(_phoneKey, phones);
      return true;
    } catch (e) {
      print('❌ Error al actualizar teléfono: $e');
      return false;
    }
  }

  /// Limpia todos los teléfonos
  Future<void> clearPhones() async {
    await _storage.remove(_phoneKey);
  }
}
