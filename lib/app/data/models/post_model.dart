class PostModel {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String? imgLink;
  final List<String> categories;

  PostModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.price = 0.0,
    this.imgLink,
    this.categories = const [],
  });

  // Convertir desde JSON de Supabase
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imgLink: json['img_link'] as String?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : [],
    );
  }

  // Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'img_link': imgLink,
      'categories': categories,
    };
  }

  // Método copyWith para crear copias con cambios
  PostModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    double? price,
    String? imgLink,
    List<String>? categories,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imgLink: imgLink ?? this.imgLink,
      categories: categories ?? this.categories,
    );
  }
}
