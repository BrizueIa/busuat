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
import '../modules/agenda/agenda_binding.dart';
import '../modules/agenda/agenda_page.dart';
import '../modules/marketplace/marketplace_binding.dart';
import '../modules/marketplace/create_post_page.dart';
import '../modules/marketplace/edit_post_page.dart';
import '../modules/marketplace/my_posts_page.dart';
import '../modules/marketplace/views/seller_verification_view.dart';
import '../modules/marketplace/views/post_detail_view.dart';
import '../modules/profile/manage_phones_view.dart';

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
    GetPage(
      name: Routes.AGENDA,
      page: () => const AgendaPage(),
      binding: AgendaBinding(),
    ),
    GetPage(
      name: Routes.CREATE_POST,
      page: () => const CreatePostPage(),
      binding: MarketplaceBinding(),
    ),
    GetPage(
      name: Routes.EDIT_POST,
      page: () => const EditPostPage(),
      binding: MarketplaceBinding(),
    ),
    GetPage(
      name: Routes.MY_POSTS,
      page: () => const MyPostsPage(),
      binding: MarketplaceBinding(),
    ),
    GetPage(
      name: Routes.SELLER_VERIFICATION,
      page: () => const SellerVerificationView(),
      binding: MarketplaceBinding(),
    ),
    GetPage(name: Routes.MANAGE_PHONES, page: () => const ManagePhonesView()),
    GetPage(name: Routes.POST_DETAIL, page: () => const PostDetailView()),
  ];
}
