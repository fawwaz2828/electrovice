import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

Future<void> login(String email, String password) async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    final credential = await _authService.loginWithEmail(
      email: email,
      password: password,
    );
    
    // Kalau Firestore kosong, default ke customer
    final role = await _authService.getUserRole(credential.user!.uid) ?? 'customer';
    Get.offAllNamed(AppRoutes.home, arguments: {'role': role});
    
  } catch (e) {
    errorMessage.value = _parseError(e.toString());
  } finally {
    isLoading.value = false;
  }
}

Future<void> register(String email, String password, String name, String role) async {
  isLoading.value = true;
  errorMessage.value = '';
  try {
    await _authService.registerWithEmail(
      email: email,
      password: password,
      name: name,
      role: role,
    );
    Get.offAllNamed(AppRoutes.home, arguments: {'role': role});
  } catch (e) {
    errorMessage.value = _parseError(e.toString());
  } finally {
    isLoading.value = false;
  }
}

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.register);
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'Email tidak terdaftar';
    if (error.contains('wrong-password')) return 'Password salah';
    if (error.contains('invalid-credential')) return 'Email atau password salah';
    if (error.contains('email-already-in-use')) return 'Email sudah digunakan';
    if (error.contains('weak-password')) return 'Password minimal 6 karakter';
    if (error.contains('invalid-email')) return 'Format email tidak valid';
    return error; // Return the actual error to see what's failing
  }
}