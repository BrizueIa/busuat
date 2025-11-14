// ignore_for_file: unnecessary_import, use_build_context_synchronously, curly_braces_in_flow_control_structures
import 'package:busuat/app/modules/agenda/models/agenda_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'agenda_controller.dart';
import 'agenda_detail_page.dart';
import 'agenda_utils.dart';
// detalle: existe `AgendaDetailPage` para vista completa/lectura
import 'package:flutter/widgets.dart';

class AgendaPage extends GetView<AgendaController> {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgendaController>()) {
      Get.put(AgendaController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => controller.setViewMode(v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'lista', child: Text('Lista')),
              const PopupMenuItem(value: 'diaria', child: Text('Diaria')),
              const PopupMenuItem(value: 'semanal', child: Text('Semanal')),
              const PopupMenuItem(value: 'mensual', child: Text('Mensual')),
            ],
            icon: const Icon(Icons.view_agenda),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.items.toList();
        if (items.isEmpty) {
          return const Center(child: Text('No hay recordatorios'));
        }

        // helpers
        bool sameDay(DateTime a, DateTime b) =>
            a.year == b.year && a.month == b.month && a.day == b.day;

        final view = controller.viewMode.value;
        final focus = controller.focusDate.value;

        // categories available (non-empty)
        final categories = items
            .map((e) => e.category)
            .where((c) => c != null && c.trim().isNotEmpty)
            .map((c) => c!.trim())
            .toSet()
            .toList();

        final selCat = controller.selectedCategory.value;

        final notes = items
            .where(
              (i) =>
                  i.when == null &&
                  (selCat == null || (i.category ?? '') == selCat),
            )
            .toList();
        final dated = items
            .where(
              (i) =>
                  i.when != null &&
                  (selCat == null || (i.category ?? '') == selCat),
            )
            .toList();

        List<AgendaItem> filteredDated;
        if (view == 'lista') {
          filteredDated = dated;
        } else if (view == 'diaria') {
          filteredDated = dated
              .where((i) => sameDay(i.when!.toLocal(), focus.toLocal()))
              .toList();
        } else if (view == 'semanal') {
          final start = focus.toLocal().subtract(
            Duration(days: focus.toLocal().weekday - 1),
          );
          final end = start.add(const Duration(days: 6));
          filteredDated = dated.where((i) {
            final d = i.when!.toLocal();
            return !d.isBefore(start) && !d.isAfter(end);
          }).toList();
        } else if (view == 'mensual') {
          filteredDated = dated.where((i) {
            final d = i.when!.toLocal();
            return d.year == focus.toLocal().year &&
                d.month == focus.toLocal().month;
          }).toList();
        } else {
          filteredDated = dated;
        }

        // Agrupar por fecha las entradas filtradas
        final Map<String, List<AgendaItem>> groups = {};
        for (final it in filteredDated) {
          final d = it.when!.toLocal();
          final key =
              '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          groups.putIfAbsent(key, () => []).add(it);
        }
        if (notes.isNotEmpty)
          groups.putIfAbsent('notes', () => []).addAll(notes);

        // ordenar keys
        final keysWithDate = groups.keys.where((k) => k != 'notes').toList();
        if (controller.sortMode.value == 'recientes') {
          keysWithDate.sort((a, b) => b.compareTo(a));
        } else {
          keysWithDate.sort((a, b) => a.compareTo(b));
        }
        final sortedKeys2 = [...keysWithDate];
        if (groups.containsKey('notes')) sortedKeys2.add('notes');

