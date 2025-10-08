class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String userType; // 'guest' or 'student'

  UserModel({required this.id, this.email, this.name, required this.userType});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      name: json['name'],
      userType: json['userType'] ?? 'guest',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'userType': userType};
  }

  bool get isGuest => userType == 'guest';
  bool get isStudent => userType == 'student';
}
