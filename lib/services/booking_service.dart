import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_document.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Create ─────────────────────────────────────────────────────
  /// Buat booking baru (cash only untuk MVP).
  /// Status langsung `confirmed` + generate kode 6 digit.
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
    String paymentMethod = PaymentMethod.cash,
  }) async {
    final ref = _db.collection('bookings').doc();
    final code = _generateCode();
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
      verificationCode: code,
      codeExpiryAt: now.add(const Duration(hours: 1)),
      status: BookingStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(booking.toFirestore());
    return ref.id;
  }

  // ── Streams ────────────────────────────────────────────────────

  /// Stream booking aktif customer (status: confirmed / on_progress).
  Stream<BookingDocument?> streamActiveBooking(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
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

  /// Stream incoming orders untuk teknisi (status: confirmed / on_progress).
  Stream<List<BookingDocument>> streamTechnicianOrders(String technicianId) {
    return _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', whereIn: [
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

  // ── Helper ─────────────────────────────────────────────────────
  String _generateCode() {
    final rand = Random.secure();
    return (100000 + rand.nextInt(900000)).toString();
  }
}
