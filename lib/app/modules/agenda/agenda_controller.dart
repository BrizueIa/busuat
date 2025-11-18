// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/agenda_item.dart';
import 'agenda_service.dart';
import 'models/schedule_item.dart';
import 'schedule_service.dart';

class AgendaController extends GetxController {
  final AgendaService _service = AgendaService();

  final items = <AgendaItem>[].obs;
  final scheduleItems = <ScheduleItem>[].obs;
  final _scheduleService = ScheduleService();
  
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadSchedule();
    _migrateLocalData();
  }

  // Migrar datos locales a Supabase en el primer inicio
  Future<void> _migrateLocalData() async {
    try {
      await _service.migrateLocalDataToSupabase();
    } catch (e) {
      print('⚠️ Error al migrar datos locales: $e');
    }
  }

  Future<void> loadSchedule() async {
    final loaded = await _scheduleService.getItems();
    scheduleItems.assignAll(loaded);
  }

  Future<void> addScheduleItem({
    required String subject,
    required List<int> weekdays,
    required String start,
    required String end,
    String? location,
    String? grade,
    String? group,
    String? classroom,
    String? professor,
  }) async {
    final item = ScheduleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      weekdays: weekdays,
      start: start,
      end: end,
      location: location,
      grade: grade,
      group: group,
      classroom: classroom,
      professor: professor,
    );
    await _scheduleService.addItem(item);
    scheduleItems.insert(0, item);
  }

  Future<void> updateScheduleItem(ScheduleItem updated) async {
    await _scheduleService.updateItem(updated);
    final i = scheduleItems.indexWhere((s) => s.id == updated.id);
    if (i != -1) {
      scheduleItems[i] = updated;
      scheduleItems.refresh();
    }
  }

  Future<void> removeScheduleItem(ScheduleItem item) async {
    await _scheduleService.removeItem(item.id);
    scheduleItems.removeWhere((s) => s.id == item.id);
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      final loaded = await _service.getItems();
      items.assignAll(loaded);
    } catch (e) {
      print('❌ Error al cargar items: $e');
      // Mostrar mensaje de error al usuario si es necesario
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(
    String title,
    String description,
    DateTime? when, {
    List<String>? category,  // Cambiado a List<String>?
  }) async {
    try {
      isLoading.value = true;
      final item = AgendaItem(
        title: title,
        description: description,
        when: when,
        done: false,
        pinned: false,
        category: category,
      );
      final created = await _service.addItem(item);
      items.insert(0, created);
    } catch (e) {
      print('❌ Error al agregar item: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // sortMode: 'recientes' | 'antiguas'
  final sortMode = 'recientes'.obs;

  // viewMode: 'lista' | 'diaria' | 'semanal' | 'mensual'
  final viewMode = 'lista'.obs;
  final focusDate = DateTime.now().obs;
  // selected category filter (null == all)
  final selectedCategory = RxnString(null);

  void setSelectedCategory(String? c) {
    selectedCategory.value = c;
  }

  void setViewMode(String mode) {
    viewMode.value = mode;
  }

  void setFocusDate(DateTime d) {
    focusDate.value = d;
  }

  void setSortMode(String mode) {
    sortMode.value = mode;
    items.refresh();
  }

  Future<void> removeItem(AgendaItem item) async {
    if (item.id == null) return;
    
    try {
      isLoading.value = true;
      await _service.removeItem(item.id!);
      items.removeWhere((i) => i.id == item.id);
    } catch (e) {
      print('❌ Error al eliminar item: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(AgendaItem updated) async {
    try {
      isLoading.value = true;
      final result = await _service.updateItem(updated);
      final i = items.indexWhere((it) => it.id == result.id);
      if (i != -1) {
        items[i] = result;
        items.refresh();
      }
    } catch (e) {
      print('❌ Error al actualizar item: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
