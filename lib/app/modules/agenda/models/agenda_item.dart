class AgendaItem {
  final String id;
  final String title;
  final String description;
  final bool done;
  final bool pinned;
  final DateTime? when;
  final String? category;

  AgendaItem({
    required this.id,
    required this.title,
    this.description = '',
    this.done = false,
    this.pinned = false,
    required this.when,
    this.category,
  });

  factory AgendaItem.fromMap(Map<String, dynamic> m) => AgendaItem(
    id: m['id'] as String,
    title: m['title'] as String,
    description: (m['description'] as String?) ?? '',
    done: (m['done'] as bool?) ?? false,
    pinned: (m['pinned'] as bool?) ?? false,
    when: m['when'] == null ? null : DateTime.parse(m['when'] as String),
    category: (m['category'] as String?) ?? null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'done': done,
    'pinned': pinned,
    'when': when == null ? null : when!.toIso8601String(),
    'category': category,
  };

  AgendaItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? done,
    bool? pinned,
    DateTime? when,
    bool whenIsProvided = false,
    String? category,
    bool categoryIsProvided = false,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      pinned: pinned ?? this.pinned,
      when: whenIsProvided ? when : this.when,
      category: categoryIsProvided ? category : this.category,
    );
  }
}
