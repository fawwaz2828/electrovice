import 'package:get/get.dart';

import '../../models/technician_model.dart';
import '../../services/auth_service.dart';

class TechnicianController extends GetxController {
  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    profile.value = TechnicianProfileData.sample();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null) {
        final currentProfile = profile.value ?? TechnicianProfileData.sample();
        profile.value = currentProfile.copyWith(
          fullName: userData['name'] ?? user.displayName ?? currentProfile.fullName,
        );
      }
    }
  }

  void setProfile(TechnicianProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = TechnicianProfileData.fromMap(map);
  }
}
