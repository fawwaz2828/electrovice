import 'package:get/get.dart';

import '../../models/technician_model.dart';

class TechnicianController extends GetxController {
  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  
  // New Service Flow State
  final RxBool isOnline = true.obs;
  final Rxn<TechnicianJobRecord> currentJob = Rxn<TechnicianJobRecord>();
  final RxList<TechnicianJobRecord> incomingRequests = <TechnicianJobRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    profile.value = TechnicianProfileData.sample();
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
    // In a real app, we'd update the server here
  }

  void verifyJob() {
    // Transition to Active Job state
    // For now, the navigation is handled in the pages, 
    // but the state is maintained here.
  }

  void completeJob() {
    if (currentJob.value != null) {
      // Move current job to history
      final completed = currentJob.value!;
      final newHistory = List<TechnicianJobRecord>.from(profile.value!.serviceHistory);
      newHistory.insert(0, TechnicianJobRecord(
        title: completed.title,
        clientName: completed.clientName,
        amount: completed.amount,
        rating: 5.0, // Mock rating
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
      );
      
      currentJob.value = null;
    }
  }

  void setProfile(TechnicianProfileData data) {
    profile.value = data;
  }

  void loadFromMap(Map<String, dynamic> map) {
    profile.value = TechnicianProfileData.fromMap(map);
  }
}
