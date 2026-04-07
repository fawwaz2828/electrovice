import 'package:get/get.dart';
import '../../models/technician_model.dart';
import '../../services/auth_service.dart';

class TechnicianController extends GetxController {
  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final AuthService _authService = AuthService();

  final RxBool isOnline = true.obs;
  final Rxn<TechnicianJobRecord> currentJob = Rxn<TechnicianJobRecord>();
  final RxList<TechnicianJobRecord> incomingRequests =
      <TechnicianJobRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
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

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final userModel = await _authService.getUserModel(user.uid);
    if (userModel == null) return;

    final tp = userModel.technicianProfile;

    profile.value = TechnicianProfileData(
      fullName: userModel.name,
      specialty: tp?.specialty ?? '',
      yearsExperience: tp?.yearsExperience ?? 0,
      successRate: tp?.successRate ?? 100,
      rating: tp?.rating ?? 0.0,
      completedWindowLabel: 'LAST 30 DAYS',
      avatarUrl: tp?.photoUrl ?? userModel.photoUrl,
      serviceHistory: const [],
      certifications: const [],
    );
  }

  // Dipanggil setelah balik dari edit page
  Future<void> refreshProfile() async {
    await _loadUserData();
  }

  void acceptJob(TechnicianJobRecord job) {
    currentJob.value = job;
  }

  void verifyJob() {}

  void completeJob() {
    if (currentJob.value != null) {
      final completed = currentJob.value!;
      final newHistory = List<TechnicianJobRecord>.from(
        profile.value!.serviceHistory,
      );
      newHistory.insert(
        0,
        TechnicianJobRecord(
          title: completed.title,
          clientName: completed.clientName,
          amount: completed.amount,
          rating: 5.0,
          completedDateLabel: 'Completed: Just now',
        ),
      );

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

  void setProfile(TechnicianProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = TechnicianProfileData.fromMap(map);
  }
}
