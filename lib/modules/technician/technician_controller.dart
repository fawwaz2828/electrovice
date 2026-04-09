import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../models/technician_model.dart';
import '../../models/booking_document.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class TechnicianController extends GetxController {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();

  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final RxBool isOnline = true.obs;

  // ── Booking state (Firestore) ─────────────────────────────────

  /// Semua incoming orders (confirmed + on_progress)
  final RxList<BookingDocument> incomingOrders = <BookingDocument>[].obs;
  final RxBool isLoadingOrders = true.obs;

  /// Booking yang sedang aktif dikerjakan (on_progress)
  final Rxn<BookingDocument> activeOrder = Rxn<BookingDocument>();

  /// Booking yang sedang dibuka detail / verifikasi
  final Rxn<BookingDocument> selectedOrder = Rxn<BookingDocument>();

  // ── Legacy Rx untuk backward compat dengan home page UI ───────
  /// currentJob dipakai oleh TechnicianHomePage via .value
  final Rxn<TechnicianJobRecord> currentJob = Rxn<TechnicianJobRecord>();
  /// incomingRequests RxList dipakai oleh TechnicianHomePage via .map()
  final RxList<TechnicianJobRecord> incomingRequests = <TechnicianJobRecord>[].obs;

  StreamSubscription? _ordersSub;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }

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
    );

    _listenToOrders(user.uid);
  }

  void _listenToOrders(String technicianId) {
    _ordersSub = _bookingService
        .streamTechnicianOrders(technicianId)
        .listen(
          (orders) {
            incomingOrders.assignAll(orders);

            // Update legacy incomingRequests (hanya yang confirmed, belum on_progress)
            incomingRequests.assignAll(
              orders
                  .where((o) => o.status == BookingStatus.confirmed)
                  .map((o) => TechnicianJobRecord(
                        title: _damageLabel(o.damageType),
                        clientName: o.userName,
                        amount: o.estimatedPrice.toDouble(),
                        rating: 0,
                        completedDateLabel: _formatDate(o.scheduledAt),
                      ))
                  .toList(),
            );

            // Update active order (on_progress)
            final active = orders
                .where((o) => o.status == BookingStatus.onProgress)
                .firstOrNull;
            activeOrder.value = active;

            // Update legacy currentJob
            currentJob.value = active == null
                ? null
                : TechnicianJobRecord(
                    title: _damageLabel(active.damageType),
                    clientName: active.userName,
                    amount: active.estimatedPrice.toDouble(),
                    rating: 0,
                    completedDateLabel: _formatDate(active.scheduledAt),
                  );

            isLoadingOrders.value = false;
          },
          onError: (e) {
            debugPrint('TechnicianController orders stream error: $e');
            isLoadingOrders.value = false;
          },
        );
  }

  // ── Actions ───────────────────────────────────────────────────

  /// Set order yang akan diverifikasi
  void selectOrder(BookingDocument order) {
    selectedOrder.value = order;
  }

  /// Dipanggil dari JobDetailPage — pilih order pertama (confirmed) untuk diverifikasi
  void acceptJob(TechnicianJobRecord _) {
    final order = incomingOrders
        .where((o) => o.status == BookingStatus.confirmed)
        .firstOrNull;
    if (order != null) selectedOrder.value = order;
  }

  /// Verifikasi kode 6 digit
  Future<void> verifyCode(String enteredCode) async {
    final order = selectedOrder.value ?? activeOrder.value;
    if (order == null) throw Exception('Tidak ada order yang dipilih');
    await _bookingService.verifyCode(order.bookingId, enteredCode);
  }

  /// Tandai pekerjaan selesai
  Future<void> completeJob() async {
    final order = activeOrder.value;
    if (order == null) throw Exception('Tidak ada order aktif');
    await _bookingService.markAsDone(order.bookingId);
  }

  /// Dipanggil setelah balik dari edit page
  Future<void> refreshProfile() async => _loadUserData();

  void setProfile(TechnicianProfileData data) => profile.value = data;

  // ── Helpers ───────────────────────────────────────────────────

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
