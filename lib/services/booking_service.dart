import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    String userPhone = '',
    required String technicianId,
    required String technicianName,
    String? technicianPhotoUrl,
    required String category,
    required String description,
    required String damageType,
    String serviceName = '',
    required DateTime scheduledAt,
    required int estimatedPrice,
    String userAddress = '',
    String paymentMethod = PaymentMethod.cash,
    double? latitude,
    double? longitude,
    List<String> damagePhotoUrls = const [],
  }) async {
    final ref = _db.collection('bookings').doc();
    final now = DateTime.now();

    final booking = BookingDocument(
      bookingId: ref.id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianPhotoUrl: technicianPhotoUrl,
      category: category,
      description: description,
      damageType: damageType,
      serviceName: serviceName,
      scheduledAt: scheduledAt,
      paymentMethod: paymentMethod,
      estimatedPrice: estimatedPrice,
      userAddress: userAddress,
      verificationCode: null,   // belum digenerate
      codeExpiryAt: null,
      status: BookingStatus.pending,
      latitude: latitude,
      longitude: longitude,
      damagePhotoUrls: damagePhotoUrls,
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(booking.toFirestore());

    // Notif ke teknisi dikirim oleh Cloud Function onBookingCreated
    // (client tidak boleh menulis ke notif milik user lain).

    return ref.id;
  }

  /// Teknisi accept order → status `confirmed` + generate kode verifikasi.
  Future<void> acceptBooking(String bookingId) async {
    final code = _generateCode();
    final expiry = DateTime.now().add(const Duration(hours: 24));
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.confirmed,
      'verificationCode': code,
      'codeExpiryAt': Timestamp.fromDate(expiry),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif ke customer dikirim oleh Cloud Function onBookingStatusChanged.
  }

  /// Teknisi decline order → status `cancelled`.
  Future<void> declineBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'cancelledBy': 'technician',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif dikirim oleh Cloud Function (onBookingStatusChanged)
    // yang membaca cancelledBy untuk bedakan declined vs cancelled.
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
    if (booking.isCodeExpired) {
      // Kode kadaluarsa → generate ulang agar customer bisa lihat kode baru
      final newCode = _generateCode();
      final newExpiry = DateTime.now().add(const Duration(hours: 24));
      await _db.collection('bookings').doc(bookingId).update({
        'verificationCode': newCode,
        'codeExpiryAt': Timestamp.fromDate(newExpiry),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      throw Exception('Kode sudah kadaluarsa dan telah diperbarui.\nMinta pelanggan lihat kode baru di halaman tracking.');
    }
    if (booking.verificationCode != enteredCode) {
      throw Exception('Kode verifikasi salah');
    }

    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.onProgress,
      'codeVerifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif ke customer dikirim oleh Cloud Function onBookingStatusChanged.
  }

  /// Teknisi submit harga final → status `awaiting_payment`.
  Future<void> submitFinalPrice({
    required String bookingId,
    required int serviceFee,
    required List<Map<String, dynamic>> spareParts,
    required String note,
    required int totalAmount,
    List<String> workPhotoUrls = const [],
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'finalServiceFee': serviceFee,
      'finalSpareParts': spareParts,
      'finalNote': note,
      'finalTotalAmount': totalAmount,
      'workPhotoUrls': workPhotoUrls,
      'status': BookingStatus.awaitingPayment,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif ke customer dikirim oleh Cloud Function onBookingStatusChanged.
  }

  /// Customer konfirmasi pembayaran tunai → status `done`.
  Future<void> confirmPayment(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif ke teknisi dikirim oleh Cloud Function onBookingStatusChanged.
  }

  /// Teknisi tandai pekerjaan selesai → status `done` + increment totalJobs.
  Future<void> markAsDone(String bookingId) async {
    final snap = await _db.collection('bookings').doc(bookingId).get();
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Increment totalJobs di technicians_online
    if (snap.exists) {
      final techId = snap.data()?['technicianId'] as String?;
      if (techId != null && techId.isNotEmpty) {
        await _db.collection('technicians_online').doc(techId).update({
          'totalJobs': FieldValue.increment(1),
        });
      }
    }
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
    // Customer hanya menyimpan rating ke booking miliknya — tidak lebih.
    // Kalkulasi rata-rata dan update technicians_online dilakukan sisi teknisi
    // via syncTechnicianStats() saat mereka membuka aplikasi.
    await _db.collection('bookings').doc(bookingId).update({
      'customerRating': rating,
      'customerReview': review,
      'customerRecommend': recommend,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hitung ulang rating rata-rata + totalJobs dari bookings teknisi,
  /// lalu sync ke technicians_online dan technicians.
  /// Harus dipanggil dari sisi TEKNISI (bukan customer) karena:
  ///   - teknisi punya izin query bookings miliknya sendiri
  ///   - teknisi punya izin tulis ke technicians_online/{uid} miliknya sendiri
  Future<void> syncTechnicianStats(String technicianId) async {
    try {
      // Query semua booking selesai milik teknisi ini
      final snap = await _db
          .collection('bookings')
          .where('technicianId', isEqualTo: technicianId)
          .where('status', isEqualTo: BookingStatus.done)
          .get();

      final totalJobs = snap.docs.length;

      final rated = snap.docs
          .where((d) => d['customerRating'] != null)
          .toList();

      final double avgRating = rated.isEmpty
          ? 0.0
          : rated
                  .map((d) => (d['customerRating'] as num).toDouble())
                  .reduce((a, b) => a + b) /
              rated.length;

      final roundedRating = double.parse(avgRating.toStringAsFixed(1));

      // Sortir rated desc by updatedAt, ambil 10 terbaru untuk snippets
      final ratedSorted = List.of(rated);
      ratedSorted.sort((a, b) {
        final aT = (a['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bT = (b['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bT.compareTo(aT);
      });
      final reviewSnippets = ratedSorted.take(10).map((d) => {
        'reviewerName': d['userName'] as String? ?? 'Pengguna',
        'rating': (d['customerRating'] as num?)?.toInt() ?? 0,
        'comment': d['customerReview'] as String? ?? '',
        'date': (d['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? '',
      }).toList();

      final statsData = {
        'rating': roundedRating,
        'totalRatings': rated.length,
        'totalJobs': totalJobs,
        'reviewSnippets': reviewSnippets,
      };

      // 1. technicians_online — tampilan di home/detail customer
      await _db
          .collection('technicians_online')
          .doc(technicianId)
          .set(statsData, SetOptions(merge: true));

      // 2. users.technicianProfile.rating — dibaca oleh TechnicianController
      //    untuk ditampilkan di halaman profil teknisi sendiri
      await _db.collection('users').doc(technicianId).update({
        'technicianProfile.rating': roundedRating,
        'technicianProfile.totalRatings': rated.length,
        'technicianProfile.totalJobs': totalJobs,
      });

      debugPrint(
          'syncTechnicianStats: rating=$roundedRating totalJobs=$totalJobs');
    } catch (e) {
      debugPrint('syncTechnicianStats error: $e');
    }
  }

  /// Update foto kerusakan setelah booking dibuat.
  Future<void> updateDamagePhotos(
      String bookingId, List<String> photoUrls) async {
    await _db.collection('bookings').doc(bookingId).update({
      'damagePhotoUrls': photoUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel booking.
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled,
      'cancelledBy': 'customer',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Notif ke teknisi dikirim oleh Cloud Function onBookingStatusChanged.
  }

  /// Ambil ulasan terbaru untuk teknisi (dari booking done yang sudah dirating).
  Future<List<BookingDocument>> fetchTechnicianReviews(
      String technicianId) async {
    final snap = await _db
        .collection('bookings')
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: BookingStatus.done)
        .get();
    final results = snap.docs
        .map(BookingDocument.fromFirestore)
        .where((b) => b.customerRating != null)
        .toList();
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results.take(10).toList();
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
