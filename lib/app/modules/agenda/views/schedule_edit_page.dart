import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busuat/app/modules/agenda/agenda_controller.dart';
import 'package:busuat/app/modules/agenda/models/schedule_item.dart';

class ScheduleEditPage extends StatefulWidget {
  final ScheduleItem? existing;
  const ScheduleEditPage({super.key, this.existing});

  @override
  State<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends State<ScheduleEditPage> {
  late final AgendaController agenda;

  final subjectCtl = TextEditingController();
  final professorCtl = TextEditingController();
  final gradeCtl = TextEditingController();
  final groupCtl = TextEditingController();
  final classroomCtl = TextEditingController();

  TimeOfDay? startTD;
  TimeOfDay? endTD;
  final weekdays = <int>{};

  @override
  void initState() {
    super.initState();
    agenda = Get.find<AgendaController>();
    final ex = widget.existing;
    if (ex != null) {
      subjectCtl.text = ex.subject;
      professorCtl.text = ex.professor ?? '';
      gradeCtl.text = ex.grade ?? '';
      groupCtl.text = ex.group ?? '';
      classroomCtl.text = ex.classroom ?? '';
      final ps = ex.start.split(':');
      startTD = TimeOfDay(
        hour: int.tryParse(ps[0]) ?? 8,
        minute: int.tryParse(ps.length > 1 ? ps[1] : '0') ?? 0,
      );
      final pe = ex.end.split(':');
      endTD = TimeOfDay(
        hour: int.tryParse(pe[0]) ?? 9,
        minute: int.tryParse(pe.length > 1 ? pe[1] : '0') ?? 0,
      );
      weekdays.addAll(ex.weekdays);
    }
  }

  String formatTD(TimeOfDay? t) => t == null ? '--:--' : t.format(context);

  Future<void> pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: startTD ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (t != null) setState(() => startTD = t);
  }

  Future<void> pickEnd() async {
    final t = await showTimePicker(
      context: context,
      initialTime: endTD ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => endTD = t);
  }

  Widget weekdayChip(int day, String label) {
    final selected = weekdays.contains(day);
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF2D2D2D),
        ),
      ),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 255, 152, 0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected
              ? const Color.fromARGB(255, 255, 152, 0)
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
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

  Future<void> save() async {
    final subject = subjectCtl.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese la materia')));
      return;
    }
    if (weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un día')),
      );
      return;
    }
    if (startTD == null || endTD == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione horario inicio/fin')),
      );
      return;
    }
    final startStr =
        '${startTD!.hour.toString().padLeft(2, '0')}:${startTD!.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endTD!.hour.toString().padLeft(2, '0')}:${endTD!.minute.toString().padLeft(2, '0')}';
    if ((startTD!.hour * 60 + startTD!.minute) >=
        (endTD!.hour * 60 + endTD!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario final debe ser posterior al inicio'),
        ),
      );
      return;
    }

    // Validación: evitar empalmes con otros horarios existentes
    int newStartMin = startTD!.hour * 60 + startTD!.minute;
    int newEndMin = endTD!.hour * 60 + endTD!.minute;
    String? conflictMsg;
    for (final existing in agenda.scheduleItems) {
      // si estamos editando, ignorar el propio registro
      if (widget.existing != null && existing.id == widget.existing!.id)
        continue;
      // comprobar si comparten algún día
      final existingDays = existing.weekdays.toSet();
      final intersect = existingDays.intersection(weekdays);
      if (intersect.isEmpty) continue;
      // parsear horas existentes
      try {
        final es = existing.start.split(':');
        final ee = existing.end.split(':');
        final exStart =
            (int.tryParse(es[0]) ?? 0) * 60 +
            (int.tryParse(es.length > 1 ? es[1] : '0') ?? 0);
        final exEnd =
            (int.tryParse(ee[0]) ?? 0) * 60 +
            (int.tryParse(ee.length > 1 ? ee[1] : '0') ?? 0);
        // overlap: start < exEnd && end > exStart  (permitimos tocar en frontera)
        if (newStartMin < exEnd && newEndMin > exStart) {
          conflictMsg =
              'Empalma con "${existing.subject}" (${existing.start} - ${existing.end}) en días seleccionados';
          break;
        }
      } catch (e) {
        // si falla el parseo, saltar esa entrada
        continue;
      }
    }
    if (conflictMsg != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(conflictMsg)));
      return;
    }

    final ex = widget.existing;
    if (ex == null) {
      await agenda.addScheduleItem(
        subject: subject,
        weekdays: weekdays.toList(),
        start: startStr,
        end: endStr,
        grade: gradeCtl.text.trim().isEmpty ? null : gradeCtl.text.trim(),
        group: groupCtl.text.trim().isEmpty ? null : groupCtl.text.trim(),
        classroom: classroomCtl.text.trim().isEmpty
            ? null
            : classroomCtl.text.trim(),
        professor: professorCtl.text.trim().isEmpty
            ? null
            : professorCtl.text.trim(),
      );
    } else {
      final updated = ScheduleItem(
        id: ex.id,
        subject: subject,
        weekdays: weekdays.toList(),
        start: startStr,
        end: endStr,
        grade: gradeCtl.text.trim().isEmpty ? null : gradeCtl.text.trim(),
        group: groupCtl.text.trim().isEmpty ? null : groupCtl.text.trim(),
        classroom: classroomCtl.text.trim().isEmpty
            ? null
            : classroomCtl.text.trim(),
        professor: professorCtl.text.trim().isEmpty
            ? null
            : professorCtl.text.trim(),
      );
      await agenda.updateScheduleItem(updated);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Agregar materia' : 'Editar materia',
        ),
        backgroundColor: const Color.fromARGB(255, 255, 152, 0),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: subjectCtl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Materia',
                prefixIcon: Icon(
                  Icons.menu_book,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: groupCtl,
                    decoration: InputDecoration(
                      labelText: 'Grupo',
                      prefixIcon: Icon(
                        Icons.group,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: gradeCtl,
                    decoration: InputDecoration(
                      labelText: 'Grado',
                      prefixIcon: Icon(
                        Icons.school,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: professorCtl,
              decoration: InputDecoration(
                labelText: 'Profesor',
                prefixIcon: Icon(Icons.person, color: const Color(0xFF2D2D2D)),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: classroomCtl,
              decoration: InputDecoration(
                labelText: 'Aula (opcional)',
                prefixIcon: Icon(
                  Icons.meeting_room,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickStart,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Inicio: ${formatTD(startTD)}',
                      style: const TextStyle(color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickEnd,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Fin: ${formatTD(endTD)}',
                      style: const TextStyle(color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                weekdayChip(1, 'Lun'),
                weekdayChip(2, 'Mar'),
                weekdayChip(3, 'Mié'),
                weekdayChip(4, 'Jue'),
                weekdayChip(5, 'Vie'),
                weekdayChip(6, 'Sáb'),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFF2D2D2D)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 152, 0),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
