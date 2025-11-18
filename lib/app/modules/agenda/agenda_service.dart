import 'package:get_storage/get_storage.dart';
import '../../data/services/agenda_supabase_service.dart';

import 'models/agenda_item.dart';

class AgendaService {
  final _box = GetStorage();
  final _key = 'agenda_items';
  final _supabaseService = AgendaSupabaseService();
  
  // Flag para habilitar migración de datos locales a Supabase
  bool _migrationCompleted = false;

  // Método para migrar datos locales a Supabase (ejecutar una sola vez)
  Future<void> migrateLocalDataToSupabase() async {
    if (_migrationCompleted) return;
    
    try {
      final localData = _box.read<List>(_key);
      if (localData == null || localData.isEmpty) {
        _migrationCompleted = true;
        return;
      }

      print('🔄 Migrando ${localData.length} items locales a Supabase...');
      
      for (var item in localData) {
        final m = Map<String, dynamic>.from(item);
        final agendaItem = AgendaItem.fromMap(m);
        
        try {
          await _supabaseService.addItem(agendaItem);
        } catch (e) {
          print('⚠️ Error al migrar item: $e');
        }
      }
      
      print('✅ Migración completada');
      _migrationCompleted = true;
      
      // Opcional: limpiar datos locales después de migración exitosa
      // await _box.remove(_key);
    } catch (e) {
      print('❌ Error durante la migración: $e');
    }
  }

  Future<List<AgendaItem>> getItems() async {
    try {
      // Intentar obtener datos de Supabase
      return await _supabaseService.getItems();
    } catch (e) {
      print('⚠️ Error al obtener items de Supabase, usando datos locales: $e');
      // Fallback a datos locales si Supabase falla
      final data = _box.read<List>(_key);
      if (data == null) return [];
      return data.map((e) {
        final m = Map<String, dynamic>.from(e);
        return AgendaItem.fromMap(m);
      }).toList();
    }
  }

  Future<AgendaItem> addItem(AgendaItem item) async {
    try {
      // Intentar guardar en Supabase
      return await _supabaseService.addItem(item);
    } catch (e) {
      print('⚠️ Error al guardar en Supabase, guardando localmente: $e');
      // Fallback a almacenamiento local
      final list = _box.read<List>(_key) ?? [];
      list.insert(0, item.toMap());
      await _box.write(_key, list);
      rethrow; // Re-lanzar para que el controller sepa que falló
    }
  }

  Future<void> removeItem(int id) async {
    try {
      // Intentar eliminar de Supabase
      await _supabaseService.removeItem(id);
    } catch (e) {
      print('⚠️ Error al eliminar de Supabase, eliminando localmente: $e');
      // Fallback a almacenamiento local
      final list = _box.read<List>(_key) ?? [];
      list.removeWhere((e) => (e as Map)['id'] == id);
      await _box.write(_key, list);
      rethrow;
    }
  }

  Future<AgendaItem> updateItem(AgendaItem item) async {
    try {
      // Intentar actualizar en Supabase
      return await _supabaseService.updateItem(item);
    } catch (e) {
      print('⚠️ Error al actualizar en Supabase, actualizando localmente: $e');
      // Fallback a almacenamiento local
      final list = _box.read<List>(_key) ?? [];
      final idx = list.indexWhere((e) => (e as Map)['id'] == item.id);
      if (idx != -1) {
        list[idx] = item.toMap();
      } else {
        list.insert(0, item.toMap());
      }
      await _box.write(_key, list);
      rethrow;
    }
  }
}
