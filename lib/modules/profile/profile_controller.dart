import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final Rxn<ProfileData> profile = Rxn<ProfileData>();
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    reloadProfile();
  }

  Future<void> reloadProfile() async {
    // Tunggu hingga Firebase Auth siap (max 3 detik)
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final userModel = await _authService.getUserModel(user.uid);
      if (userModel == null) return;

      profile.value = ProfileData(
        fullName: userModel.name,
        emailAddress: userModel.email,
        mobileNumber: userModel.phone ?? '',
        isMobileVerified: false,
        avatarUrl: userModel.photoUrl,
        // primaryNodes & securityOptions bukan data Firestore — statis
        primaryNodes: const [],
        securityOptions: const [
          SecurityOption(key: 'change_access_key', title: 'Change Password'),
          SecurityOption(key: 'privacy_management', title: 'Privacy Management'),
        ],
      );
    } catch (e) {
      debugPrint('ProfileController: gagal load - $e');
    }
  }
}
