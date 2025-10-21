import 'package:get/get.dart';
import '../core/middlewares/auth_middleware.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_page.dart';
import '../modules/auth_options/auth_options_binding.dart';
import '../modules/auth_options/auth_options_page.dart';
import '../modules/student_login/student_login_binding.dart';
import '../modules/student_login/student_login_page.dart';
import '../modules/register/register_binding.dart';
import '../modules/register/register_page.dart';
import '../modules/guest/guest_binding.dart';
import '../modules/guest/guest_page.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';
import '../modules/map/map_binding.dart';
import '../modules/map/map_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.AUTH_OPTIONS,
      page: () => const AuthOptionsPage(),
      binding: AuthOptionsBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_LOGIN,
      page: () => const StudentLoginPage(),
      binding: StudentLoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.GUEST,
      page: () => const GuestPage(),
      binding: GuestBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [StudentMiddleware()],
    ),
    GetPage(
      name: Routes.MAP,
      page: () => const MapPage(),
      binding: MapBinding(),
    ),
  ];
}
