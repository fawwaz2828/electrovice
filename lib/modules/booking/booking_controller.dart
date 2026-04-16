import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/booking_document.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/storage_service.dart';
import '../../services/technician_service.dart' show TechnicianOnlineModel, TechnicianService;
import '../../services/technician_service.dart' as tech_svc show ServiceEstimate;
import '../../config/routes.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  // ── Technician yang dipilih customer ──────────────────────────
  final Rxn<TechnicianOnlineModel> selectedTechnician = Rxn();

  // ── Service yang dipilih customer dari tab SERVICE ──────────
  final Rxn<tech_svc.ServiceEstimate> selectedService = Rxn();

  // ── Form state (BookingFormPage) ──────────────────────────────
  final RxString description = ''.obs;
  final RxString damageType = 'other'.obs;
  final RxString userAddress = ''.obs;
  final Rx<DateTime> scheduledAt = DateTime.now().add(const Duration(hours: 2)).obs;

  // ── Slot jadwal ───────────────────────────────────────────────
  /// Jam mulai kerja teknisi (default 08:00)
  static const int _workStart = 8;
  /// Jam selesai kerja teknisi (default 17:00)
  static const int _workEnd = 17;
  /// Durasi tiap slot dalam jam (1 slot = 2 jam kerja)
  static const int _slotDuration = 2;

  /// Semua slot untuk tanggal yang dipilih (generated from workStart..workEnd)
  final RxList<DateTime> allDaySlots = <DateTime>[].obs;
  /// Jam yang sudah terisi (ada booking aktif)
  final RxList<int> occupiedHours = <int>[].obs;
  final RxBool isLoadingSlots = false.obs;

  // ── GPS koordinat customer ────────────────────────────────────
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final RxBool isDetectingLocation = false.obs;

  // ── Foto kerusakan customer ───────────────────────────────────
  final RxList<File> damagePhotos = <File>[].obs;
  final _imagePicker = ImagePicker();

  // ── Technician reviews (untuk detail page) ───────────────────
  final RxList<Map<String, dynamic>> technicianReviews = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingReviews = false.obs;

  // ── Checkout state ────────────────────────────────────────────
  final RxString paymentMethod = PaymentMethod.cash.obs;
  final RxBool isSubmitting = false.obs;

  // ── Active booking (tracking page) ───────────────────────────
  final Rxn<BookingDocument> activeBooking = Rxn();
  StreamSubscription? _activeSub;

  // ── Real-time technician location (tracking page) ─────────────
  final RxnDouble technicianLat = RxnDouble();
  final RxnDouble technicianLng = RxnDouble();
  StreamSubscription? _techLocationSub;

  // ── Booking history ───────────────────────────────────────────
  final RxList<BookingDocument> bookingHistory = <BookingDocument>[].obs;
  final RxBool isLoadingHistory = true.obs;
  StreamSubscription? _historySub;

  @override
  void onInit() {
    super.onInit();
    _loadTechnicianFromArguments();
    _initUserStreams();
    // Load slot awal setelah controller siap
    loadSlotsForDate(scheduledAt.value);
  }

  @override
  void onClose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    _techLocationSub?.cancel();
    super.onClose();
  }

  // ── Init ──────────────────────────────────────────────────────

  void _loadTechnicianFromArguments() {
    final args = Get.arguments;
    if (args is TechnicianOnlineModel) {
      // Set dari args dulu agar UI langsung tampil
      selectedTechnician.value = args;
      _loadTechnicianReviews(args.uid);
      // Fresh fetch agar rating & totalJobs selalu up-to-date
      _refreshTechnicianData(args.uid, args.distanceKm);
    }
  }

  Future<void> _refreshTechnicianData(String uid, double distanceKm) async {
    try {
      final fresh = await TechnicianService().getTechnicianDetail(uid);
      if (fresh != null) {
        // Pertahankan distanceKm dari list (tidak tersimpan di Firestore)
        selectedTechnician.value = TechnicianOnlineModel(
          uid: fresh.uid,
          name: fresh.name,
          specialty: fresh.specialty,
          category: fresh.category,
          rating: fresh.rating,
          totalJobs: fresh.totalJobs,
          yearsExperience: fresh.yearsExperience,
          isAvailable: fresh.isAvailable,
          workshopAddress: fresh.workshopAddress,
          distanceKm: distanceKm,
          accreditations: fresh.accreditations,
          certificationUrls: fresh.certificationUrls,
          serviceEstimates: fresh.serviceEstimates,
          diagnosisFee: fresh.diagnosisFee,
          photoUrl: fresh.photoUrl,
          lat: fresh.lat,
          lng: fresh.lng,
        );
      }
    } catch (e) {
      debugPrint('_refreshTechnicianData error: $e');
    }
  }

  Future<void> _loadTechnicianReviews(String techId) async {
    isLoadingReviews.value = true;
    try {
      final docs = await _bookingService.fetchTechnicianReviews(techId);
      technicianReviews.assignAll(docs.map((b) => {
        'reviewerName': b.userName,
        'rating': b.customerRating ?? 0,
        'comment': b.customerReview ?? '',
        'date': _formatDate(b.updatedAt),
      }).toList());
    } catch (e) {
      debugPrint('loadTechnicianReviews error: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> _initUserStreams() async {
    // Wait for Firebase Auth to restore persisted auth state (handles cold start
    // where currentUser is null until the SDK finishes reading from disk).
    String? uid = _authService.currentUser?.uid;
    if (uid == null) {
      try {
        final user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 10));
        uid = user?.uid;
      } catch (_) {
        uid = _authService.currentUser?.uid;
      }
    }
    if (uid == null) return;

    // Listen to active booking
    _activeSub = _bookingService.streamActiveBooking(uid).listen(
      (doc) {
        final prev = activeBooking.value;
        activeBooking.value = doc;

        // Mulai stream lokasi teknisi saat status `confirmed` (teknisi menuju lokasi)
        if (doc != null && doc.status == BookingStatus.confirmed) {
          _startTechLocationStream(doc.technicianId);
        } else if (prev?.status == BookingStatus.confirmed &&
            doc?.status != BookingStatus.confirmed) {
          _stopTechLocationStream();
        }

        // Auto-navigate ke review page saat status berubah ke done & belum dirating
        if (doc != null &&
            doc.status == BookingStatus.done &&
            doc.customerRating == null &&
            prev?.status != BookingStatus.done) {
          // Delay kecil agar halaman tracking render dulu
          Future.delayed(const Duration(milliseconds: 600), () {
            if (Get.currentRoute == AppRoutes.orderTracking) {
              Get.toNamed(AppRoutes.review, arguments: doc);
            }
          });
        }
      },
      onError: (e) => debugPrint('BookingController active stream error: $e'),
    );

    // Listen to history
    _historySub = _bookingService.streamCustomerHistory(uid).listen(
      (docs) {
        bookingHistory.assignAll(docs);
        isLoadingHistory.value = false;
      },
      onError: (e) {
        debugPrint('BookingController history stream error: $e');
        isLoadingHistory.value = false;
      },
    );
  }

  // ── Technician Live Location (tracking page) ─────────────────

  void _startTechLocationStream(String techId) {
    // Jangan duplicate stream untuk technician yang sama
    if (_techLocationSub != null) return;
    _techLocationSub = FirebaseFirestore.instance
        .collection('technicians_online')
        .doc(techId)
        .snapshots()
        .listen(
          (snap) {
            if (!snap.exists) return;
            final data = snap.data();
            final loc = data?['currentLocation'] as Map?;
            technicianLat.value = (loc?['lat'] as num?)?.toDouble();
            technicianLng.value = (loc?['lng'] as num?)?.toDouble();
          },
          onError: (e) => debugPrint('techLocationSub error: $e'),
        );
  }

  void _stopTechLocationStream() {
    _techLocationSub?.cancel();
    _techLocationSub = null;
    technicianLat.value = null;
    technicianLng.value = null;
  }

  // ── Technician Detail Page ────────────────────────────────────

  /// Map TechnicianOnlineModel → CustomerTechnicianDetail untuk UI page.
  CustomerTechnicianDetail get technicianData {
    final t = selectedTechnician.value;
    if (t == null) return _emptyTechnician();

    return CustomerTechnicianDetail(
      id: t.uid,
      name: t.name,
      specialty: t.specialty.isEmpty ? t.category.toUpperCase() : t.specialty,
      yearsExperience: t.yearsExperience,
      successRate: 100,
      rating: t.rating,
      avatarUrl: t.photoUrl,
      accreditations: t.accreditations,
      guaranteeText:
          'Setiap pengerjaan dilindungi sistem kode verifikasi 6 digit unik sebagai bukti kehadiran teknisi.',
      estimates: t.serviceEstimates
          .map((e) => ServiceEstimate(
                title: e.service,
                priceLabel: e.priceLabel,
              ))
          .toList(),
      workshopName: 'Workshop ${t.name}',
      workshopAddress: t.workshopAddress.isEmpty
          ? 'Alamat belum diisi'
          : t.workshopAddress,
      reviews: technicianReviews
          .map((r) => CustomerReview(
                author: r['reviewerName'] as String? ?? '-',
                comment: r['comment'] as String? ?? '',
                rating: (r['rating'] as num?)?.toInt() ?? 0,
              ))
          .toList(),
    );
  }

  CustomerTechnicianDetail _emptyTechnician() {
    return const CustomerTechnicianDetail(
      id: '',
      name: '-',
      specialty: '-',
      yearsExperience: 0,
      successRate: 0,
      rating: 0,
      accreditations: [],
      guaranteeText: '',
      estimates: [],
      workshopName: '',
      workshopAddress: '',
      reviews: [],
    );
  }

  // ── Form Page ─────────────────────────────────────────────────

  void setDescription(String value) => description.value = value;
  void setDamageType(String value) => damageType.value = value;
  void setUserAddress(String value) => userAddress.value = value;
  void setSelectedService(tech_svc.ServiceEstimate s) => selectedService.value = s;

  /// Buka Mapbox location picker → set lat/lng + isi teks alamat secara otomatis.
  Future<void> pickLocationFromMap(
      void Function(String address) onAddressChanged) async {
    final result = await Get.toNamed(AppRoutes.mapboxLocationPicker);
    if (result != null && result is Map) {
      latitude.value = result['lat'] as double?;
      longitude.value = result['lng'] as double?;
      final addr = result['address'] as String? ?? '';
      if (addr.isNotEmpty) onAddressChanged(addr);
    }
  }

  /// Helper untuk membuka pre-booking chat ke teknisi yang sedang dibuka
  void openPreChat() async {
    final t = selectedTechnician.value;
    if (t == null) return;
    final uid  = _authService.currentUser?.uid ?? '';
    final user = await _authService.getUserModel(uid);
    final name = user?.name ?? _authService.currentUser?.email ?? 'Customer';
    Get.toNamed(AppRoutes.chat, arguments: {
      'customerId':      uid,
      'customerName':    name,
      'technicianId':    t.uid,
      'otherPartyName':  t.name,
      'otherPartyPhotoUrl': t.photoUrl,
    });
  }

  /// Set tanggal saja — pertahankan jam yang sudah dipilih jika slotnya masih tersedia.
  void setScheduledDate(DateTime date) {
    final currentHour = scheduledAt.value.hour;
    scheduledAt.value = DateTime(date.year, date.month, date.day, currentHour);
    loadSlotsForDate(date);
  }

  /// Set jam slot — pertahankan tanggal yang sudah dipilih.
  void setScheduledAt(DateTime value) => scheduledAt.value = value;

  /// Load semua slot hari itu dan tandai mana yang sudah terisi.
  Future<void> loadSlotsForDate(DateTime date) async {
    final tech = selectedTechnician.value;
    isLoadingSlots.value = true;

    // Generate semua slot: 08:00, 10:00, 12:00, 14:00, 16:00
    final slots = <DateTime>[];
    for (int h = _workStart; h + _slotDuration <= _workEnd; h += _slotDuration) {
      slots.add(DateTime(date.year, date.month, date.day, h));
    }
    allDaySlots.assignAll(slots);

    if (tech == null) {
      occupiedHours.clear();
      isLoadingSlots.value = false;
      return;
    }

    try {
      final occupied = await _bookingService.fetchOccupiedHours(tech.uid, date);
      occupiedHours.assignAll(occupied);

      // Jika slot yang sedang dipilih sudah terisi atau sudah lewat, pilih slot pertama yang tersedia
      final now = DateTime.now();
      final currentSlot = DateTime(date.year, date.month, date.day, scheduledAt.value.hour);
      final isCurrentOccupied = occupied.contains(currentSlot.hour);
      final isCurrentPast = currentSlot.isBefore(now);

      if (isCurrentOccupied || isCurrentPast) {
        final firstFree = slots.where((s) =>
            !occupied.contains(s.hour) && !s.isBefore(now)).firstOrNull;
        if (firstFree != null) {
          scheduledAt.value = firstFree;
        }
      }
    } catch (e) {
      debugPrint('loadSlotsForDate error: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// Cek apakah sebuah slot tersedia (tidak terisi & tidak lewat waktu).
  bool isSlotAvailable(DateTime slot) {
    if (slot.isBefore(DateTime.now())) return false;
    return !occupiedHours.contains(slot.hour);
  }

  bool get isFormValid =>
      description.value.trim().isNotEmpty && userAddress.value.trim().isNotEmpty;

  /// Deteksi lokasi GPS customer — simpan lat/lng, tidak menggantikan teks alamat.
  Future<void> detectGpsLocation() async {
    isDetectingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Mati', 'Aktifkan layanan lokasi di pengaturan perangkat',
            snackPosition: SnackPosition.TOP);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Izin Ditolak',
            'Aktifkan izin lokasi di Pengaturan > Aplikasi > Electrovice',
            snackPosition: SnackPosition.TOP);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      Get.snackbar('Lokasi Terdeteksi', 'Koordinat GPS berhasil disimpan',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    } catch (e) {
      debugPrint('GPS error: $e');
      Get.snackbar('Gagal', 'Tidak bisa mendapatkan lokasi GPS',
          snackPosition: SnackPosition.TOP);
    } finally {
      isDetectingLocation.value = false;
    }
  }

  // ── Damage Photos ─────────────────────────────────────────────

  Future<void> addDamagePhoto() async {
    if (damagePhotos.length >= 3) {
      Get.snackbar('Maksimal 3 foto', 'Hapus foto yang ada untuk menambah yang baru',
          snackPosition: SnackPosition.TOP);
      return;
    }
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1280,
      );
      if (picked != null) damagePhotos.add(File(picked.path));
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak bisa membuka galeri',
          snackPosition: SnackPosition.TOP);
    }
  }

  void removeDamagePhoto(int index) {
    if (index >= 0 && index < damagePhotos.length) {
      damagePhotos.removeAt(index);
    }
  }

  // ── Checkout Page ─────────────────────────────────────────────

  void setPaymentMethod(String method) => paymentMethod.value = method;

  /// Customer batalkan booking (hanya boleh saat pending/confirmed).
  Future<void> cancelBooking() async {
    final booking = activeBooking.value;
    if (booking == null) return;
    if (booking.status != BookingStatus.pending &&
        booking.status != BookingStatus.confirmed) return;
    isSubmitting.value = true;
    try {
      await _bookingService.cancelBooking(booking.bookingId);
      Get.back(); // tutup dialog kalau ada
      Get.snackbar('Pesanan Dibatalkan', 'Booking berhasil dibatalkan.',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Customer konfirmasi pembayaran → status done → navigasi ke review
  Future<void> confirmPayment() async {
    final booking = activeBooking.value;
    if (booking == null) return;
    isSubmitting.value = true;
    try {
      await _bookingService.confirmPayment(booking.bookingId);
      Get.offNamed(AppRoutes.review, arguments: booking);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Map ke CheckoutSummary untuk UI checkout page.
  CheckoutSummary get checkoutData {
    final svc = selectedService.value;
    final minPrice = svc?.minPrice ?? 0;
    final maxPrice = svc?.maxPrice ?? 0;

    // Admin fee = 10% dari minPrice (dibulatkan ke ratusan terdekat)
    final adminFee = minPrice > 0
        ? ((minPrice * 0.10) / 100).round() * 100.0
        : 0.0;

    // Delivery fee berdasarkan jarak ke workshop teknisi
    final distKm = selectedTechnician.value?.distanceKm ?? 0;
    final deliveryFee = distKm >= 10 ? 15000.0 : 8000.0;

    return CheckoutSummary(
      currentRepairTitle: svc?.service ?? _damageTypeLabel(damageType.value),
      scheduledForLabel: _formatDateTime(scheduledAt.value),
      paymentMethod: _mapPaymentType(paymentMethod.value),
      paymentOptions: const [
        PaymentOption(
          type: PaymentMethodType.wallet,
          title: 'Bayar Tunai',
          subtitle: 'Bayar langsung ke teknisi di lokasi',
        ),
      ],
      serviceFee: minPrice.toDouble(),
      partsLabel: maxPrice > 0 ? 'Estimasi maks' : 'Estimasi (bisa berubah)',
      partsFee: maxPrice.toDouble(),
      adminFee: adminFee,
      deliveryFee: deliveryFee,
    );
  }

  // ── Submit Booking ────────────────────────────────────────────

  Future<void> submitBooking() async {
    if (!isFormValid) {
      Get.snackbar('Oops', 'Deskripsi keluhan tidak boleh kosong',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Sesi habis, silakan login ulang',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final tech = selectedTechnician.value;
    if (tech == null) {
      Get.snackbar('Error', 'Data teknisi tidak ditemukan',
          snackPosition: SnackPosition.TOP);
      return;
    }

    isSubmitting.value = true;

    try {
      final userModel = await _authService.getUserModel(user.uid);
      final svc = selectedService.value;
      final estimatedPrice = svc?.minPrice ??
          (tech.serviceEstimates.isNotEmpty
              ? tech.serviceEstimates.first.minPrice
              : 0);

      // 1. Buat booking dulu (tanpa foto)
      final bookingId = await _bookingService.createBooking(
        userId: user.uid,
        userName: userModel?.name ?? user.email ?? 'Customer',
        technicianId: tech.uid,
        technicianName: tech.name,
        technicianPhotoUrl: tech.photoUrl,
        category: tech.category,
        description: description.value.trim(),
        damageType: damageType.value.isEmpty ? 'other' : damageType.value,
        scheduledAt: scheduledAt.value,
        estimatedPrice: estimatedPrice,
        userAddress: userAddress.value.trim(),
        paymentMethod: paymentMethod.value,
        latitude: latitude.value,
        longitude: longitude.value,
      );

      debugPrint('Booking created: $bookingId');

      // 2. Upload foto menggunakan bookingId asli, lalu update doc
      if (damagePhotos.isNotEmpty) {
        try {
          final photoUrls = await StorageService()
              .uploadDamagePhotos(bookingId, damagePhotos.toList());
          if (photoUrls.isNotEmpty) {
            await _bookingService.updateDamagePhotos(bookingId, photoUrls);
          }
        } catch (e) {
          debugPrint('uploadDamagePhotos error (non-fatal): $e');
          // Booking tetap berhasil meski foto gagal upload
        }
      }

      damagePhotos.clear();

      // Navigate ke tracking page (replace checkout dari stack)
      Get.offNamed(AppRoutes.orderTracking);
    } catch (e) {
      Get.snackbar('Gagal membuat booking', e.toString(),
          snackPosition: SnackPosition.TOP);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Tracking Page ─────────────────────────────────────────────

  /// Map BookingDocument → OrderTrackingData untuk UI tracking page.
  OrderTrackingData get trackingData {
    final booking = activeBooking.value;
    if (booking == null) return _emptyTracking();

    final isPending = booking.status == BookingStatus.pending;
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isOnProgress = booking.status == BookingStatus.onProgress;
    final isAwaitingPayment = booking.status == BookingStatus.awaitingPayment;
    final isDone = booking.status == BookingStatus.done;

    final steps = [
      TrackingStatusStep(
        step: OrderStatusStep.waiting,
        title: 'Menunggu Konfirmasi Teknisi',
        subtitle: 'Teknisi sedang mempertimbangkan pesanan',
        isComplete: !isPending,
        isCurrent: isPending,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.waiting,
        title: 'Teknisi di Jalan',
        subtitle: 'Teknisi sedang menuju lokasi kamu',
        isComplete: isOnProgress || isDone,
        isCurrent: isConfirmed,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.verification,
        title: 'Verifikasi Kode 6 Digit',
        subtitle: 'Tunjukkan kode ke teknisi saat tiba',
        isComplete: isOnProgress || isDone,
        isCurrent: isConfirmed,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.inProgress,
        title: 'Sedang Diperbaiki',
        subtitle: 'Teknisi sedang mengerjakan perangkat',
        isComplete: isAwaitingPayment || isDone,
        isCurrent: isOnProgress,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.completed,
        title: 'Selesai',
        subtitle: isAwaitingPayment
            ? 'Silakan lakukan pembayaran'
            : 'Pekerjaan telah selesai',
        isComplete: isDone,
        isCurrent: isAwaitingPayment || isDone,
      ),
    ];

    // Kode hanya tampil setelah teknisi accept (status confirmed ke atas)
    final secCode = isPending ? '------' : (booking.verificationCode ?? '------');

    return OrderTrackingData(
      mapTitle: 'STATUS PESANAN',
      currentStatusTitle: _statusLabel(booking.status),
      statusSteps: steps,
      securityCode: secCode,
      technicianName: booking.technicianName,
      technicianRole: booking.category.toUpperCase(),
      partnerLabel: 'ELECTROVICE VERIFIED',
      technicianAvatarUrl: booking.technicianPhotoUrl,
      customerLat: booking.latitude,
      customerLng: booking.longitude,
    );
  }

  OrderTrackingData _emptyTracking() {
    return const OrderTrackingData(
      mapTitle: 'STATUS PESANAN',
      currentStatusTitle: 'Memuat data...',
      statusSteps: [],
      securityCode: '------',
      technicianName: '-',
      technicianRole: '-',
      partnerLabel: 'ELECTROVICE',
      customerLat: null,
      customerLng: null,
    );
  }

  // ── History Page ──────────────────────────────────────────────

  /// Map BookingDocument → OrderHistoryRecord untuk UI history page.
  List<OrderHistoryRecord> get orderHistoryData {
    return bookingHistory.map((b) {
      final statusUi = switch (b.status) {
        BookingStatus.done => OrderHistoryStatus.success,
        BookingStatus.cancelled => OrderHistoryStatus.canceled,
        BookingStatus.awaitingPayment => OrderHistoryStatus.awaitingPayment,
        _ => OrderHistoryStatus.active, // pending / confirmed / on_progress
      };

      return OrderHistoryRecord(
        title: _damageTypeLabel(b.damageType),
        subtitle: b.technicianName,
        dateLabel: _formatDate(b.createdAt),
        amountLabel: b.estimatedPrice > 0
            ? 'Rp ${_formatPrice(b.estimatedPrice)}'
            : 'Tunai',
        status: statusUi,
      );
    }).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _damageTypeLabel(String type) => switch (type) {
        'screen' => 'Kerusakan Layar',
        'battery' => 'Masalah Baterai',
        'hardware' => 'Kerusakan Hardware',
        'water' => 'Water Damage',
        'camera' => 'Masalah Kamera',
        _ => 'Perbaikan Umum',
      };

  String _statusLabel(String status) => switch (status) {
        BookingStatus.pending => 'Menunggu Konfirmasi',
        BookingStatus.confirmed => 'Teknisi Menuju Lokasi',
        BookingStatus.onProgress => 'Sedang Dikerjakan',
        BookingStatus.awaitingPayment => 'Menunggu Pembayaran',
        BookingStatus.done => 'Selesai',
        BookingStatus.cancelled => 'Dibatalkan',
        _ => status,
      };

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    return '${_formatDate(dt)}, $hour.00';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  PaymentMethodType _mapPaymentType(String method) => switch (method) {
        PaymentMethod.cash => PaymentMethodType.wallet,
        _ => PaymentMethodType.wallet,
      };
}