        // header for view navigation when not lista
        Widget viewHeader() {
          if (view == 'lista') return const SizedBox.shrink();
          String label;
          if (view == 'diaria') {
            label = formatDate(focus);
          } else if (view == 'semanal') {
            final start = focus.toLocal().subtract(
              Duration(days: focus.toLocal().weekday - 1),
            );
            final end = start.add(const Duration(days: 6));
            label = '${formatDate(start)} - ${formatDate(end)}';
          } else if (view == 'mensual') {
            label = '${focus.month.toString().padLeft(2, '0')}/${focus.year}';
          } else {
            label = '';
          }
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    if (view == 'diaria')
                      controller.setFocusDate(
                        controller.focusDate.value.subtract(
                          const Duration(days: 1),
                        ),
                      );
                    if (view == 'semanal')
                      controller.setFocusDate(
                        controller.focusDate.value.subtract(
                          const Duration(days: 7),
                        ),
                      );
                    if (view == 'mensual')
                      controller.setFocusDate(
                        DateTime(
                          controller.focusDate.value.year,
                          controller.focusDate.value.month - 1,
                          controller.focusDate.value.day,
                        ),
                      );
                  },
                ),
                Expanded(child: Text(label, textAlign: TextAlign.center)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.focusDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) controller.setFocusDate(picked);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    if (view == 'diaria')
                      controller.setFocusDate(
                        controller.focusDate.value.add(const Duration(days: 1)),
                      );
                    if (view == 'semanal')
                      controller.setFocusDate(
                        controller.focusDate.value.add(const Duration(days: 7)),
                      );
                    if (view == 'mensual')
                      controller.setFocusDate(
                        DateTime(
                          controller.focusDate.value.year,
                          controller.focusDate.value.month + 1,
                          controller.focusDate.value.day,
                        ),
                      );
                  },
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // categories filter chips
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 8.0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() {
                        final sel = controller.selectedCategory.value;
                        return Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: const Text('Todas'),
                                selected: sel == null,
                                onSelected: (_) =>
                                    controller.setSelectedCategory(null),
                              ),
                            ),
                            ...categories.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text(c),
                                  selected:
                                      controller.selectedCategory.value == c,
                                  onSelected: (_) =>
                                      controller.setSelectedCategory(
                                        controller.selectedCategory.value == c
                                            ? null
                                            : c,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            viewHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: sortedKeys2.length,
                itemBuilder: (context, idx) {
                  final key = sortedKeys2[idx];
                  final list = groups[key]!;
                  // ordenar items internos: pineados al frente, luego por fecha si existe
                  list.sort((a, b) {
                    if (a.pinned && !b.pinned) return -1;
                    if (!a.pinned && b.pinned) return 1;
                    if (a.when != null && b.when != null)
                      return a.when!.compareTo(b.when!);
                    return 0;
                  });

                  final headerIsNotes = key == 'notes';
                  final headerLabel = headerIsNotes
                      ? 'Notas'
                      : formatDate(
                          DateTime(
                            int.parse(key.split('-')[0]),
                            int.parse(key.split('-')[1]),
                            int.parse(key.split('-')[2]),
                          ),
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.orange.shade50,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          headerLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                      ...list.map((item) {
                        final doneStyle = item.done
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              )
                            : const TextStyle();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          child: GestureDetector(
                            onTap: () => Get.to(
                              () =>
                                  AgendaDetailPage(item: item, readOnly: false),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      8,
                                      8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: item.done,
                                          onChanged: (v) async {
                                            final updated = item.copyWith(
                                              done: v ?? false,
                                            );
                                            await controller.updateItem(
                                              updated,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: doneStyle.copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      item.pinned
                                                          ? Icons.push_pin
                                                          : Icons
                                                                .push_pin_outlined,
                                                      size: 18,
                                                      color: item.pinned
                                                          ? Colors.orange
                                                          : Colors.grey[600],
                                                    ),
                                                    onPressed: () async {
                                                      final updated = item
                                                          .copyWith(
                                                            pinned:
                                                                !item.pinned,
                                                          );
                                                      await controller
                                                          .updateItem(updated);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              if (item.description.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 6.0,
                                                        right: 8.0,
                                                      ),
                                                  child: Text(
                                                    item.description,
                                                    style: doneStyle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      children: [
                                        if (item.when != null)
                                          Text(
                                            formatTime(item.when),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Eliminar'),
                                                content: const Text(
                                                  '¿Eliminar este recordatorio?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Eliminar',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await controller.removeItem(item);
                                              Get.snackbar(
                                                'Eliminado',
                                                'Recordatorio eliminado',
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      }),
      // note: view controls handled above via controller.viewMode
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    DateTime when = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (_) {
        bool hasReminder = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final displayWhen = hasReminder ? when : null;
            return AlertDialog(
              title: const Text('Añadir'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Establecer recordatorio'),
                    value: hasReminder,
                    onChanged: (v) => setState(() => hasReminder = v),
                  ),
                  if (hasReminder) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text('Fecha: ${formatDate(displayWhen)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: Navigator.of(
                                context,
                                rootNavigator: true,
                              ).context,
                              initialDate: when,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: const Locale('es', 'ES'),
                            );
                            if (d != null) {
                              setState(
                                () => when = DateTime(
                                  d.year,
                                  d.month,
                                  d.day,
                                  when.hour,
                                  when.minute,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Hora: ${formatTime(displayWhen)}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: Navigator.of(
                                context,
                                rootNavigator: true,
                              ).context,
                              initialTime: TimeOfDay.fromDateTime(when),
                              builder: (context, child) =>
                                  Localizations.override(
                                    context: context,
                                    locale: const Locale('es', 'ES'),
                                    child: child ?? const SizedBox.shrink(),
                                  ),
                            );
                            if (t != null)
                              setState(
                                () => when = DateTime(
                                  when.year,
                                  when.month,
                                  when.day,
                                  t.hour,
                                  t.minute,
                                ),
                              );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    final category = categoryCtrl.text.trim();
                    if (title.isEmpty) return;
                    await controller.addItem(
                      title,
                      description,
                      hasReminder ? when : null,
                      category: category.isEmpty ? null : category,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
