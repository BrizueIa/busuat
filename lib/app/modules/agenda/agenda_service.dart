import 'package:get_storage/get_storage.dart';

import 'models/agenda_item.dart';

class AgendaService {
  final _box = GetStorage();
  final _key = 'agenda_items';

  Future<List<AgendaItem>> getItems() async {
    final data = _box.read<List>(_key);
    if (data == null) return [];
    return data.map((e) {
      final m = Map<String, dynamic>.from(e);
      return AgendaItem.fromMap(m);
    }).toList();
  }

  Future<void> addItem(AgendaItem item) async {
    final list = _box.read<List>(_key) ?? [];
    list.insert(0, item.toMap());
    await _box.write(_key, list);
  }

  Future<void> removeItem(String id) async {
    final list = _box.read<List>(_key) ?? [];
    list.removeWhere((e) => (e as Map)['id'] == id);
    await _box.write(_key, list);
  }

  Future<void> updateItem(AgendaItem item) async {
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
