import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/schedule_item.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<ScheduleItem>> getItems() async {
    try {
      if (_currentUserId == null) {
        print('⚠️ No hay usuario autenticado');
        return [];
      }

      final response = await _supabase
          .from('schedule')
          .select()
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return response.map((e) {
        final m = Map<String, dynamic>.from(e);
        return ScheduleItem.fromMap(m);
      }).toList();
    } catch (e) {
      print('❌ Error al obtener items del horario: $e');
      return [];
    }
  }

  Future<ScheduleItem?> addItem(ScheduleItem item) async {
    try {
      if (_currentUserId == null) {
        print('⚠️ No hay usuario autenticado');
        return null;
      }

      // Asegurar que el item tiene el user_id correcto
      final itemWithUser = ScheduleItem(
        id: item.id,
        userId: _currentUserId,
        subject: item.subject,
        weekdays: item.weekdays,
        start: item.start,
        end: item.end,
        location: item.location,
        grade: item.grade,
        group: item.group,
        classroom: item.classroom,
        professor: item.professor,
      );

      final response = await _supabase
          .from('schedule')
          .insert(itemWithUser.toInsertMap())
          .select()
          .single();

      return ScheduleItem.fromMap(response);
    } catch (e) {
      print('❌ Error al agregar item del horario: $e');
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
          .from('schedule')
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      print('❌ Error al eliminar item del horario: $e');
    }
  }

  Future<ScheduleItem?> updateItem(ScheduleItem item) async {
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
          .from('schedule')
          .update({
            'subject': item.subject,
            'weekdays': item.weekdays,
            'start': item.start,
            'end': item.end,
            'location': item.location,
            'grade': item.grade,
            'group': item.group,
            'classroom': item.classroom,
            'professor': item.professor,
          })
          .eq('id', item.id!)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return ScheduleItem.fromMap(response);
    } catch (e) {
      print('❌ Error al actualizar item del horario: $e');
      return null;
    }
  }
}
