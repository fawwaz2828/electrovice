import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../models/profile_model.dart';
import '../../models/user_model.dart';
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

      // Update seluruh profile sekaligus — tidak ada .sample() sama sekali
      final current = profile.value ?? ProfileData.sample();
      profile.value = current.copyWith(
        fullName: userModel.name,
        emailAddress: userModel.email,
        // phone bisa ditambah nanti kalau ProfileData sudah ada field-nya
      );
    } catch (e) {
      debugPrint('ProfileController: gagal load - $e');
    }
  }

  void setProfile(ProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = ProfileData.fromMap(map);
  }
}