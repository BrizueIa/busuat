class ScheduleItem {
  final String id;

  /// Materia / nombre principal
  final String subject;

  /// Lista de días (1 = Monday .. 7 = Sunday)
  final List<int> weekdays;

  /// HH:mm
  final String start;

  /// HH:mm
  final String end;

  final String? location;
  final String? grade;
  final String? group;
  final String? classroom;
  final String? professor;

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.weekdays,
    required this.start,
    required this.end,
    this.location,
    this.grade,
    this.group,
    this.classroom,
    this.professor,
  });

  factory ScheduleItem.fromMap(Map m) {
    final raw = m['weekdays'];
    List<int> wk = [];
    if (raw is List) {
      wk = raw.map((e) => (e as num).toInt()).toList();
    } else if (raw is String) {
      // legacy single weekday stored as number string
      final v = int.tryParse(raw) ?? 0;
      if (v > 0) wk = [v];
    } else if (m.containsKey('weekday')) {
      // older format used a single 'weekday' int
      final v = (m['weekday'] is num)
          ? (m['weekday'] as num).toInt()
          : (int.tryParse(m['weekday']?.toString() ?? '') ?? 0);
      if (v > 0) wk = [v];
    }

    // subject prefers explicit 'subject', fallback to legacy 'title'
    final subj = (m['subject'] as String?) ?? (m['title'] as String?);
    return ScheduleItem(
      id: m['id'] as String,
      subject: subj ?? '',
      weekdays: wk,
      start: m['start'] as String,
      end: m['end'] as String,
      location: m['location'] as String?,
      grade: m['grade'] as String?,
      group: m['group'] as String?,
      classroom: m['classroom'] as String?,
      professor: m['professor'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'weekdays': weekdays,
    'start': start,
    'end': end,
    'location': location,
    'grade': grade,
    'group': group,
    'classroom': classroom,
    'professor': professor,
  };

  /// Helper: returns minutes since midnight for a HH:mm string
  static int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 60 + m;
  }

  /// Check if a specific DateTime falls inside this slot (weekday + time range)
  bool contains(DateTime dt) {
    if (!weekdays.contains(dt.weekday)) return false;
    final nowMin = dt.hour * 60 + dt.minute;
    final s = _minutes(start);
    final e = _minutes(end);
    return nowMin >= s && nowMin < e;
  }
}
