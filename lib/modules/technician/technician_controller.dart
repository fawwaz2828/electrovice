import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../models/technician_model.dart';
import '../../models/booking_document.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/technician_service.dart' show TechnicianService, ServiceEstimate;

class TechnicianController extends GetxController {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final TechnicianService _techService = TechnicianService();

  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final RxBool isOnline = true.obs;

  // ── Booking state (Firestore) ─────────────────────────────────

  /// Semua incoming orders (confirmed + on_progress)
  final RxList<BookingDocument> incomingOrders = <BookingDocument>[].obs;
  final RxBool isLoadingOrders = true.obs;

  /// Order yang sudah selesai (done) — untuk history page
  final RxList<BookingDocument> completedOrders = <BookingDocument>[].obs;
  final RxBool isLoadingCompleted = false.obs;

  /// Booking yang sedang aktif dikerjakan (on_progress)
  final Rxn<BookingDocument> activeOrder = Rxn<BookingDocument>();

  /// Booking yang sedang dibuka detail / verifikasi
  final Rxn<BookingDocument> selectedOrder = Rxn<BookingDocument>();

  // ── Service estimates (My Service page) ──────────────────────
  final RxList<ServiceEstimate> serviceEstimates = <ServiceEstimate>[].obs;
  final RxBool isLoadingServices = false.obs;

  // ── Legacy Rx untuk backward compat dengan home page UI ───────
  /// currentJob dipakai oleh TechnicianHomePage via .value
  final Rxn<TechnicianJobRecord> currentJob = Rxn<TechnicianJobRecord>();
  /// incomingRequests RxList dipakai oleh TechnicianHomePage via .map()
  final RxList<TechnicianJobRecord> incomingRequests = <TechnicianJobRecord>[].obs;

