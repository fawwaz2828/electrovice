import 'package:get/get.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/profile/profile_page.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/auth/signup_page.dart';
import '../modules/home/home_page.dart';
import '../modules/home/home_controller.dart';
import '../modules/booking/booking_controller.dart';
import '../modules/booking/booking_form_page.dart';
import '../modules/booking/booking_history_page.dart';
import '../modules/booking/booking_technician_detail_page.dart';
import '../modules/booking/booking_tracking_page.dart';
import '../modules/booking/checkout_page.dart';
import '../modules/technician/technician_controller.dart';
import '../modules/technician/technician_profile_page.dart';
import '../modules/technician/technician_profile_edit_page.dart';
import '../modules/technician/technician_home_page.dart';
import '../modules/technician/job_detail_page.dart';
import '../modules/technician/verification_page.dart';
import '../modules/technician/active_job_page.dart';
import '../modules/technician/technician_list_page.dart';
import '../modules/technician/job_summary_page.dart';
import '../modules/technician/mapbox_location_picker_page.dart';
import '../modules/profile/profile_edit_page.dart';
import '../modules/chat/chat_page.dart';
import '../modules/chat/chat_controller.dart';
import '../modules/booking/review_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profilePage = '/profile';
  static const String technicianProfile = '/technician/profile';
  static const String technicianHome = '/technician/home';
  static const String jobDetail = '/technician/job-detail';
  static const String activeJob = '/technician/active-job';
  static const String verification = '/technician/verification';
  static const String technicianDetail = '/customer/technician-detail';
  static const String createOrder = '/customer/create-order';
  static const String checkout = '/customer/checkout';
  static const String orderTracking = '/customer/order-tracking';
  static const String orderHistory = '/customer/order-history';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String technicianList = '/customer/technician-list';
  static const String jobSummary = '/technician/job-summary';
  static const technicianProfileEdit = '/technician/profile/edit';
  static const profileEdit = '/profile/edit';
  static const mapboxLocationPicker = '/mapbox-location-picker';
  static const chat = '/chat';
  static const review = '/review';

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

    // ── Customer ────────────────────────────────────────────────
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      }),
    ),
    GetPage(
      name: profilePage,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
      }),
    ),
    // Titik awal booking flow — selalu buat controller baru agar args terbaca
    GetPage(
      name: technicianDetail,
      page: () => const BookingTechnicianDetailPage(),
      binding: BindingsBuilder(() {
        Get.delete<BookingController>(force: true);
        Get.put(BookingController());
      }),
    ),
    // Halaman berikutnya dalam flow — reuse controller yang sama
    GetPage(
      name: createOrder,
      page: () => const BookingFormPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingController>()) Get.put(BookingController());
      }),
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingController>()) Get.put(BookingController());
      }),
    ),
    GetPage(
      name: orderTracking,
      page: () => const BookingTrackingPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingController>()) Get.put(BookingController());
      }),
    ),
    GetPage(
      name: orderHistory,
      page: () => const BookingHistoryPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingController>()) Get.put(BookingController());
      }),
    ),
    GetPage(
      name: technicianList,
      page: () => const TechnicianListPage(),
    ),
    GetPage(
      name: profileEdit,
      page: () => const ProfileEditPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
      }),
    ),

    // ── Technician ───────────────────────────────────────────────
    GetPage(
      name: technicianHome,
      page: () => const TechnicianHomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: technicianProfile,
      page: () => const TechnicianProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: technicianProfileEdit,
      page: () => const TechnicianProfileEditPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: jobDetail,
      page: () => const JobDetailPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: verification,
      page: () => const VerificationPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: activeJob,
      page: () => const ActiveJobPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.mapboxLocationPicker,
      page: () => const MapboxLocationPickerPage(),
    ),
    GetPage(
      name: chat,
      page: () => const ChatPage(),
    ),
    GetPage(
      name: jobSummary,
      page: () => const JobSummaryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TechnicianController>(() => TechnicianController(), fenix: true);
      }),
    ),
    GetPage(
      name: review,
      page: () => const ReviewPage(),
    ),
    GetPage(
      name: chat,
      page: () => const ChatPage(),
      binding: BindingsBuilder(() {
        Get.delete<ChatController>(force: true);
        Get.put(ChatController());
      }),
    ),
  ];
}