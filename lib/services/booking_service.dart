import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_document.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Create ─────────────────────────────────────────────────────
  /// Buat booking baru (cash only untuk MVP).
  /// Status langsung `confirmed` + generate kode 6 digit.
  /// Buat booking baru → status langsung `pending` (menunggu teknisi accept).
  /// Kode verifikasi belum digenerate di sini — dibuat saat teknisi accept.
  Future<String> createBooking({
    required String userId,
    required String userName,
    required String technicianId,
    required String technicianName,
    String? technicianPhotoUrl,
    required String category,
    required String description,
    required String damageType,
    required DateTime scheduledAt,
    required int estimatedPrice,
    String userAddress = '',
    String paymentMethod = PaymentMethod.cash,
    double? latitude,
    double? longitude,
  }) async {
    final ref = _db.collection('bookings').doc();
    final now = DateTime.now();

    final booking = BookingDocument(
      bookingId: ref.id,
      userId: userId,
      userName: userName,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianPhotoUrl: technicianPhotoUrl,
      category: category,
      description: description,
      damageType: damageType,
      scheduledAt: scheduledAt,
      paymentMethod: paymentMethod,
      estimatedPrice: estimatedPrice,
      userAddress: userAddress,
      verificationCode: null,   // belum digenerate
      codeExpiryAt: null,
      status: BookingStatus.pending,
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(booking.toFirestore());
    return ref.id;
  }

  /// Teknisi accept order → status `confirmed` + generate kode verifikasi.
  Future<void> acceptBooking(String bookingId) async {
    final code = _generateCode();
    final expiry = DateTime.now().add(const Duration(hours: 2));
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.confirmed,
      'verificationCode': code,
      'codeExpiryAt': Timestamp.fromDate(expiry),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Teknisi decline order → status `cancelled`.
  Future<void> declineBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Streams ────────────────────────────────────────────────────

  /// Stream booking aktif customer (status: pending / confirmed / on_progress).
  Stream<BookingDocument?> streamActiveBooking(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.onProgress,
          BookingStatus.awaitingPayment,
          BookingStatus.done, // include done agar tracking page bisa tampil review banner
        ])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : BookingDocument.fromFirestore(snap.docs.first));
  }

  /// Stream riwayat booking customer (semua status).
  Stream<List<BookingDocument>> streamCustomerHistory(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BookingDocument.fromFirestore).toList());
  }

  /// Stream incoming orders untuk teknisi (status: pending / confirmed / on_progress).
  Stream<List<BookingDocument>> streamTechnicianOrders(String technicianId) {
    return _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', whereIn: [
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.onProgress,
          BookingStatus.awaitingPayment,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(BookingDocument.fromFirestore).toList());
  }

  /// Stream satu booking berdasarkan ID (untuk tracking page).
  Stream<BookingDocument?> streamBookingById(String bookingId) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .map((snap) => snap.exists ? BookingDocument.fromFirestore(snap) : null);
  }

  // ── Actions ────────────────────────────────────────────────────

  /// Teknisi verifikasi kode 6 digit → status jadi `on_progress`.
  Future<void> verifyCode(String bookingId, String enteredCode) async {
    final snap = await _db.collection('bookings').doc(bookingId).get();
    if (!snap.exists) throw Exception('Booking tidak ditemukan');

    final booking = BookingDocument.fromFirestore(snap);

    if (booking.status != BookingStatus.confirmed) {
      throw Exception('Booking tidak dalam status confirmed');
    }
    if (booking.verificationCode != enteredCode) {
      throw Exception('Kode verifikasi salah');
    }
    if (booking.isCodeExpired) {
      throw Exception('Kode sudah kadaluarsa');
    }

    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.onProgress,
      'codeVerifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Teknisi submit harga final → status `awaiting_payment`.
  Future<void> submitFinalPrice({
    required String bookingId,
    required int serviceFee,
    required List<Map<String, dynamic>> spareParts,
    required String note,
    required int totalAmount,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'finalServiceFee': serviceFee,
      'finalSpareParts': spareParts,
      'finalNote': note,
      'finalTotalAmount': totalAmount,
      'status': BookingStatus.awaitingPayment,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Customer konfirmasi pembayaran tunai → status `done`.
  Future<void> confirmPayment(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Teknisi tandai pekerjaan selesai → status `done`.
  Future<void> markAsDone(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Customer submit ulasan & rating (1–5 bintang).
  /// Otomatis recalculate rata-rata rating teknisi.
  Future<void> submitReview({
    required String bookingId,
    required String technicianId,
    required int rating,
    String review = '',
    bool recommend = true,
  }) async {
    // 1. Simpan rating ke booking doc
    await _db.collection('bookings').doc(bookingId).update({
      'customerRating': rating,
      'customerReview': review,
      'customerRecommend': recommend,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Recalculate rating rata-rata teknisi dari semua booking yang sudah dirating
    final snap = await _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: BookingStatus.done)
        .get();

    final rated = snap.docs
        .where((d) => d['customerRating'] != null)
        .toList();

    if (rated.isEmpty) return;

    final avg = rated
            .map((d) => (d['customerRating'] as num).toDouble())
            .reduce((a, b) => a + b) /
        rated.length;

    await _db.collection('technicians').doc(technicianId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'totalRatings': rated.length,
    });
  }

  /// Cancel booking.
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ambil ulasan terbaru untuk teknisi (dari booking done yang sudah dirating).
  Future<List<BookingDocument>> fetchTechnicianReviews(
      String technicianId) async {
    final snap = await _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: BookingStatus.done)
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .get();
    return snap.docs
        .map(BookingDocument.fromFirestore)
        .where((b) => b.customerRating != null)
        .toList();
  }

  /// Ambil riwayat order selesai (done) milik teknisi tertentu.
  Future<List<BookingDocument>> fetchDoneOrders(String technicianId) async {
    final snap = await _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: BookingStatus.done)
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(BookingDocument.fromFirestore).toList();
  }

  /// Ambil jam-jam yang sudah terisi untuk teknisi di tanggal tertentu.
  /// Menggunakan index yang sudah ada (technicianId + status whereIn).
  /// Filter tanggal dilakukan client-side untuk menghindari index baru.
  Future<List<int>> fetchOccupiedHours(
    String technicianId,
    DateTime date,
  ) async {
    final snap = await _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', whereIn: [
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.onProgress,
          BookingStatus.awaitingPayment,
        ])
        .get();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return snap.docs
        .where((d) {
          final ts = d['scheduledAt'];
          if (ts == null) return false;
          final dt = (ts as Timestamp).toDate();
          return dt.isAfter(startOfDay) && dt.isBefore(endOfDay);
        })
        .map((d) => ((d['scheduledAt'] as Timestamp).toDate()).hour)
        .toList();
  }

  // ── Helper ─────────────────────────────────────────────────────
  String _generateCode() {
    final rand = Random.secure();
    return (100000 + rand.nextInt(900000)).toString();
  }
}
