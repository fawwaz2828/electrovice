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

  /// Teknisi tandai pekerjaan selesai → status `done`.
  Future<void> markAsDone(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel booking.
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
