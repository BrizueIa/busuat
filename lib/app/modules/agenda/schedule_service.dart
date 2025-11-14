import 'package:get_storage/get_storage.dart';

import 'models/schedule_item.dart';

class ScheduleService {
  final _box = GetStorage();
  final _key = 'agenda_schedule';

  Future<List<ScheduleItem>> getItems() async {
    final data = _box.read<List>(_key);
    if (data == null) return [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e);
      return ScheduleItem.fromMap(m);
    }).toList();
  }

  Future<void> addItem(ScheduleItem item) async {
    final list = _box.read<List>(_key) ?? [];
    list.insert(0, item.toMap());
    await _box.write(_key, list);
  }

  Future<void> removeItem(String id) async {
    final list = _box.read<List>(_key) ?? [];
    list.removeWhere((e) => (e as Map)['id'] == id);
    await _box.write(_key, list);
  }

  Future<void> updateItem(ScheduleItem item) async {
    final list = _box.read<List>(_key) ?? [];
    final idx = list.indexWhere((e) => (e as Map)['id'] == item.id);
    if (idx != -1) {
      list[idx] = item.toMap();
    } else {
      list.insert(0, item.toMap());
    }
    await _box.write(_key, list);
  }
}
