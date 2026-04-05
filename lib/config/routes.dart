import 'package:get/get.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/profile/profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register'; 
  static const String profile_page = '/profile'; // Add this line for the profile page route

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
    ),
  ];
}
