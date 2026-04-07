import 'package:get/get.dart';

import '../../models/technician_model.dart';
import '../../services/auth_service.dart';

class TechnicianController extends GetxController {
  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final AuthService _authService = AuthService();

  // New Service Flow State
  final RxBool isOnline = true.obs;
  final Rxn<TechnicianJobRecord> currentJob = Rxn<TechnicianJobRecord>();
  final RxList<TechnicianJobRecord> incomingRequests = <TechnicianJobRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    profile.value = TechnicianProfileData.sample();
    _loadUserData();
    _loadMockRequests();
  }

  void _loadMockRequests() {
    incomingRequests.assignAll([
      const TechnicianJobRecord(
        title: 'MacBook Pro Screen Replacement',
        clientName: 'Sarah Jenkins',
        amount: 180.0,
        rating: 0,
        completedDateLabel: 'URGENT: 2.4km away',
      ),
      const TechnicianJobRecord(
        title: 'Mesh Wi-Fi Configuration',
        clientName: 'TechCorp Office',
        amount: 75.0,
        rating: 0,
        completedDateLabel: '0.8km away',
      ),
    ]);
  }

  void acceptJob(TechnicianJobRecord job) {
    currentJob.value = job;
  }

  void verifyJob() {
    // Transition logic if needed
  }

  void completeJob() {
    if (currentJob.value != null) {
      final completed = currentJob.value!;
      final newHistory = List<TechnicianJobRecord>.from(profile.value!.serviceHistory);
      newHistory.insert(0, TechnicianJobRecord(
        title: completed.title,
        clientName: completed.clientName,
        amount: completed.amount,
        rating: 5.0,
        completedDateLabel: 'Completed: Just now',
      ));

      profile.value = TechnicianProfileData(
        fullName: profile.value!.fullName,
        specialty: profile.value!.specialty,
        yearsExperience: profile.value!.yearsExperience,
        successRate: profile.value!.successRate,
        rating: profile.value!.rating,
        completedWindowLabel: profile.value!.completedWindowLabel,
        avatarUrl: profile.value!.avatarUrl,
        serviceHistory: newHistory,
        description: profile.value!.description,
        certifications: profile.value!.certifications,
        address: profile.value!.address,
      );
      
      currentJob.value = null;
    }
  }

  void updateProfileInfo({
    String? fullName,
    String? description,
    List<String>? certifications,
    String? address,
    String? avatarUrl,
    String? specialty,
  }) {
    if (profile.value != null) {
      profile.value = profile.value!.copyWith(
        fullName: fullName,
        description: description,
        certifications: certifications,
        address: address,
        avatarUrl: avatarUrl,
        specialty: specialty,
      );
    }
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
