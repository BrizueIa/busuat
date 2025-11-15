import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busuat/app/modules/agenda/agenda_controller.dart';
import 'package:busuat/app/modules/agenda/models/schedule_item.dart';
import 'package:busuat/app/modules/agenda/widgets/confirm_dialog.dart';

class SchedulePreviewPage extends GetView<AgendaController> {
  const SchedulePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgendaController>()) Get.put(AgendaController());
    const orange = Color.fromARGB(255, 255, 152, 0);
    // The table depends on reactive scheduleItems; rebuild when they change

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa'),
        backgroundColor: orange,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Obx(() {
        final items = controller.scheduleItems;

        // collect unique start times
        final starts = <String>{};
        for (final s in items) starts.add(s.start);
        final rows = starts.toList()..sort();

        final now = DateTime.now();
        final todayWeekday = now.weekday; // 1..7
        int? highlightedRowIndex;
        int highlightedCol = -1;

        for (var r = 0; r < rows.length; r++) {
          for (var c = 1; c <= 6; c++) {
            final found = _findItemFor(items, rows[r], c);
            if (found != null && c == todayWeekday) {
              final startMin = _parseMinutes(found.start);
              final endMin = _parseMinutes(found.end);
              final nowMin = now.hour * 60 + now.minute;
              if (nowMin >= startMin && nowMin < endMin) {
                highlightedRowIndex = r;
                highlightedCol = c - 1;
              }
            }
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: rows.isEmpty
                ? const Center(
                    child: Text('No hay materias para previsualizar'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // entire table wrapped in a single horizontal scroll view
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Hora | Lunes..Sábado | Profesor
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Hora header aligns with hour column (no horizontal margin)
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        'Hora',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Días: usar Container con el mismo margin/width que las celdas
                                  ...List.generate(6, (i) {
                                    return Container(
                                      width: 160,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _weekdayName(i + 1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),

                                  // Profesor header, con el mismo margin que las celdas
                                  Container(
                                    width: 160,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Profesor',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(rows.length, (r) {
                                final anyItem = _findAnyItemForStart(
                                  items,
                                  rows[r],
                                );
                                final profesorVal = anyItem?.professor ?? '';

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Hora
                                    SizedBox(
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          // Mostrar inicio - fin si está disponible
                                          '${rows[r]}${(anyItem?.end ?? '').isNotEmpty ? ' - ${anyItem!.end}' : ''}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Celdas de días: mostrar materia y debajo grupo + aula
                                    ...List.generate(6, (c) {
                                      final weekday = c + 1;
                                      final cellItem = _findItemFor(
                                        items,
                                        rows[r],
                                        weekday,
                                      );
                                      final isHighlighted =
                                          highlightedRowIndex == r &&
                                          highlightedCol == c;
                                      if (cellItem == null) {
                                        return Container(
                                          width: 160,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(
                                            minHeight: 64,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isHighlighted
                                                ? orange.withOpacity(0.12)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isHighlighted
                                                  ? orange
                                                  : Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        );
                                      }

                                      final groupText =
                                          '${cellItem.grade ?? ''}${(cellItem.group ?? '').isNotEmpty ? ' ${cellItem.group}' : ''}';
                                      final aulaText = cellItem.classroom ?? '';

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onLongPress: () async {
                                          final ok = await showConfirmDialog(
                                            context,
                                            title: 'Eliminar',
                                            content:
                                                '¿Eliminar "${cellItem.subject}"?',
                                          );
                                          if (ok == true) {
                                            final deleted = cellItem;
                                            await controller.removeScheduleItem(
                                              cellItem,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Materia eliminada',
                                                ),
                                                action: SnackBarAction(
                                                  label: 'Deshacer',
                                                  onPressed: () {
                                                    controller.addScheduleItem(
                                                      subject: deleted.subject,
                                                      weekdays:
                                                          deleted.weekdays,
                                                      start: deleted.start,
                                                      end: deleted.end,
                                                      grade: deleted.grade,
                                                      group: deleted.group,
                                                      classroom:
                                                          deleted.classroom,
                                                      professor:
                                                          deleted.professor,
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 160,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(
                                            minHeight: 64,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isHighlighted
                                                ? orange.withOpacity(0.12)
                                                : Colors.white,
                                            border: Border.all(
                                              color: isHighlighted
                                                  ? orange
                                                  : Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                cellItem.subject,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                [groupText, aulaText]
                                                    .where((s) => s.isNotEmpty)
                                                    .join(' • '),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    // Profesor (representativo del horario) — mostrar en caja blanca redondeada
                                    Container(
                                      width: 160,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.02,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          profesorVal,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
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
                        // extra bottom padding to avoid system overlays or debug stripe
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
          ),
        );
      }),
    );
  }

  String _weekdayName(int d) {
    switch (d) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      default:
        return '';
    }
  }

  int _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 60 + m;
  }

  ScheduleItem? _findItemFor(
    List<ScheduleItem> items,
    String start,
    int weekday,
  ) {
    for (final it in items) {
      if (it.start == start && it.weekdays.contains(weekday)) return it;
    }
    return null;
  }

  // Find any schedule item that has the given start time (for any weekday)
  ScheduleItem? _findAnyItemForStart(List<ScheduleItem> items, String start) {
    for (final it in items) {
      if (it.start == start) return it;
    }
    return null;
  }
}
