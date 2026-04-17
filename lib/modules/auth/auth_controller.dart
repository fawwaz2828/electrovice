import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';
import '../profile/profile_controller.dart';

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
      await _navigateToHome(role);
    } catch (e) {
      errorMessage.value = _parseError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Register email/password
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

      await Future.delayed(const Duration(seconds: 1));

      // Teknisi baru langsung ke onboarding
      if (role == 'technician') {
        Get.offAllNamed(AppRoutes.technicianOnboarding);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
      Get.snackbar(
        'Berhasil!',
        role == 'technician'
            ? 'Akun dibuat! Lengkapi profil teknisimu.'
            : 'Akun berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      final userRole = await _authService.getUserRole(user.uid) ?? role;

      await _navigateToHome(userRole);

      if (isNewUser) {
        Get.snackbar(
          'Akun Dibuat!',
          'Pendaftaran Google berhasil.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = _parseError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _navigateToHome(String role) async {
    if (role == 'admin') {
      Get.offAllNamed(AppRoutes.adminHome);
    } else if (role == 'technician') {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        final data = await _authService.getUserData(uid);
        final techProfile = data?['technicianProfile'] as Map?;

        // Belum onboarding
        if (techProfile == null) {
          Get.offAllNamed(AppRoutes.technicianOnboarding);
          return;
        }

        final status = techProfile['verificationStatus'] as String? ?? 'pending';

        switch (status) {
          case 'verified':
            Get.offAllNamed(AppRoutes.technicianHome);
          case 'declined':
            Get.offAllNamed(AppRoutes.verificationDeclined);
          default: // pending
            Get.offAllNamed(AppRoutes.verificationPending);
        }
      }
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    // Hapus ProfileController saat logout
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>();
    }
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