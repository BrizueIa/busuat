class UserModel {
  final String id;
  final String? email;
  final String userType; // 'guest' or 'student'

  UserModel({required this.id, this.email, required this.userType});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      userType: json['userType'] ?? 'guest',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'userType': userType};
  }

  bool get isGuest => userType == 'guest';
  bool get isStudent => userType == 'student';
}
