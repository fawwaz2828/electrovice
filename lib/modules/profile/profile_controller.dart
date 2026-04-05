import 'package:get/get.dart';

import '../../models/profile_model.dart';

class ProfileController extends GetxController {
  final Rxn<ProfileData> profile = Rxn<ProfileData>();

  @override
  void onInit() {
    super.onInit();
    profile.value = ProfileData.sample();
  }

  void setProfile(ProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = ProfileData.fromMap(map);
  }
}
