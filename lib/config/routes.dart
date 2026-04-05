import 'package:get/get.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/profile/profile_page.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/auth/signup_page.dart';
import '../modules/home/home_page.dart';
import '../modules/technician/technician_controller.dart';
import '../modules/technician/technician_profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile_page = '/profile';
  static const String technicianProfile = '/technician/profile';
  static const String signup = '/signup';
  static const String home = '/home';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: profile_page,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: technicianProfile,
      page: () => const TechnicianProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController());
      }),
    ),
    GetPage(
      name: signup,
      page: () => const SignupPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
  ];
}
