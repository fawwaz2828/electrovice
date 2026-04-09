import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/booking_document.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/technician_service.dart' show TechnicianOnlineModel;
import '../../config/routes.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  // ── Technician yang dipilih customer ──────────────────────────
  final Rxn<TechnicianOnlineModel> selectedTechnician = Rxn();

  // ── Form state (BookingFormPage) ──────────────────────────────
  final RxString description = ''.obs;
  final RxString damageType = 'other'.obs;
  final RxString userAddress = ''.obs;
  final Rx<DateTime> scheduledAt = DateTime.now().add(const Duration(hours: 2)).obs;

  // ── GPS koordinat customer ────────────────────────────────────
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final RxBool isDetectingLocation = false.obs;

  // ── Checkout state ────────────────────────────────────────────
  final RxString paymentMethod = PaymentMethod.cash.obs;
  final RxBool isSubmitting = false.obs;

  // ── Active booking (tracking page) ───────────────────────────
  final Rxn<BookingDocument> activeBooking = Rxn();
  StreamSubscription? _activeSub;

  // ── Booking history ───────────────────────────────────────────
  final RxList<BookingDocument> bookingHistory = <BookingDocument>[].obs;
  final RxBool isLoadingHistory = true.obs;
  StreamSubscription? _historySub;

  @override
  void onInit() {
    super.onInit();
    _loadTechnicianFromArguments();
    _initUserStreams();
  }

  @override
  void onClose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    super.onClose();
  }

  // ── Init ──────────────────────────────────────────────────────

  void _loadTechnicianFromArguments() {
    final args = Get.arguments;
    if (args is TechnicianOnlineModel) {
      selectedTechnician.value = args;
    }
  }

  Future<void> _initUserStreams() async {
    int retry = 0;
    while (_authService.currentUser == null && retry < 6) {
      await Future.delayed(const Duration(milliseconds: 500));
      retry++;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    // Listen to active booking
    _activeSub = _bookingService.streamActiveBooking(uid).listen(
      (doc) => activeBooking.value = doc,
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
      reviews: const [],
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
  void setScheduledAt(DateTime value) => scheduledAt.value = value;

  bool get isFormValid =>
      description.value.trim().isNotEmpty && userAddress.value.trim().isNotEmpty;

  /// Deteksi lokasi GPS customer — simpan lat/lng, tidak menggantikan teks alamat.
  Future<void> detectGpsLocation() async {
    isDetectingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Mati', 'Aktifkan layanan lokasi di pengaturan perangkat',
            snackPosition: SnackPosition.BOTTOM);
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
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      Get.snackbar('Lokasi Terdeteksi', 'Koordinat GPS berhasil disimpan',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      debugPrint('GPS error: $e');
      Get.snackbar('Gagal', 'Tidak bisa mendapatkan lokasi GPS',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetectingLocation.value = false;
    }
  }

  // ── Checkout Page ─────────────────────────────────────────────

  void setPaymentMethod(String method) => paymentMethod.value = method;

  /// Map ke CheckoutSummary untuk UI checkout page.
  CheckoutSummary get checkoutData {
    final t = selectedTechnician.value;
    final estimates = t?.serviceEstimates ?? [];
    final minPrice = estimates.isNotEmpty ? estimates.first.minPrice : 0;

    return CheckoutSummary(
      currentRepairTitle: _damageTypeLabel(damageType.value),
      scheduledForLabel:
          'Jadwal: ${_formatDate(scheduledAt.value)}',
      paymentMethod: _mapPaymentType(paymentMethod.value),
      paymentOptions: const [
        PaymentOption(
          type: PaymentMethodType.wallet,
          title: 'Bayar Tunai',
          subtitle: 'Bayar langsung ke teknisi di lokasi',
        ),
      ],
      serviceFee: minPrice.toDouble(),
      partsLabel: 'Estimasi biaya (bisa berubah)',
      partsFee: 0,
      taxFee: 0,
    );
  }

  // ── Submit Booking ────────────────────────────────────────────

  Future<void> submitBooking() async {
    if (!isFormValid) {
      Get.snackbar('Oops', 'Deskripsi keluhan tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Sesi habis, silakan login ulang',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final tech = selectedTechnician.value;
    if (tech == null) {
      Get.snackbar('Error', 'Data teknisi tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;

    try {
      final userModel = await _authService.getUserModel(user.uid);
      final estimatedPrice = tech.serviceEstimates.isNotEmpty
          ? tech.serviceEstimates.first.minPrice
          : 0;

      final bookingId = await _bookingService.createBooking(
        userId: user.uid,
        userName: userModel?.name ?? user.email ?? 'Customer',
        technicianId: tech.uid,
        technicianName: tech.name,
        technicianPhotoUrl: tech.photoUrl,
        category: tech.category,
        description: description.value.trim(),
        damageType: damageType.value,
        scheduledAt: scheduledAt.value,
        estimatedPrice: estimatedPrice,
        userAddress: userAddress.value.trim(),
        paymentMethod: paymentMethod.value,
        latitude: latitude.value,
        longitude: longitude.value,
      );

      debugPrint('Booking created: $bookingId');

      // Navigate ke tracking page (replace checkout dari stack)
      Get.offNamed(AppRoutes.orderTracking);
    } catch (e) {
      Get.snackbar('Gagal membuat booking', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
        title: 'Booking Dikonfirmasi',
        subtitle: 'Teknisi dalam perjalanan ke lokasi',
        isComplete: isOnProgress || isDone,
        isCurrent: isConfirmed,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.verification,
        title: 'Verifikasi Kode',
        subtitle: 'Tunjukkan kode ke teknisi saat tiba',
        isComplete: isOnProgress || isDone,
        isCurrent: isConfirmed,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.inProgress,
        title: 'Pengerjaan Berlangsung',
        subtitle: '',
        isComplete: isDone,
        isCurrent: isOnProgress,
      ),
      TrackingStatusStep(
        step: OrderStatusStep.completed,
        title: 'Selesai',
        subtitle: '',
        isComplete: isDone,
        isCurrent: isDone,
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
        _ => OrderHistoryStatus.success,
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
