import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final GetStorage _storage = GetStorage();
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';

  // Guardar usuario actual
  Future<void> saveCurrentUser(UserModel user) async {
    await _storage.write(_userKey, user.toJson());
  }

  // Obtener usuario actual
  UserModel? getCurrentUser() {
    final userData = _storage.read(_userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Registrar nuevo estudiante (almacenamiento local)
  Future<bool> registerStudent(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      // Obtener lista de usuarios registrados
      List users = _storage.read(_usersKey) ?? [];

      // Verificar si el email ya existe
      bool emailExists = users.any((user) => user['email'] == email);
      if (emailExists) {
        return false;
      }

      // Crear nuevo usuario
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'password': password,
        'name': name,
        'userType': 'student',
      };

      users.add(newUser);
      await _storage.write(_usersKey, users);

      // Guardar como usuario actual
      final userModel = UserModel(
        id: newUser['id'] as String,
        email: email,
        name: name,
        userType: 'student',
      );
      await saveCurrentUser(userModel);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Login de estudiante
  Future<bool> loginStudent(String email, String password) async {
    try {
      List users = _storage.read(_usersKey) ?? [];

      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        final userModel = UserModel(
          id: user['id'] as String,
          email: email,
          name: user['name'],
          userType: 'student',
        );
        await saveCurrentUser(userModel);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login como invitado
  Future<void> loginAsGuest() async {
    final guestUser = UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      userType: 'guest',
    );
    await saveCurrentUser(guestUser);
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _storage.remove(_userKey);
  }

  // Verificar si hay sesión activa
  bool hasActiveSession() {
    return _storage.hasData(_userKey);
  }
}
