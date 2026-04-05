import 'package:get/get.dart';

import '../../models/technician_model.dart';

class TechnicianController extends GetxController {
  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();

  @override
  void onInit() {
    super.onInit();
    profile.value = TechnicianProfileData.sample();
  }

  void setProfile(TechnicianProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = TechnicianProfileData.fromMap(map);
  }
}
