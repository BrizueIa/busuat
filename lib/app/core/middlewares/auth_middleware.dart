import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthRepository _authRepository = AuthRepository();

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Si el usuario está intentando acceder a login y ya tiene sesión, redirigir
    if (_authRepository.hasActiveSession() && route == '/login') {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        if (user.isGuest) {
          return const RouteSettings(name: '/guest');
        } else if (user.isStudent) {
          return const RouteSettings(name: '/home');
        }
      }
    }
    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  final AuthRepository _authRepository = AuthRepository();

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!_authRepository.hasActiveSession()) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class StudentMiddleware extends GetMiddleware {
  final AuthRepository _authRepository = AuthRepository();

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!_authRepository.hasActiveSession()) {
      return const RouteSettings(name: '/login');
    }

    final user = _authRepository.getCurrentUser();
    if (user != null && user.isGuest) {
      // Si es invitado intentando acceder a rutas de estudiante, redirigir
      return const RouteSettings(name: '/guest');
    }

    return null;
  }
}
