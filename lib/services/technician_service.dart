import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class TechnicianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── UPDATE PROFILE (update ke 2 collection sekaligus) ──────────
  Future<void> updateTechnicianProfile(
    String uid, {
    required String name,
    String phone = '',
    required String category,
    required String specialty,
    required String bio,
    required int yearsExperience,
    required double serviceRadius,
    required bool isAvailable,
    required String workshopAddress,
    required double lat,
    required double lng,
    required List<String> accreditations,
    List<String> certificationUrls = const [],
    required List<Map<String, dynamic>> serviceEstimates,
    int diagnosisFee = 0,
  }) async {
    final GeoFirePoint point = GeoFirePoint(GeoPoint(lat, lng));

    // Update collection users
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      if (phone.isNotEmpty) 'phone': phone,
      'technicianProfile.category': category,
      'technicianProfile.specialty': specialty,
      'technicianProfile.bio': bio,
      'technicianProfile.yearsExperience': yearsExperience,
      'technicianProfile.serviceRadius': serviceRadius,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update collection technicians_online
    await _firestore.collection('technicians_online').doc(uid).set({
      'uid': uid,
      'name': name,
      'specialty': specialty,
      'category': category,
      'isAvailable': isAvailable,
      'workshopAddress': workshopAddress,
      'location': point.data,
      'accreditations': accreditations,
      'certificationUrls': certificationUrls,
      'serviceEstimates': serviceEstimates,
      'serviceRadius': serviceRadius,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // merge: true supaya rating & totalJobs tidak tertimpa
  }

  // ── UPDATE WORKSHOP ADDRESS ONLY ──────────────────────────────
  Future<void> updateWorkshopAddress({
    required String uid,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final GeoFirePoint point = GeoFirePoint(GeoPoint(lat, lng));
    await _firestore.collection('technicians_online').doc(uid).set({
      'workshopAddress': address,
      'location': point.data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Also update users collection
    await _firestore.collection('users').doc(uid).update({
      'technicianProfile.workshopAddress': address,
      'technicianProfile.latitude': lat,
      'technicianProfile.longitude': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── GET CURRENT LOCATION ───────────────────────────────────────
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ── GET TECHNICIAN LIST ────────────────────────────────────────
  Future<List<TechnicianOnlineModel>> getTechnicianList({
    required double lat,
    required double lng,
    double radiusKm = 10,
    String? category,
  }) async {
    List<TechnicianOnlineModel> result = [];

    // ── 1. Try geo-query (requires correct geohash in location field)
    try {
      final collection = _firestore.collection('technicians_online');
      final geoRef = GeoCollectionReference<Map<String, dynamic>>(collection);
      final center = GeoFirePoint(GeoPoint(lat, lng));

      final snapshots = await geoRef.fetchWithin(
        center: center,
        radiusInKm: radiusKm,
        field: 'location',
        geopointFrom: (data) => (data['location']['geopoint'] as GeoPoint),
        strictMode: false, // false = bounding box saja, lebih toleran
      );

      result = snapshots
          .where((doc) => doc.data() != null)
          .where((doc) => doc.data()!['isOnline'] != false)
          .map((doc) {
            final data = doc.data()!;
            double distKm = 0;
            try {
              final GeoPoint gp = data['location']['geopoint'] as GeoPoint;
              distKm = Geolocator.distanceBetween(
                    lat, lng, gp.latitude, gp.longitude) /
                  1000;
            } catch (_) {}
            return TechnicianOnlineModel.fromMap(data,
                distanceKm: distKm, injectDiagnosa: true);
          })
          .toList();
    } catch (_) {}

    // ── 2. Fallback: fetch semua dokumen jika geo-query gagal / kosong
    if (result.isEmpty) {
      final snapshot = await _firestore
          .collection('technicians_online')
          .get();

      result = snapshot.docs
          .where((d) => d.data().isNotEmpty)
          .where((d) => d.data()['isOnline'] != false)
          .map((d) {
            final data = d.data();
            double distKm = 0;
            try {
              final loc = data['location'];
              if (loc is Map) {
                final gp = loc['geopoint'] as GeoPoint;
                distKm = Geolocator.distanceBetween(
                        lat, lng, gp.latitude, gp.longitude) /
                    1000;
              }
            } catch (_) {}
            return TechnicianOnlineModel.fromMap(data,
                distanceKm: distKm, injectDiagnosa: true);
          })
          .toList();
    }

    if (category != null && category.isNotEmpty) {
      result = result.where((t) => t.category == category).toList();
    }

    result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return result;
  }

  // ── GET TECHNICIAN DETAIL ──────────────────────────────────────
  Future<TechnicianOnlineModel?> getTechnicianDetail(String uid) async {
    final doc = await _firestore
        .collection('technicians_online')
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return TechnicianOnlineModel.fromMap(doc.data()!, injectDiagnosa: true);
  }

  // ── INJECT DIAGNOSA HELPER ─────────────────────────────────────
  static List<ServiceEstimate> _withDiagnosa(
    List<ServiceEstimate> list,
    int diagFee,
  ) {
    if (diagFee <= 0) return list;
    final hasDiagnosa = list.any(
      (s) => s.service.toLowerCase().contains('diagnosa'),
    );
    if (hasDiagnosa) return list;
    return [
      ServiceEstimate(
        service: 'Diagnosa',
        minPrice: diagFee,
        maxPrice: diagFee,
        description:
            'Pemeriksaan awal kondisi perangkat untuk menentukan kerusakan dan estimasi biaya perbaikan.',
        duration: 'same_day',
      ),
      ...list,
    ];
  }

  // ── SERVICE ESTIMATE CRUD ───────────────────────────────────────

  /// Load daftar service dari technicians_online/{uid}.
  /// Diagnosa selalu disertakan di posisi pertama jika diagnosisFee > 0
  /// dan belum ada service bernama "Diagnosa" di dalam list.
  Future<List<ServiceEstimate>> getServiceEstimates(String uid) async {
    final doc = await _firestore
        .collection('technicians_online')
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return [];

    final data = doc.data()!;
    final raw  = data['serviceEstimates'] as List<dynamic>? ?? [];
    final list = raw
        .whereType<Map>()
        .map((e) => ServiceEstimate.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final diagFee = (data['diagnosisFee'] as num?)?.toInt() ?? 0;
    return _withDiagnosa(list, diagFee);
  }

  /// Simpan seluruh list service (replace all)
  Future<void> saveServiceEstimates(
      String uid, List<ServiceEstimate> estimates) async {
    await _firestore.collection('technicians_online').doc(uid).set(
      {'serviceEstimates': estimates.map((e) => e.toMap()).toList()},
      SetOptions(merge: true),
    );
  }
}

// ── MODELS ────────────────────────────────────────────────────────

class TechnicianOnlineModel {
  final String uid;
  final String name;
  final String specialty;
  final String category;
  final double rating;
  final int totalJobs;
  final int yearsExperience;
  final bool isAvailable;
  final String? photoUrl;
  final String workshopAddress;
  final double distanceKm;
  final List<String> accreditations;
  final List<String> certificationUrls; // foto sertifikat
  final List<ServiceEstimate> serviceEstimates;
  final int diagnosisFee;
  // Koordinat workshop — null jika belum pernah di-set
  final double? lat;
  final double? lng;

  const TechnicianOnlineModel({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.category,
    required this.rating,
    required this.totalJobs,
    required this.yearsExperience,
    required this.isAvailable,
    required this.workshopAddress,
    required this.distanceKm,
    required this.accreditations,
    required this.certificationUrls,
    required this.serviceEstimates,
    required this.diagnosisFee,
    this.photoUrl,
    this.lat,
    this.lng,
  });

  factory TechnicianOnlineModel.fromMap(
    Map<String, dynamic> map, {
    double distanceKm = 0,
    bool injectDiagnosa = false,
  }) {
    final List<String> accreditations =
        (map['accreditations'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            // Filter out accidental URLs stored by old onboarding
            .where((s) => !s.startsWith('http'))
            .toList();

    final List<String> certUrls =
        (map['certificationUrls'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    final diagFee = (map['diagnosisFee'] as num?)?.toInt() ?? 0;

    List<ServiceEstimate> estimates =
        (map['serviceEstimates'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((e) => ServiceEstimate.fromMap(
                Map<String, dynamic>.from(e)))
            .toList();

    if (injectDiagnosa) {
      estimates = TechnicianService._withDiagnosa(estimates, diagFee);
    }

    // Baca koordinat dari GeoFirePoint ('location.geopoint')
    double? lat;
    double? lng;
    final locationData = map['location'];
    if (locationData is Map) {
      final geopoint = locationData['geopoint'];
      if (geopoint is GeoPoint) {
        lat = geopoint.latitude;
        lng = geopoint.longitude;
      }
    }

    return TechnicianOnlineModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      category: map['category'] as String? ?? 'electronic',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: (map['totalJobs'] as num?)?.toInt() ?? 0,
      yearsExperience: _parseYearsExp(map['yearsExperience']),
      isAvailable: map['isAvailable'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      workshopAddress: map['workshopAddress'] as String? ?? '',
      distanceKm: distanceKm,
      accreditations: accreditations,
      certificationUrls: certUrls,
      serviceEstimates: estimates,
      diagnosisFee: diagFee,
      lat: lat,
      lng: lng,
    );
  }

  String get distanceLabel {
    if (distanceKm < 1) return '${(distanceKm * 1000).toInt()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

/// Parse yearsExperience yang mungkin disimpan sebagai String ('1-2yr', '<1yr', '5yr+')
/// atau sebagai num (int/double). Mengekstrak digit pertama dari string.
int _parseYearsExp(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) {
    final direct = int.tryParse(v);
    if (direct != null) return direct;
    final match = RegExp(r'(\d+)').firstMatch(v);
    if (match != null) return int.parse(match.group(1)!);
  }
  return 0;
}

class ServiceEstimate {
  final String service;
  final int minPrice;
  final int maxPrice;
  final String description;
  final String duration; // 'same_day' | '1-2_days' | '2-6_days'

  const ServiceEstimate({
    required this.service,
    required this.minPrice,
    required this.maxPrice,
    this.description = '',
    this.duration = 'same_day',
  });

  factory ServiceEstimate.fromMap(Map<String, dynamic> map) {
    return ServiceEstimate(
      service: map['service'] as String? ?? '',
      minPrice: (map['minPrice'] as num?)?.toInt() ?? 0,
      maxPrice: (map['maxPrice'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      duration: map['duration'] as String? ?? 'same_day',
    );
  }

  Map<String, dynamic> toMap() => {
        'service': service,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'description': description,
        'duration': duration,
      };

  String get durationLabel => switch (duration) {
        '1-2_days' => '1 - 2 Days',
        '2-6_days' => '2 - 6 Days',
        _ => 'Same day',
      };

  String get priceLabel {
    String _fmt(int v) {
      final s = v.toString();
      final buf = StringBuffer();
      int c = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (c > 0 && c % 3 == 0) buf.write('.');
        buf.write(s[i]);
        c++;
      }
      return 'Rp ${buf.toString().split('').reversed.join()}';
    }

    if (maxPrice <= 0) return '${_fmt(minPrice)}k +';
    if (minPrice == maxPrice) return _fmt(minPrice);
    return '${_fmt(minPrice)} - ${_fmt(maxPrice)}';
  }
}