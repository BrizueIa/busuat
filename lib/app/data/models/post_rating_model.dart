class PostRatingModel {
  final int? id;
  final int postId;
  final int rating;
  final String? body;
  final DateTime createdAt;

  PostRatingModel({
    this.id,
    required this.postId,
    required this.rating,
    this.body,
    required this.createdAt,
  });

  factory PostRatingModel.fromJson(Map<String, dynamic> json) {
    return PostRatingModel(
      id: json['id'] as int?,
      postId: json['post_id'] as int,
      rating: json['rating'] as int,
      body: json['body'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'post_id': postId,
      'rating': rating,
      if (body != null) 'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
