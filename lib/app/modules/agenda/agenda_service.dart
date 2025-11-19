import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/agenda_item.dart';

class AgendaService {
  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<AgendaItem>> getItems() async {
    try {
      if (_currentUserId == null) {
        print('⚠️ No hay usuario autenticado');
        return [];
      }

      final response = await _supabase
          .from('agenda')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return response.map((e) {
        final m = Map<String, dynamic>.from(e);
        return AgendaItem.fromMap(m);
      }).toList();
    } catch (e) {
      print('❌ Error al obtener items de agenda: $e');
      return [];
    }
  }

  Future<AgendaItem?> addItem(AgendaItem item) async {
    try {
      if (_currentUserId == null) {
        print('⚠️ No hay usuario autenticado');
        return null;
      }

      // Asegurar que el item tiene el user_id correcto
      final itemWithUser = AgendaItem(
        id: item.id,
        userId: _currentUserId,
        title: item.title,
        description: item.description,
        done: item.done,
        pinned: item.pinned,
        when: item.when,
        category: item.category,
      );

      final response = await _supabase
          .from('agenda')
          .insert(itemWithUser.toInsertMap())
          .select()
          .single();

      return AgendaItem.fromMap(response);
    } catch (e) {
      print('❌ Error al agregar item de agenda: $e');
      return null;
    }
  }

  Future<void> removeItem(int id) async {
    try {
      if (_currentUserId == null) {
        print('⚠️ No hay usuario autenticado');
        return;
      }

      await _supabase
          .from('agenda')
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      print('❌ Error al eliminar item de agenda: $e');
    }
  }

  Future<AgendaItem?> updateItem(AgendaItem item) async {
    if (item.id == null) {
      print('❌ Error: item sin id para actualizar');
      return null;
    }

    if (_currentUserId == null) {
      print('⚠️ No hay usuario autenticado');
      return null;
    }

    try {
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
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return AgendaItem.fromMap(response);
    } catch (e) {
      print('❌ Error al actualizar item de agenda: $e');
      return null;
    }
  }
}