  StreamSubscription? _ordersSub;
  StreamSubscription? _authSub;
  bool _ordersStreamActive = false;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    // Re-subscribe streams if Firebase Auth fires a sign-out/sign-in cycle
    // (can happen during token refresh — causes Firestore PERMISSION_DENIED)
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !_ordersStreamActive) {
        _ordersSub?.cancel();
        _listenToOrders(user.uid);
      }
    });
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  /// Total earnings dari semua order selesai
  int get totalEarnings => completedOrders.fold(
      0, (sum, o) => sum + (o.finalTotalAmount ?? o.estimatedPrice));

  Future<void> _loadUserData() async {
    try {
      int retry = 0;
      while (_authService.currentUser == null && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retry++;
      }

      final user = _authService.currentUser;
      if (user == null) return;

      final userModel = await _authService.getUserModel(user.uid);
      final tp = userModel?.technicianProfile;

      profile.value = TechnicianProfileData(
        fullName: userModel?.name ?? user.email ?? 'Teknisi',
        specialty: tp?.specialty ?? '',
        yearsExperience: tp?.yearsExperience ?? 0,
        successRate: tp?.successRate ?? 100,
        rating: tp?.rating ?? 0.0,
        completedWindowLabel: 'LAST 30 DAYS',
        avatarUrl: tp?.photoUrl ?? userModel?.photoUrl,
        serviceHistory: const [],
        certifications: const [],
      );

      _listenToOrders(user.uid);
      _loadServices(user.uid);
      loadCompletedOrders();
      // Sync rating rata-rata + totalJobs ke technicians_online.
      // Dilakukan sisi teknisi karena customer tidak punya izin tulis ke sana.
      _bookingService.syncTechnicianStats(user.uid);
    } catch (e) {
      debugPrint('TechnicianController._loadUserData error: $e');
      // Set minimal profile so UI doesn't stay in skeleton forever
      final uid = _authService.currentUser?.uid;
      profile.value = TechnicianProfileData(
        fullName: _authService.currentUser?.email ?? 'Teknisi',
        specialty: '',
        yearsExperience: 0,
        successRate: 100,
        rating: 0.0,
        completedWindowLabel: 'LAST 30 DAYS',
        serviceHistory: const [],
        certifications: const [],
      );
      if (uid != null) {
        _listenToOrders(uid);
        _loadServices(uid);
      }
    }
  }

  Future<void> _loadServices(String uid) async {
    try {
      isLoadingServices.value = true;
      final list = await _techService.getServiceEstimates(uid);
      serviceEstimates.assignAll(list);
    } catch (e) {
      debugPrint('_loadServices error: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  // ── Service CRUD ──────────────────────────────────────────────

  Future<void> addService(ServiceEstimate s) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    serviceEstimates.add(s);
    await _techService.saveServiceEstimates(uid, serviceEstimates.toList());
  }

  Future<void> updateService(int index, ServiceEstimate s) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    serviceEstimates[index] = s;
    await _techService.saveServiceEstimates(uid, serviceEstimates.toList());
  }

  Future<void> deleteService(int index) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    serviceEstimates.removeAt(index);
    await _techService.saveServiceEstimates(uid, serviceEstimates.toList());
  }

  Future<void> refreshServices() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) await _loadServices(uid);
  }

  void _listenToOrders(String technicianId) {
    _ordersStreamActive = true;
    _ordersSub = _bookingService
        .streamTechnicianOrders(technicianId)
        .listen(
          (orders) {
            incomingOrders.assignAll(orders);

            // Sync selectedOrder dari stream agar tidak stale setelah re-login
            if (selectedOrder.value != null) {
              final updated = orders
                  .where((o) => o.bookingId == selectedOrder.value!.bookingId)
                  .firstOrNull;
              if (updated != null) selectedOrder.value = updated;
            }

            // incomingRequests hanya yang masih pending (belum diaccept teknisi)
            incomingRequests.assignAll(
              orders
                  .where((o) => o.status == BookingStatus.pending)
                  .map((o) => TechnicianJobRecord(
                        title: _damageLabel(o.damageType),
                        clientName: o.userName,
                        amount: o.estimatedPrice.toDouble(),
                        rating: 0,
                        completedDateLabel: _formatDate(o.scheduledAt),
                      ))
                  .toList(),
            );

            // activeOrder = confirmed / on_progress / awaiting_payment
            final active = orders
                .where((o) =>
                    o.status == BookingStatus.confirmed ||
                    o.status == BookingStatus.onProgress ||
                    o.status == BookingStatus.awaitingPayment)
                .firstOrNull;
            activeOrder.value = active;

            // Auto-set selectedOrder ke confirmed order jika belum dipilih
            // Berguna setelah re-login agar verification page bisa lanjut
            if (active != null && selectedOrder.value == null) {
              selectedOrder.value = active;
            }

            // currentJob untuk "Current Assignment" di home page
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
            _ordersStreamActive = false;
            debugPrint('TechnicianController orders stream error: $e');
            isLoadingOrders.value = false;
          },
          onDone: () => _ordersStreamActive = false,
        );
  }

  /// Muat riwayat order selesai dari Firestore
  Future<void> loadCompletedOrders() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    isLoadingCompleted.value = true;
    try {
      final orders = await _bookingService.fetchDoneOrders(uid);
      completedOrders.assignAll(orders);
    } catch (e) {
      debugPrint('loadCompletedOrders error: $e');
    } finally {
      isLoadingCompleted.value = false;
    }
  }

  // ── Actions ───────────────────────────────────────────────────

  /// Set order yang akan diverifikasi
  void selectOrder(BookingDocument order) {
    selectedOrder.value = order;
  }

  /// Teknisi accept order → status pending → confirmed + generate kode verifikasi
  Future<void> acceptOrder() async {
    final order = selectedOrder.value;
    if (order == null) throw Exception('Tidak ada order yang dipilih');
    // Jika sudah confirmed, langsung lanjut ke verifikasi tanpa memanggil Firestore lagi
    if (order.status == BookingStatus.confirmed) return;
    if (order.status != BookingStatus.pending) {
      throw Exception('Status order tidak valid: ${order.status}');
    }
    await _bookingService.acceptBooking(order.bookingId);
  }

  /// Teknisi decline order → status cancelled
  Future<void> declineOrder() async {
    final order = selectedOrder.value;
    if (order == null) throw Exception('Tidak ada order yang dipilih');
    await _bookingService.declineBooking(order.bookingId);
    selectedOrder.value = null;
  }

  /// Dipanggil dari JobDetailPage (legacy) — pilih order pertama (pending) untuk diverifikasi
  void acceptJob(TechnicianJobRecord _) {
    final order = incomingOrders
        .where((o) => o.status == BookingStatus.pending)
        .firstOrNull;
    if (order != null) selectedOrder.value = order;
  }

  /// Verifikasi kode 6 digit
  Future<void> verifyCode(String enteredCode) async {
    final order = selectedOrder.value ?? activeOrder.value;
    if (order == null) throw Exception('Tidak ada order yang dipilih');
    await _bookingService.verifyCode(order.bookingId, enteredCode);
  }

  /// Teknisi submit harga final → status awaiting_payment
  Future<void> submitFinalPrice({
    required int serviceFee,
    required List<Map<String, dynamic>> spareParts,
    required String note,
    required int diagnosisFee,
  }) async {
    final order = activeOrder.value ?? selectedOrder.value;
    if (order == null) throw Exception('Tidak ada order aktif');
    final partsTotal = spareParts.fold<int>(
        0, (sum, p) => sum + ((p['price'] as num?)?.toInt() ?? 0));
    final totalAmount = serviceFee + partsTotal + diagnosisFee;
    await _bookingService.submitFinalPrice(
      bookingId: order.bookingId,
      serviceFee: serviceFee,
      spareParts: spareParts,
      note: note,
      totalAmount: totalAmount,
    );
  }

  /// Tandai pekerjaan selesai — return order untuk ditampilkan di JobSummaryPage
  Future<BookingDocument> completeJob() async {
    final order = activeOrder.value;
    if (order == null) throw Exception('Tidak ada order aktif');
    await _bookingService.markAsDone(order.bookingId);
    return order;
  }

  /// Dipanggil setelah balik dari edit page
  Future<void> refreshProfile() async => _loadUserData();

  void setProfile(TechnicianProfileData data) => profile.value = data;

  /// Legacy method used by technician_edit_profile_page.dart
  void updateProfileInfo({
    required String fullName,
    required String specialty,
    String description = '',
    List<String> certifications = const [],
    String address = '',
    String? avatarUrl,
  }) {
    final current = profile.value;
    if (current == null) return;
    profile.value = TechnicianProfileData(
      fullName: fullName,
      specialty: specialty,
      yearsExperience: current.yearsExperience,
      successRate: current.successRate,
      rating: current.rating,
      completedWindowLabel: current.completedWindowLabel,
      avatarUrl: avatarUrl ?? current.avatarUrl,
      serviceHistory: current.serviceHistory,
      certifications: certifications.isNotEmpty
          ? certifications
          : current.certifications,
    );
  }

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
