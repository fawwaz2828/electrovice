import 'package:get/get.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/auth/signup_page.dart';
import '../modules/home/home_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register'; 
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
      name: signup,
      page: () => const SignupPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
  ];
}
