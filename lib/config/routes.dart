import 'package:get/get.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
<<<<<<< HEAD
import '../modules/profile/profile_page.dart';
=======
import '../modules/auth/signup_page.dart';
import '../modules/home/home_page.dart';
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register'; 
<<<<<<< HEAD
  static const String profile_page = '/profile'; // Add this line for the profile page route
=======
  static const String signup = '/signup';
  static const String home = '/home';
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24

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
<<<<<<< HEAD
      name: profile_page,
      page: () => const ProfilePage(),
=======
      name: signup,
      page: () => const SignupPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
>>>>>>> d29feedf15af469c170d0ebc6887c63bdc2c6d24
    ),
  ];
}
