import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../services/technician_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = AuthService();
  final TechnicianService _technicianService = TechnicianService();

  final RxString userName = ''.obs;
  final RxList<TechnicianOnlineModel> nearbyTechnicians =
      <TechnicianOnlineModel>[].obs;
  final RxBool isLoadingTechnicians = true.obs;
  final RxString locationError = ''.obs;
  /// Total teknisi available di area (sebelum dibatasi 3)
  final RxInt technicianCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    loadNearbyTechnicians();
  }

  Future<void> _loadUserName() async {
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }
    final user = _authService.currentUser;
    if (user == null) return;

    final userModel = await _authService.getUserModel(user.uid);
    if (userModel != null) {
      userName.value = userModel.name.split(' ').first;
    }
  }

  Future<void> loadNearbyTechnicians() async {
    isLoadingTechnicians.value = true;
    locationError.value = '';

    try {
      final position = await _technicianService.getCurrentLocation();

      if (position == null) {
        locationError.value = 'Location permission required';
        isLoadingTechnicians.value = false;
        return;
      }

      final technicians = await _technicianService.getTechnicianList(
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: 10,
      );

      final available = technicians.where((t) => t.isAvailable).toList();
      // Simpan total count sebelum dibatasi 3
      technicianCount.value = available.length;
      // Ambil max 3 teknisi terdekat yang available untuk home page
      nearbyTechnicians.assignAll(available.take(3).toList());
    } catch (e) {
      debugPrint('HomeController: gagal load teknisi - $e');
      locationError.value = 'Failed to load data';
    } finally {
      isLoadingTechnicians.value = false;
    }
  }
}
