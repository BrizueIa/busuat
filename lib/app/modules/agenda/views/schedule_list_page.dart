// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busuat/app/modules/agenda/agenda_controller.dart';
import 'package:busuat/app/modules/agenda/views/schedule_edit_page.dart';
import 'package:busuat/app/modules/agenda/widgets/confirm_dialog.dart';

class ScheduleListPage extends GetView<AgendaController> {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgendaController>()) Get.put(AgendaController());

    const orange = Color.fromARGB(255, 255, 152, 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de materias'),
        backgroundColor: orange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            tooltip: 'Vista previa',
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.grid_view),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.scheduleItems.toList();
        if (items.isEmpty) {
          return const Center(child: Text('No hay materias en el horario'));
        }

        // Ordenar por día (primer día de weekdays) y luego por hora
        items.sort((a, b) {
          // Obtener el primer día de cada materia
          final firstDayA = a.weekdays.isEmpty
              ? 7
              : a.weekdays.reduce((curr, next) => curr < next ? curr : next);
          final firstDayB = b.weekdays.isEmpty
              ? 7
              : b.weekdays.reduce((curr, next) => curr < next ? curr : next);

          // Primero comparar por día
          final dayCompare = firstDayA.compareTo(firstDayB);
          if (dayCompare != 0) return dayCompare;

          // Si es el mismo día, comparar por hora de inicio
          final partsA = a.start.split(':');
          final partsB = b.start.split(':');

          final hourA = int.tryParse(partsA[0]) ?? 0;
          final hourB = int.tryParse(partsB[0]) ?? 0;
          final minuteA = partsA.length > 1
              ? (int.tryParse(partsA[1]) ?? 0)
              : 0;
          final minuteB = partsB.length > 1
              ? (int.tryParse(partsB[1]) ?? 0)
              : 0;

          final totalMinutesA = hourA * 60 + minuteA;
          final totalMinutesB = hourB * 60 + minuteB;

          return totalMinutesA.compareTo(totalMinutesB);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final s = items[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async =>
                    await Get.to(() => ScheduleEditPage(existing: s)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 56,
                        decoration: BoxDecoration(
                          color: orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.subject,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${s.grade ?? ''} ${s.group ?? ''} · ${s.start} - ${s.end}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _weekdayLabels(s.weekdays),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Keep only delete action (no edit pencil)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            context,
                            title: 'Eliminar',
                            content: '¿Eliminar materia?',
                          );
                          if (ok == true) {
                            final deleted = s;
                            await controller.removeScheduleItem(s);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Materia eliminada'),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  onPressed: () {
                                    controller.addScheduleItem(
                                      subject: deleted.subject,
                                      weekdays: deleted.weekdays,
                                      start: deleted.start,
                                      end: deleted.end,
                                      grade: deleted.grade,
                                      group: deleted.group,
                                      classroom: deleted.classroom,
                                      professor: deleted.professor,
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schedule_list_fab',
        backgroundColor: orange,
        child: const Icon(Icons.add),
        onPressed: () async => await Get.to(() => const ScheduleEditPage()),
      ),
    );
  }

  String _weekdayLabels(List<int> days) {
    final map = {1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue', 5: 'Vie', 6: 'Sáb'};
    final labels = days.map((d) => map[d] ?? '').where((s) => s.isNotEmpty);
    return labels.join(', ');
  }
}
