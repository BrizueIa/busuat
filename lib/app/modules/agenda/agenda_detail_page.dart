// ignore_for_file: use_build_context_synchronously

import 'package:busuat/app/modules/agenda/models/agenda_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'agenda_controller.dart';
import 'agenda_utils.dart';

class AgendaDetailPage extends StatefulWidget {
  final AgendaItem item;
  final bool readOnly;

  const AgendaDetailPage({
    super.key,
    required this.item,
    this.readOnly = false,
  });

  @override
  State<AgendaDetailPage> createState() => _AgendaDetailPageState();
}

class _AgendaDetailPageState extends State<AgendaDetailPage> {
  late final AgendaController controller;
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController categoryCtrl;
  DateTime? when;
  bool hasReminder = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AgendaController>();
    // inicializar con los valores del item actual
    titleCtrl = TextEditingController(text: widget.item.title);
    descCtrl = TextEditingController(text: widget.item.description);
    categoryCtrl = TextEditingController(text: widget.item.category ?? '');
    when = widget.item.when;
    hasReminder = when != null;
    // Abrir en modo edición al entrar en detalle
    isEditing = true;
  }

  void _enterEdit() {
    setState(() {
      // refrescar controles con valores más recientes
      final current = controller.items.firstWhere(
        (e) => e.id == widget.item.id,
        orElse: () => widget.item,
      );
      titleCtrl.text = current.title;
      descCtrl.text = current.description;
      categoryCtrl.text = current.category ?? '';
      when = current.when;
      hasReminder = when != null;
      isEditing = true;
    });
  }

  Future<void> _save() async {
    final title = titleCtrl.text.trim();
    final desc = descCtrl.text.trim();
    if (title.isEmpty) return;
    final current = controller.items.firstWhere(
      (e) => e.id == widget.item.id,
      orElse: () => widget.item,
    );
    final updated = current.copyWith(
      title: title,
      description: desc,
      when: when,
      whenIsProvided: true,
      category: categoryCtrl.text.trim(),
      categoryIsProvided: true,
    );
    await controller.updateItem(updated);
    setState(() {
      isEditing = false;
      hasReminder = updated.when != null;
    });
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar'),
                  content: const Text('¿Eliminar este recordatorio?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await controller.removeItem(widget.item);
                Get.snackbar(
                  'Eliminado',
                  'Recordatorio eliminado',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing ? _buildEditor(context) : _buildReader(context),
      ),
    );
  }

  Widget _buildReader(BuildContext context) {
    return Obx(() {
      final current = controller.items.firstWhere(
        (e) => e.id == widget.item.id,
        orElse: () => widget.item,
      );
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _enterEdit,
              child: Text(
                current.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if ((current.category ?? '').isNotEmpty)
              Chip(label: Text(current.category!)),
            const SizedBox(height: 12),
            if (current.description.isNotEmpty)
              GestureDetector(
                onTap: _enterEdit,
                child: SelectableText(
                  current.description,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            else
              const Text(
                'Sin descripción',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 20),
            if (current.when != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(formatDate(current.when)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(formatTime(current.when)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    current.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: current.pinned ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () async {
                    final updated = current.copyWith(pinned: !current.pinned);
                    await controller.updateItem(updated);
                  },
                ),
                const SizedBox(width: 12),
                Text(current.pinned ? 'Fijada' : 'No fijada'),
                const SizedBox(width: 24),
                Checkbox(
                  value: current.done,
                  onChanged: (v) async {
                    final updated = current.copyWith(done: v ?? false);
                    await controller.updateItem(updated);
                  },
                ),
                const SizedBox(width: 4),
                const Text('Hecho'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          minLines: 3,
          maxLines: null,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Establecer recordatorio'),
          value: hasReminder,
          onChanged: (v) => setState(() {
            hasReminder = v;
            if (!hasReminder) {
              when = null;
            } else {
              when ??= DateTime.now().add(const Duration(hours: 1));
            }
          }),
        ),
        const SizedBox(height: 12),
        if (hasReminder) ...[
          Row(
            children: [
              Expanded(child: Text('Fecha: ${formatDate(when)}')),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () async {
                  final d = await showDatePicker(
                    context: Navigator.of(context, rootNavigator: true).context,
                    initialDate: when ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es', 'ES'),
                  );
                  if (d != null) {
                    setState(() {
                      when = DateTime(
                        d.year,
                        d.month,
                        d.day,
                        when?.hour ?? 0,
                        when?.minute ?? 0,
                      );
                    });
                  }
                },
              ),
            ],
          ),

          Row(
            children: [
              Expanded(child: Text('Hora: ${formatTime(when)}')),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final t = await showTimePicker(
                    context: Navigator.of(context, rootNavigator: true).context,
                    initialTime: TimeOfDay.fromDateTime(when ?? DateTime.now()),
                    builder: (context, child) => Localizations.override(
                      context: context,
                      locale: const Locale('es', 'ES'),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                  if (t != null) {
                    setState(() {
                      when = DateTime(
                        when?.year ?? DateTime.now().year,
                        when?.month ?? DateTime.now().month,
                        when?.day ?? DateTime.now().day,
                        t.hour,
                        t.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ],
    );
  }

  // format helpers delegated to agenda_utils.dart
}
