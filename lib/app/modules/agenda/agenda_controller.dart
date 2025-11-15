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

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadSchedule();
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
    final loaded = await _service.getItems();
    items.assignAll(loaded);
  }

  Future<void> addItem(
    String title,
    String description,
    DateTime? when, {
    String? category,
  }) async {
    final item = AgendaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      when: when,
      done: false,
      pinned: false,
      category: category,
    );
    await _service.addItem(item);
    items.insert(0, item);
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
    await _service.removeItem(item.id);
    items.removeWhere((i) => i.id == item.id);
  }

  Future<void> updateItem(AgendaItem updated) async {
    await _service.updateItem(updated);
    final i = items.indexWhere((it) => it.id == updated.id);
    if (i != -1) {
      items[i] = updated;
      items.refresh();
    }
  }
}
