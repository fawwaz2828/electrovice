import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Login email/password
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      final role = await _authService.getUserRole(user!.uid) ?? 'customer';
      Get.offAllNamed(AppRoutes.home, arguments: {'role': role});
    } catch (e) {
      errorMessage.value = _parseError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Register email/password — setelah register balik ke login
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
      Get.offAllNamed(AppRoutes.login, arguments: {'role': role == 'technician' ? 'technician' : 'customer'});
      Get.snackbar('Berhasil!', 'Akun berhasil dibuat. Silakan login.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = _parseError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign-In
  Future<void> loginWithGoogle({String role = 'customer'}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _authService.signInWithGoogle(role: role);
      if (result == null) {
        isLoading.value = false;
        return;
      }

      final user = result['user'];
      final isNewUser = result['isNew'] as bool;
      
      if (isNewUser) {
        // User baru → logout dulu, arahkan ke login
        await _authService.logout();
        Get.offAllNamed(AppRoutes.login, arguments: {'role': role});
        Get.snackbar(
          'Akun Dibuat!', 
          'Silakan login kembali dengan akun Google kamu.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // User lama → langsung ke home
        final userRole = await _authService.getUserRole(user.uid) ?? role;
        Get.offAllNamed(AppRoutes.home, arguments: {'role': userRole});
      }
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
    if (error.contains('network')) return 'Periksa koneksi internet';
    return 'Terjadi kesalahan, coba lagi';
  }
}