import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../agenda/agenda_controller.dart';
import '../../agenda/models/schedule_item.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _horarioExpanded = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final user = controller.currentUser.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar de estudiante
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 80, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              // Título
              const Text(
                'Estudiante UAT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              // Badge de verificado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cuenta verificada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Email
              if (user?.email != null)
                Text(
                  user!.email!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 40),

              // Estado de la cuenta
              _buildSectionCard(
                title: 'Estado de la Cuenta',
                icon: Icons.account_circle_outlined,
                iconColor: Colors.orange,
                children: [
                  _buildInfoRow(
                    Icons.school,
                    'Tipo de cuenta',
                    'Estudiante',
                    Colors.orange.shade700,
                  ),
                  const Divider(height: 30),
                  _buildInfoRow(
                    Icons.verified_user,
                    'Estado',
                    'Verificado',
                    Colors.green.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Sección: Horario (debajo de Estado de la Cuenta)
              _buildSectionCard(
                title: 'Horario',
                icon: Icons.schedule,
                iconColor: Colors.deepPurple,
                headerTrailing: IconButton(
                  icon: Transform.rotate(
                    angle: _horarioExpanded
                        ? 0
                        : 3.14, // rotate to indicate collapsed
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: () =>
                      setState(() => _horarioExpanded = !_horarioExpanded),
                ),
                children: _horarioExpanded
                    ? [
                        GetX<AgendaController>(
                          builder: (agenda) {
                            final items = agenda.scheduleItems;
                            if (items.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Aún no hay materias en tu horario.',
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }

                            return Column(
                              children: items.map((s) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(s.subject),
                                  subtitle: Text(
                                    '${s.grade ?? ''} ${s.group ?? ''} · ${s.start} - ${s.end} · ${s.classroom ?? ''}',
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GetX<AgendaController>(
                                builder: (agenda) {
                                  final has = agenda.scheduleItems.isNotEmpty;
                                  return ElevatedButton(
                                    onPressed: () async {
                                      // Pedir cuántas materias agregar (1-10)
                                      final cnt = await _askHowMany(context);
                                      if (cnt == null || cnt <= 0) return;
                                      for (var i = 0; i < cnt; i++) {
                                        final ok = await _openScheduleDialog(
                                          context,
                                        );
                                        if (!ok) break; // cancelar secuencia
                                      }
                                    },
                                    child: Text(
                                      has ? 'Agregar materia' : 'Crear horario',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _manageSubjects(context),
                                child: const Text('Gestionar materias'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => _showPreview(context),
                            child: const Text('Vista previa del horario'),
                          ),
                        ),
                      ]
                    : [const SizedBox.shrink()],
              ),

              const SizedBox(height: 30),

              // Botón de cerrar sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro de que deseas salir?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.logout();
                            },
                            child: const Text(
                              'Salir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
    Widget? headerTrailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, color: iconColor ?? Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<int?> _askHowMany(BuildContext context) async {
    final ctl = TextEditingController(text: '1');
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cuántas materias desea agregar?'),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '1 - 10'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctl.text) ?? 0;
              final clamped = v.clamp(1, 10);
              Navigator.of(ctx).pop(clamped);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return res;
  }

  Future<bool> _openScheduleDialog(
    BuildContext context, [
    ScheduleItem? existing,
  ]) async {
    final agenda = Get.find<AgendaController>();
    final subjectCtl = TextEditingController(text: existing?.subject ?? '');
    final professorCtl = TextEditingController(text: existing?.professor ?? '');
    final gradeCtl = TextEditingController(text: existing?.grade ?? '');
    final groupCtl = TextEditingController(text: existing?.group ?? '');
    final classroomCtl = TextEditingController(text: existing?.classroom ?? '');

    TimeOfDay? startTD;
    TimeOfDay? endTD;
    if (existing != null) {
      final ps = existing.start.split(':');
      startTD = TimeOfDay(
        hour: int.tryParse(ps[0]) ?? 0,
        minute: int.tryParse(ps.length > 1 ? ps[1] : '0') ?? 0,
      );
      final pe = existing.end.split(':');
      endTD = TimeOfDay(
        hour: int.tryParse(pe[0]) ?? 0,
        minute: int.tryParse(pe.length > 1 ? pe[1] : '0') ?? 0,
      );
    }

    final weekdays = <int>{};
    if (existing != null) weekdays.addAll(existing.weekdays);

    String formatTD(TimeOfDay? t) => t == null ? '--:--' : t.format(context);

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setState) {
            Future<void> pickStart() async {
              final t = await showTimePicker(
                context: ctx2,
                initialTime: startTD ?? TimeOfDay(hour: 8, minute: 0),
              );
              if (t != null) setState(() => startTD = t);
            }

            Future<void> pickEnd() async {
              final t = await showTimePicker(
                context: ctx2,
                initialTime: endTD ?? TimeOfDay(hour: 9, minute: 0),
              );
              if (t != null) setState(() => endTD = t);
            }

            Widget weekdayChip(int day, String label) {
              final selected = weekdays.contains(day);
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v)
                      weekdays.add(day);
                    else
                      weekdays.remove(day);
                  });
                },
              );
            }

            return AlertDialog(
              title: Text(
                existing == null ? 'Agregar materia' : 'Editar materia',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: subjectCtl,
                      decoration: const InputDecoration(labelText: 'Materia'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: groupCtl,
                      decoration: const InputDecoration(labelText: 'Grupo'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: gradeCtl,
                      decoration: const InputDecoration(labelText: 'Grado'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: professorCtl,
                      decoration: const InputDecoration(labelText: 'Profesor'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: classroomCtl,
                      decoration: const InputDecoration(
                        labelText: 'Aula (opcional)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: pickStart,
                            child: Text('Inicio: ${formatTD(startTD)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: pickEnd,
                            child: Text('Fin: ${formatTD(endTD)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        weekdayChip(1, 'Lun'),
                        weekdayChip(2, 'Mar'),
                        weekdayChip(3, 'Mié'),
                        weekdayChip(4, 'Jue'),
                        weekdayChip(5, 'Vie'),
                        weekdayChip(6, 'Sáb'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    final subject = subjectCtl.text.trim();
                    if (subject.isEmpty) {
                      // show simple error
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        const SnackBar(content: Text('Ingrese la materia')),
                      );
                      return;
                    }
                    if (weekdays.isEmpty) {
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        const SnackBar(
                          content: Text('Seleccione al menos un día'),
                        ),
                      );
                      return;
                    }
                    if (startTD == null || endTD == null) {
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        const SnackBar(
                          content: Text('Seleccione horario inicio/fin'),
                        ),
                      );
                      return;
                    }
                    final startStr =
                        '${startTD!.hour.toString().padLeft(2, '0')}:${startTD!.minute.toString().padLeft(2, '0')}';
                    final endStr =
                        '${endTD!.hour.toString().padLeft(2, '0')}:${endTD!.minute.toString().padLeft(2, '0')}';
                    if ((startTD!.hour * 60 + startTD!.minute) >=
                        (endTD!.hour * 60 + endTD!.minute)) {
                      ScaffoldMessenger.of(ctx2).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Horario final debe ser posterior al inicio',
                          ),
                        ),
                      );
                      return;
                    }

                    if (existing == null) {
                      await agenda.addScheduleItem(
                        subject: subject,
                        weekdays: weekdays.toList(),
                        start: startStr,
                        end: endStr,
                        grade: gradeCtl.text.trim().isEmpty
                            ? null
                            : gradeCtl.text.trim(),
                        group: groupCtl.text.trim().isEmpty
                            ? null
                            : groupCtl.text.trim(),
                        classroom: classroomCtl.text.trim().isEmpty
                            ? null
                            : classroomCtl.text.trim(),
                        professor: professorCtl.text.trim().isEmpty
                            ? null
                            : professorCtl.text.trim(),
                      );
                    } else {
                      final updated = ScheduleItem(
                        id: existing.id,
                        subject: subject,
                        weekdays: weekdays.toList(),
                        start: startStr,
                        end: endStr,
                        grade: gradeCtl.text.trim().isEmpty
                            ? null
                            : gradeCtl.text.trim(),
                        group: groupCtl.text.trim().isEmpty
                            ? null
                            : groupCtl.text.trim(),
                        classroom: classroomCtl.text.trim().isEmpty
                            ? null
                            : classroomCtl.text.trim(),
                        professor: professorCtl.text.trim().isEmpty
                            ? null
                            : professorCtl.text.trim(),
                      );
                      await agenda.updateScheduleItem(updated);
                    }

                    Navigator.of(ctx2).pop(true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    return saved == true;
  }

  void _manageSubjects(BuildContext context) {
    final agenda = Get.find<AgendaController>();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Gestionar materias'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() {
              final items = agenda.scheduleItems;
              if (items.isEmpty) return const Text('No hay materias.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (c, i) {
                  final s = items[i];
                  return ListTile(
                    title: Text(s.subject),
                    subtitle: Text(
                      '${s.grade ?? ''} ${s.group ?? ''} · ${s.start}-${s.end}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _openScheduleDialog(context, s);
                            _manageSubjects(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c2) => AlertDialog(
                                title: const Text('Eliminar'),
                                content: const Text('¿Eliminar materia?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(c2).pop(false),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(c2).pop(true),
                                    child: const Text('Sí'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true)
                              await agenda.removeScheduleItem(s);
                            // refresh dialog
                            (ctx as Element).markNeedsBuild();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showPreview(BuildContext context) {
    final agenda = Get.find<AgendaController>();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Vista previa del horario'),
          content: SingleChildScrollView(
            child: Obx(() {
              final items = agenda.scheduleItems;
              if (items.isEmpty)
                return const Text('No hay materias para mostrar.');

              // Build simple table grouped by grade/group and time
              final rows = <TableRow>[];
              rows.add(
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Grupo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Hora',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (var d = 1; d <= 6; d++)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _weekdayLabel(d),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Profesor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              for (var s in items) {
                final dayCells = <Widget>[];
                for (var d = 1; d <= 6; d++) {
                  dayCells.add(
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(s.weekdays.contains(d) ? s.subject : ''),
                    ),
                  );
                }
                rows.add(
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${s.grade ?? ''} ${s.group ?? ''}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${s.start} - ${s.end}'),
                      ),
                      ...dayCells,
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(s.professor ?? ''),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: rows,
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  static String _weekdayLabel(int d) {
    switch (d) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      default:
        return '';
    }
  }
}
