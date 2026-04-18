import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/technician_model.dart';
import '../../models/booking_document.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/technician_service.dart' show TechnicianService, ServiceEstimate;

class TechnicianController extends GetxController with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final TechnicianService _techService = TechnicianService();

  final Rxn<TechnicianProfileData> profile = Rxn<TechnicianProfileData>();
  final RxBool isOnline = false.obs;
  final RxBool isTogglingOnline = false.obs;

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

  // ── Live location tracking ────────────────────────────────────
  Timer? _locationTimer;
  String? _trackingUid;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && !_ordersStreamActive) {
        _ordersSub?.cancel();
        _listenToOrders(user.uid);
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _ordersSub?.cancel();
    _authSub?.cancel();
    _stopLocationTracking();
    super.onClose();
  }

  /// Restart dead stream when app comes back to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_ordersStreamActive) {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        _ordersSub?.cancel();
        _listenToOrders(uid);
      }
    }
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
        fullName: userModel?.name ?? user.email ?? 'Technician',
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
      _loadOnlineStatus(user.uid);
      // Sync rating rata-rata + totalJobs ke technicians_online.
      // Dilakukan sisi teknisi karena customer tidak punya izin tulis ke sana.
      _bookingService.syncTechnicianStats(user.uid);
    } catch (e) {
      debugPrint('TechnicianController._loadUserData error: $e');
      // Set minimal profile so UI doesn't stay in skeleton forever
      final uid = _authService.currentUser?.uid;
      profile.value = TechnicianProfileData(
        fullName: _authService.currentUser?.email ?? 'Technician',
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

  // ── Online / Offline status ───────────────────────────────────

  Future<void> _loadOnlineStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('technicians_online')
          .doc(uid)
          .get();
      if (doc.exists) {
        isOnline.value = doc.data()?['isOnline'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('_loadOnlineStatus error: $e');
    }
  }

  /// Toggle online/offline dan persist ke Firestore.
  Future<void> setOnlineStatus(bool online) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    isTogglingOnline.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('technicians_online')
          .doc(uid)
          .set({'isOnline': online}, SetOptions(merge: true));
      isOnline.value = online;
    } catch (e) {
      debugPrint('setOnlineStatus error: $e');
    } finally {
      isTogglingOnline.value = false;
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
    _trackingUid = technicianId;

    // Timeout: jika stream tidak balas dalam 10 detik, hentikan loading state
    Future.delayed(const Duration(seconds: 10), () {
      if (isLoadingOrders.value) {
        isLoadingOrders.value = false;
        debugPrint('TechnicianController: orders stream timeout');
      }
    });

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

            // Kirim lokasi real-time hanya saat status `confirmed` (menuju lokasi)
            if (active?.status == BookingStatus.confirmed) {
              _startLocationTracking(technicianId);
            } else {
              _stopLocationTracking();
            }

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
            // Auto-retry after 3 s so new orders don't require logout to appear.
            Future.delayed(const Duration(seconds: 3), () {
              final uid = _authService.currentUser?.uid;
              if (uid != null && !_ordersStreamActive) {
                _ordersSub?.cancel();
                _listenToOrders(uid);
              }
            });
          },
          onDone: () {
            _ordersStreamActive = false;
            Future.delayed(const Duration(seconds: 1), () {
              final uid = _authService.currentUser?.uid;
              if (uid != null && !_ordersStreamActive) {
                _ordersSub?.cancel();
                _listenToOrders(uid);
              }
            });
          },
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
    if (order == null) throw Exception('No order selected');
    // Jika sudah confirmed, langsung lanjut ke verifikasi tanpa memanggil Firestore lagi
    if (order.status == BookingStatus.confirmed) return;
    if (order.status != BookingStatus.pending) {
      throw Exception('Invalid order status: ${order.status}');
    }
    await _bookingService.acceptBooking(order.bookingId);
  }

  /// Teknisi decline order → status cancelled
  Future<void> declineOrder() async {
    final order = selectedOrder.value;
    if (order == null) throw Exception('No order selected');
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
    if (order == null) throw Exception('No order selected');
    await _bookingService.verifyCode(order.bookingId, enteredCode);
  }

  /// Teknisi submit harga final → status awaiting_payment
  Future<void> submitFinalPrice({
    required int serviceFee,
    required List<Map<String, dynamic>> spareParts,
    required String note,
    required int diagnosisFee,
    List<String> workPhotoUrls = const [],
  }) async {
    final order = activeOrder.value ?? selectedOrder.value;
    if (order == null) throw Exception('No active order');
    final partsTotal = spareParts.fold<int>(
        0, (sum, p) => sum + ((p['price'] as num?)?.toInt() ?? 0));
    final totalAmount = serviceFee + partsTotal + diagnosisFee;
    await _bookingService.submitFinalPrice(
      bookingId: order.bookingId,
      serviceFee: serviceFee,
      spareParts: spareParts,
      note: note,
      totalAmount: totalAmount,
      workPhotoUrls: workPhotoUrls,
    );
  }

  /// Tandai pekerjaan selesai — return order untuk ditampilkan di JobSummaryPage
  Future<BookingDocument> completeJob() async {
    final order = activeOrder.value;
    if (order == null) throw Exception('No active order');
    await _bookingService.markAsDone(order.bookingId);
    return order;
  }

  /// Dipanggil setelah balik dari edit page
  Future<void> refreshProfile() async => _loadUserData();

  /// Refresh semua data (orders + profile) — bisa dipanggil dari UI
  Future<void> refreshAll() async {
    isLoadingOrders.value = true;
    _ordersSub?.cancel();
    _ordersStreamActive = false;
    await _loadUserData();
  }

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

  // ── Live location tracking ────────────────────────────────────

  Future<void> _startLocationTracking(String uid) async {
    if (_locationTimer != null && _locationTimer!.isActive) return;

    // Request permission jika belum
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Location permission denied — tracking disabled');
      return;
    }

    debugPrint('Starting location tracking for $uid');
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        await FirebaseFirestore.instance
            .collection('technicians_online')
            .doc(uid)
            .set({
          'currentLocation': {
            'lat': pos.latitude,
            'lng': pos.longitude,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        }, SetOptions(merge: true));
        debugPrint('Location updated: ${pos.latitude}, ${pos.longitude}');
      } catch (e) {
        debugPrint('location update error: $e');
      }
    });
  }

  void _stopLocationTracking() {
    if (_locationTimer == null) return;
    debugPrint('Stopping location tracking');
    _locationTimer?.cancel();
    _locationTimer = null;
    // Clear currentLocation dari Firestore agar customer tidak lihat posisi stale
    if (_trackingUid != null) {
      FirebaseFirestore.instance
          .collection('technicians_online')
          .doc(_trackingUid)
          .set({'currentLocation': null}, SetOptions(merge: true))
          .catchError((e) => debugPrint('clear location error: $e'));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _damageLabel(String type) => switch (type) {
        'screen' => 'Screen Damage',
        'battery' => 'Battery Issue',
        'hardware' => 'Hardware Damage',
        'water' => 'Water Damage',
        'camera' => 'Camera Issue',
        _ => 'General Repair',
      };

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}