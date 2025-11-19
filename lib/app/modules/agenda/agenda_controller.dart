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
    final added = await _scheduleService.addItem(item);
    if (added != null) {
      scheduleItems.insert(0, added);
    }
  }

  Future<void> updateScheduleItem(ScheduleItem updated) async {
    final result = await _scheduleService.updateItem(updated);
    if (result != null) {
      final i = scheduleItems.indexWhere((s) => s.id == result.id);
      if (i != -1) {
        scheduleItems[i] = result;
        scheduleItems.refresh();
      }
    }
  }

  Future<void> removeScheduleItem(ScheduleItem item) async {
    if (item.id == null) return;
    await _scheduleService.removeItem(item.id!);
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
    List<String>? category,
  }) async {
    final item = AgendaItem(
      title: title,
      description: description,
      when: when,
      done: false,
      pinned: false,
      category: category,
    );
    final added = await _service.addItem(item);
    if (added != null) {
      items.insert(0, added);
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
    await _service.removeItem(item.id!);
    items.removeWhere((i) => i.id == item.id);
  }

  Future<void> updateItem(AgendaItem updated) async {
    final result = await _service.updateItem(updated);
    if (result != null) {
      final i = items.indexWhere((it) => it.id == result.id);
      if (i != -1) {
        items[i] = result;
        items.refresh();
      }
    }
  }
}
