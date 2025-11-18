class AgendaItem {
  final int? id; // Cambiado a int? para Supabase (bigint GENERATED)
  final String title;
  final String description;
  final bool done;
  final bool pinned;
  final DateTime? when;
  final List<String>? category; // Cambiado a List<String>? para ARRAY
  final String? userId; // Agregado para vincular con auth.users

  AgendaItem({
    this.id,
    required this.title,
    this.description = '',
    this.done = false,
    this.pinned = false,
    this.when,
    this.category,
    this.userId,
  });

  factory AgendaItem.fromMap(Map<String, dynamic> m) {
    // Manejar category tanto como String (legacy) o List
    List<String>? categoryList;
    final categoryData = m['category'];
    if (categoryData != null) {
      if (categoryData is List) {
        categoryList = categoryData.map((e) => e.toString()).toList();
      } else if (categoryData is String && categoryData.isNotEmpty) {
        // Retrocompatibilidad: convertir string único a lista
        categoryList = [categoryData];
      }
    }

    return AgendaItem(
      id: m['id'] != null ? (m['id'] is int ? m['id'] : int.tryParse(m['id'].toString())) : null,
      title: m['title'] as String,
      description: (m['description'] as String?) ?? '',
      done: (m['done'] as bool?) ?? false,
      pinned: (m['pinned'] as bool?) ?? false,
      when: m['when'] == null ? null : DateTime.parse(m['when'] as String),
      category: categoryList,
      userId: m['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'done': done,
    'pinned': pinned,
    'when': when?.toIso8601String(),
    'category': category,
    if (userId != null) 'user_id': userId,
  };

  // Para Supabase inserts (sin id, se genera automáticamente)
  Map<String, dynamic> toInsertMap() => {
    'title': title,
    'description': description,
    'done': done,
    'pinned': pinned,
    'when': when?.toIso8601String(),
    'category': category,
    // user_id no se incluye aquí, se maneja mediante RLS
  };

  AgendaItem copyWith({
    int? id,
    String? title,
    String? description,
    bool? done,
    bool? pinned,
    DateTime? when,
    bool whenIsProvided = false,
    List<String>? category,
    bool categoryIsProvided = false,
    String? userId,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      pinned: pinned ?? this.pinned,
      when: whenIsProvided ? when : this.when,
      category: categoryIsProvided ? category : this.category,
      userId: userId ?? this.userId,
    );
  }
}
