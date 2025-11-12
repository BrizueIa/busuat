class PostModel {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String? imgLink;
  final List<String> categories;
  final String? phoneNumber;
  final String? faculty;
  final double averageRating;
  final int ratingsCount;

  PostModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.price = 0.0,
    this.imgLink,
    this.categories = const [],
    this.phoneNumber,
    this.faculty,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
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
      phoneNumber: json['phone_number'] as String?,
      faculty: json['faculty'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratings_count'] as int? ?? 0,
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
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (faculty != null) 'faculty': faculty,
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
    String? phoneNumber,
    String? faculty,
    double? averageRating,
    int? ratingsCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imgLink: imgLink ?? this.imgLink,
      categories: categories ?? this.categories,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faculty: faculty ?? this.faculty,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
    );
  }
}
