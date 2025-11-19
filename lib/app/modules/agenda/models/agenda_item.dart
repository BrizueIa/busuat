class AgendaItem {
  final int? id; // bigint from database, nullable for new items
  final String? userId; // Required for database operations
  final String title;
  final String description;
  final bool done;
  final bool pinned;
  final DateTime? when;
  final List<String>? category; // Changed to List to match database ARRAY type

  AgendaItem({
    this.id,
    this.userId,
    required this.title,
    this.description = '',
    this.done = false,
    this.pinned = false,
    required this.when,
    this.category,
  });

  factory AgendaItem.fromMap(Map<String, dynamic> m) => AgendaItem(
    id: m['id'] is int
        ? m['id']
        : (m['id'] is String ? int.tryParse(m['id']) : null),
    userId: m['user_id'] as String?,
    title: m['title'] as String,
    description: (m['description'] as String?) ?? '',
    done: (m['done'] as bool?) ?? false,
    pinned: (m['pinned'] as bool?) ?? false,
    when: m['when'] == null ? null : DateTime.parse(m['when'] as String),
    category: m['category'] is List
        ? (m['category'] as List).map((e) => e.toString()).toList()
        : (m['category'] is String && (m['category'] as String).isNotEmpty)
        ? [m['category'] as String]
        : null,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    if (userId != null) 'user_id': userId,
    'title': title,
    'description': description,
    'done': done,
    'pinned': pinned,
    'when': when?.toIso8601String(),
    'category': category,
  };

  // For database insert (without id)
  Map<String, dynamic> toInsertMap() => {
    'user_id': userId,
    'title': title,
    'description': description,
    'done': done,
    'pinned': pinned,
    'when': when?.toIso8601String(),
    'category': category,
  };

  AgendaItem copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    bool? done,
    bool? pinned,
    DateTime? when,
    bool whenIsProvided = false,
    List<String>? category,
    bool categoryIsProvided = false,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      pinned: pinned ?? this.pinned,
      when: whenIsProvided ? when : this.when,
      category: categoryIsProvided ? category : this.category,
    );
  }
}
