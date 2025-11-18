import 'package:supabase_flutter/supabase_flutter.dart';
import '../../modules/agenda/models/agenda_item.dart';

class AgendaSupabaseService {
  final _supabase = Supabase.instance.client;

  // Obtener todos los items de agenda del usuario actual
  Future<List<AgendaItem>> getItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('⚠️ Usuario no autenticado');
        return [];
      }

      final response = await _supabase
          .from('agenda')
          .select()
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((item) => AgendaItem.fromMap(item))
          .toList();

      print('✅ ${items.length} items de agenda cargados');
      return items;
    } catch (e) {
      print('❌ Error al obtener items de agenda: $e');
      rethrow;
    }
  }

  // Crear un nuevo item de agenda
  Future<AgendaItem> addItem(AgendaItem item) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('agenda')
          .insert(item.toInsertMap())
          .select()
          .single();

      print('✅ Item de agenda creado exitosamente');
      return AgendaItem.fromMap(response);
    } catch (e) {
      print('❌ Error al crear item de agenda: $e');
      rethrow;
    }
  }

  // Actualizar un item de agenda existente
  Future<AgendaItem> updateItem(AgendaItem item) async {
    try {
      if (item.id == null) {
        throw Exception('Item sin ID no puede ser actualizado');
      }

      final response = await _supabase
          .from('agenda')
          .update({
            'title': item.title,
            'description': item.description,
            'done': item.done,
            'pinned': item.pinned,
            'when': item.when?.toIso8601String(),
            'category': item.category,
          })
          .eq('id', item.id!)
          .select()
          .single();

      print('✅ Item de agenda actualizado exitosamente');
      return AgendaItem.fromMap(response);
    } catch (e) {
      print('❌ Error al actualizar item de agenda: $e');
      rethrow;
    }
  }

  // Eliminar un item de agenda
  Future<void> removeItem(int id) async {
    try {
      await _supabase
          .from('agenda')
          .delete()
          .eq('id', id);

      print('✅ Item de agenda eliminado exitosamente');
    } catch (e) {
      print('❌ Error al eliminar item de agenda: $e');
      rethrow;
    }
  }

  // Obtener items con recordatorio (when no es null)
  Future<List<AgendaItem>> getItemsWithReminders() async {
    try {
      final response = await _supabase
          .from('agenda')
          .select()
          .not('when', 'is', null)
          .order('when', ascending: true);

      final items = (response as List)
          .map((item) => AgendaItem.fromMap(item))
          .toList();

      return items;
    } catch (e) {
      print('❌ Error al obtener items con recordatorios: $e');
      rethrow;
    }
  }

  // Obtener items por categoría
  Future<List<AgendaItem>> getItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('agenda')
          .select()
          .contains('category', [category])
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((item) => AgendaItem.fromMap(item))
          .toList();

      return items;
    } catch (e) {
      print('❌ Error al obtener items por categoría: $e');
      rethrow;
    }
  }

  // Obtener items fijados (pinned)
  Future<List<AgendaItem>> getPinnedItems() async {
    try {
      final response = await _supabase
          .from('agenda')
          .select()
          .eq('pinned', true)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((item) => AgendaItem.fromMap(item))
          .toList();

      return items;
    } catch (e) {
      print('❌ Error al obtener items fijados: $e');
      rethrow;
    }
  }

  // Marcar item como completado/no completado
  Future<void> toggleDone(int id, bool done) async {
    try {
      await _supabase
          .from('agenda')
          .update({'done': done})
          .eq('id', id);

      print('✅ Estado del item actualizado');
    } catch (e) {
      print('❌ Error al actualizar estado del item: $e');
      rethrow;
    }
  }

  // Fijar/desfijar item
  Future<void> togglePin(int id, bool pinned) async {
    try {
      await _supabase
          .from('agenda')
          .update({'pinned': pinned})
          .eq('id', id);

      print('✅ Pin del item actualizado');
    } catch (e) {
      print('❌ Error al actualizar pin del item: $e');
      rethrow;
    }
  }
}
