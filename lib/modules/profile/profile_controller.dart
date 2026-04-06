import 'package:get/get.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final Rxn<ProfileData> profile = Rxn<ProfileData>();
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // Set sample dulu supaya UI tidak kosong saat loading
    profile.value = ProfileData.sample();
    reloadProfile();
  }

  Future<void> reloadProfile() async {
    // Tunggu currentUser ready (maksimal 3 detik)
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final userData = await _authService.getUserData(user.uid);
      print('DEBUG userData: $userData');
      if (userData != null) {
        final currentProfile = profile.value ?? ProfileData.sample();
        profile.value = currentProfile.copyWith(
          fullName: userData['name'] ?? user.displayName ?? currentProfile.fullName,
          emailAddress: userData['email'] ?? user.email ?? currentProfile.emailAddress,
        );
      } else {
        // Fallback dari Firebase Auth langsung
        final currentProfile = profile.value ?? ProfileData.sample();
        profile.value = currentProfile.copyWith(
          fullName: user.displayName ?? currentProfile.fullName,
          emailAddress: user.email ?? currentProfile.emailAddress,
        );
      }
    } catch (e) {
      // Gagal load → tetap pakai data yang ada, jangan crash
      print('ProfileController: gagal load user data - $e');
    }
  }

  void setProfile(ProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = ProfileData.fromMap(map);
  }
}