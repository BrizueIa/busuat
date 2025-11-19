// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'agenda_controller.dart';
import 'agenda_utils.dart';

class AgendaCreatePage extends StatefulWidget {
  const AgendaCreatePage({super.key});

  @override
  State<AgendaCreatePage> createState() => _AgendaCreatePageState();
}

class _AgendaCreatePageState extends State<AgendaCreatePage> {
  late final AgendaController controller;
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController categoryCtrl;
  DateTime? when;
  bool hasReminder = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AgendaController>();
    titleCtrl = TextEditingController();
    descCtrl = TextEditingController();
    categoryCtrl = TextEditingController();
    when = null;
    hasReminder = false;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleCtrl.text.trim();
    final desc = descCtrl.text.trim();
    if (title.isEmpty) return;

    // Parse categories from comma-separated string
    List<String>? categories;
    if (categoryCtrl.text.trim().isNotEmpty) {
      categories = categoryCtrl.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (categories.isEmpty) categories = null;
    }

    await controller.addItem(
      title,
      desc,
      hasReminder ? when : null,
      category: categories,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Añadir'),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categorías',
                  hintText: 'Separa múltiples categorías con comas',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                minLines: 3,
                maxLines: null,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 6),
              if (hasReminder) ...[
                Row(
                  children: [
                    Expanded(child: Text('Fecha: ${formatDate(when)}')),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: Navigator.of(
                            context,
                            rootNavigator: true,
                          ).context,
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
                          context: Navigator.of(
                            context,
                            rootNavigator: true,
                          ).context,
                          initialTime: TimeOfDay.fromDateTime(
                            when ?? DateTime.now(),
                          ),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _save,
                    child: const Text('Añadir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
