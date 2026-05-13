import 'package:cloud_firestore/cloud_firestore.dart';

/// Hasil ringkas dari operasi migrasi sertifikasi.
class MigrationResult {
  final int updated;
  final int seeded;
  final int deleted;

  const MigrationResult({
    this.updated = 0,
    this.seeded = 0,
    this.deleted = 0,
  });

  @override
  String toString() =>
      'updated=$updated, seeded=$seeded, deleted=$deleted';
}

/// One-shot utility untuk membersihkan data sertifikasi lama dan
/// menyiapkan data demo untuk fitur "Upgrade Certification".
///
/// Aman dipanggil berulang kali — operasi reset bersifat idempotent
/// dan seeding pakai `set(..., merge: true)` jadi tidak menimpa field
/// lain (rating, totalJobs, lokasi, dsb.) milik akun seed.
///
/// Dipanggil dari halaman admin (lihat [AdminHomePage] tombol
/// "Migrate certifications").
class CertificationMigrationService {
  CertificationMigrationService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _techCol = 'technicians_online';
  static const String _regCol = 'certification_registrations';

  /// Reset semua dokumen di `technicians_online`:
  ///   - `isCertified` → `false`
  ///   - `accreditations` → `[]`
  ///   - `certificationUrls` → `[]`
  ///
  /// Tidak menyentuh field lain. Memakai `WriteBatch` per 400 dokumen
  /// agar tetap di bawah limit Firestore (500 ops / batch).
  Future<int> resetAllCertifications() async {
    final snap = await _db.collection(_techCol).get();
    if (snap.docs.isEmpty) return 0;

    int processed = 0;
    final batches = <WriteBatch>[];
    WriteBatch current = _db.batch();
    int opsInBatch = 0;

    for (final doc in snap.docs) {
      current.set(
        doc.reference,
        {
          'isCertified': false,
          'accreditations': <String>[],
          'certificationUrls': <String>[],
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      opsInBatch++;
      processed++;
      if (opsInBatch >= 400) {
        batches.add(current);
        current = _db.batch();
        opsInBatch = 0;
      }
    }
    if (opsInBatch > 0) batches.add(current);

    for (final b in batches) {
      await b.commit();
    }
    return processed;
  }

  /// Hapus seluruh dokumen di koleksi `certification_registrations`.
  /// Dipakai untuk membersihkan pendaftaran lama saat migrasi.
  Future<int> deleteAllCertificationRegistrations() async {
    final snap = await _db.collection(_regCol).get();
    if (snap.docs.isEmpty) return 0;

    int deleted = 0;
    WriteBatch current = _db.batch();
    int opsInBatch = 0;
    final batches = <WriteBatch>[];

    for (final doc in snap.docs) {
      current.delete(doc.reference);
      opsInBatch++;
      deleted++;
      if (opsInBatch >= 400) {
        batches.add(current);
        current = _db.batch();
        opsInBatch = 0;
      }
    }
    if (opsInBatch > 0) batches.add(current);

    for (final b in batches) {
      await b.commit();
    }
    return deleted;
  }

  /// Buat / update dua akun teknisi demo dengan `isCertified: true`
  /// dan satu entry di `certification_registrations` dengan
  /// `status: approved`.
  ///
  /// Dokumen `technicians_online` memakai doc ID `tech_001` & `tech_002`
  /// agar gampang di-reference dan terlihat di list customer.
  Future<int> seedDemoCertifiedTechnicians() async {
    final demos = <Map<String, dynamic>>[
      {
        'uid': 'tech_001',
        'name': 'Andi Pratama',
        'specialty': 'Smartphone & Laptop Repair',
        'certificationType': 'LSP Digital/Computer Technician',
      },
      {
        'uid': 'tech_002',
        'name': 'Budi Santoso',
        'specialty': 'Automotive Electrical & EV',
        'certificationType': 'LSP Automotive Technician',
      },
    ];

    int seeded = 0;
    for (final d in demos) {
      final uid = d['uid'] as String;

      // 1. Upsert dokumen teknisi
      await _db.collection(_techCol).doc(uid).set({
        'uid': uid,
        'name': d['name'],
        'specialty': d['specialty'],
        'category': 'electronic',
        'isAvailable': true,
        'isOnline': true,
        'isCertified': true,
        'rating': 4.8,
        'totalJobs': 25,
        'yearsExperience': 5,
        'workshopAddress': 'Jakarta, Indonesia',
        'deviceCategories': uid == 'tech_001'
            ? ['laptop', 'smartphone']
            : ['vehicle'],
        'serviceMethod': const ['pickup', 'dropoff'],
        'accreditations': [d['certificationType']],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Sample registration record (status: approved) — id deterministik
      // sehingga seed berulang tidak membuat duplikat.
      await _db
          .collection(_regCol)
          .doc('demo_$uid')
          .set({
        'uid': uid,
        'fullName': d['name'],
        'nik': '32710012340000${seeded + 1}',
        'phone': '+628123456789$seeded',
        'birthPlace': 'Jakarta',
        'birthDate': Timestamp.fromDate(DateTime(1995, 1, 1)),
        'address': 'Jl. Demo No. ${seeded + 1}, Jakarta',
        'certificationType': d['certificationType'],
        'examDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 30))),
        'paymentMethod': 'Bank Transfer',
        'totalCost': 525000,
        'status': 'approved',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      seeded++;
    }
    return seeded;
  }

  /// Konvensi pemanggilan paling umum: bersihkan semua → seed demo.
  Future<MigrationResult> runFullMigration() async {
    final deleted = await deleteAllCertificationRegistrations();
    final updated = await resetAllCertifications();
    final seeded = await seedDemoCertifiedTechnicians();
    return MigrationResult(
        updated: updated, seeded: seeded, deleted: deleted);
  }
}
