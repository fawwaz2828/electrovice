import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TechnicianVerificationModel {
  final String uid;
  final String name;
  final String email;
  final String city;
  final String workshopName;
  final List<String> deviceCategories;
  final String verificationStatus;
  final String? photoUrl;
  final String? ktpImageUrl;
  final String? selfieImageUrl;
  final String? nik;
  final String? namaKtp;
  final String? bio;
  final String? phone;
  final List<String> certificationUrls;
  final String? openTime;
  final String? closeTime;
  final List<String> availableDays;
  final double serviceRadius;
  final DateTime? submittedAt;

  TechnicianVerificationModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.city,
    required this.workshopName,
    required this.deviceCategories,
    required this.verificationStatus,
    this.photoUrl,
    this.ktpImageUrl,
    this.selfieImageUrl,
    this.nik,
    this.namaKtp,
    this.bio,
    this.phone,
    required this.certificationUrls,
    this.openTime,
    this.closeTime,
    required this.availableDays,
    required this.serviceRadius,
    this.submittedAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get submittedLabel {
    if (submittedAt == null) return '-';
    final d = submittedAt!;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hour:$min';
  }

  factory TechnicianVerificationModel.fromFirestore(
      Map<String, dynamic> data, String uid) {
    final profile = data['technicianProfile'] as Map<String, dynamic>? ?? {};
    final cats = (profile['deviceCategories'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final days = (profile['availableDays'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final certs = (profile['certificationUrls'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    DateTime? submittedAt;
    final ts = data['updatedAt'] ?? data['createdAt'];
    if (ts is Timestamp) submittedAt = ts.toDate();

    return TechnicianVerificationModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      city: profile['city'] as String? ?? '',
      workshopName: profile['workshopName'] as String? ?? 'Tanpa workshop',
      deviceCategories: cats,
      verificationStatus:
          profile['verificationStatus'] as String? ?? 'pending',
      photoUrl: profile['photoUrl'] as String? ?? data['photoUrl'] as String?,
      ktpImageUrl: profile['ktpImageUrl'] as String?,
      selfieImageUrl: profile['selfieImageUrl'] as String?,
      nik: profile['nik'] as String?,
      namaKtp: data['name'] as String?,
      bio: profile['bio'] as String?,
      phone: profile['phone'] as String?,
      certificationUrls: certs,
      openTime: profile['openTime'] as String?,
      closeTime: profile['closeTime'] as String?,
      availableDays: days,
      serviceRadius:
          (profile['serviceRadius'] as num?)?.toDouble() ?? 5.0,
      submittedAt: submittedAt,
    );
  }
}

class AdminController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  final RxList<TechnicianVerificationModel> technicians =
      <TechnicianVerificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  List<TechnicianVerificationModel> get pendingList =>
      technicians.where((t) => t.verificationStatus == 'pending').toList();
  List<TechnicianVerificationModel> get verifiedList =>
      technicians.where((t) => t.verificationStatus == 'verified').toList();
  List<TechnicianVerificationModel> get declinedList =>
      technicians.where((t) => t.verificationStatus == 'declined').toList();

  @override
  void onInit() {
    super.onInit();
    fetchTechnicians();
  }

  Future<void> fetchTechnicians() async {
    isLoading.value = true;
    error.value = '';
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'technician')
          .get();

      technicians.value = snapshot.docs
          .map((doc) =>
              TechnicianVerificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      error.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(String uid) async {
    await _updateStatus(uid, 'verified');
  }

  Future<void> decline(String uid) async {
    await _updateStatus(uid, 'declined');
  }

  Future<void> _updateStatus(String uid, String status) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'technicianProfile.verificationStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list tanpa fetch ulang
      final index = technicians.indexWhere((t) => t.uid == uid);
      if (index != -1) {
        final old = technicians[index];
        technicians[index] = TechnicianVerificationModel(
          uid: old.uid,
          name: old.name,
          email: old.email,
          city: old.city,
          workshopName: old.workshopName,
          deviceCategories: old.deviceCategories,
          verificationStatus: status,
          photoUrl: old.photoUrl,
          ktpImageUrl: old.ktpImageUrl,
          selfieImageUrl: old.selfieImageUrl,
          nik: old.nik,
          namaKtp: old.namaKtp,
          bio: old.bio,
          phone: old.phone,
          certificationUrls: old.certificationUrls,
          openTime: old.openTime,
          closeTime: old.closeTime,
          availableDays: old.availableDays,
          serviceRadius: old.serviceRadius,
          submittedAt: old.submittedAt,
        );
      }

      Get.snackbar(
        status == 'verified' ? 'Approved ✓' : 'Declined',
        status == 'verified'
            ? 'Teknisi berhasil diverifikasi'
            : 'Teknisi telah ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Gagal update status: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
