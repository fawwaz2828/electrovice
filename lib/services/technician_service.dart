import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class TechnicianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── UPDATE PROFILE (update ke 2 collection sekaligus) ──────────
  Future<void> updateTechnicianProfile(
    String uid, {
    required String name,
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
    required List<Map<String, dynamic>> serviceEstimates,
  }) async {
    final GeoFirePoint point = GeoFirePoint(GeoPoint(lat, lng));

    // Update collection users
    await _firestore.collection('users').doc(uid).update({
      'name': name,
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
      'serviceEstimates': serviceEstimates,
      'serviceRadius': serviceRadius,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // merge: true supaya rating & totalJobs tidak tertimpa
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
    final collection = _firestore.collection('technicians_online');
    final geoRef = GeoCollectionReference<Map<String, dynamic>>(collection);
    final center = GeoFirePoint(GeoPoint(lat, lng));

    final snapshots = await geoRef.fetchWithin(
      center: center,
      radiusInKm: radiusKm,
      field: 'location',
      geopointFrom: (data) =>
          (data['location']['geopoint'] as GeoPoint),
      strictMode: true,
    );

    List<TechnicianOnlineModel> result = snapshots
        .where((doc) => doc.data() != null)
        .map((doc) {
          final data = doc.data()!;
          final GeoPoint geopoint =
              data['location']['geopoint'] as GeoPoint;
          final double distanceKm = Geolocator.distanceBetween(
                lat, lng,
                geopoint.latitude, geopoint.longitude,
              ) / 1000;
          return TechnicianOnlineModel.fromMap(data,
              distanceKm: distanceKm);
        })
        .toList();

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
    return TechnicianOnlineModel.fromMap(doc.data()!);
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
  final List<ServiceEstimate> serviceEstimates;

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
    required this.serviceEstimates,
    this.photoUrl,
  });

  factory TechnicianOnlineModel.fromMap(
    Map<String, dynamic> map, {
    double distanceKm = 0,
  }) {
    final List<String> accreditations =
        (map['accreditations'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    final List<ServiceEstimate> estimates =
        (map['serviceEstimates'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((e) => ServiceEstimate.fromMap(
                Map<String, dynamic>.from(e)))
            .toList();

    return TechnicianOnlineModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      category: map['category'] as String? ?? 'electronic',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalJobs: (map['totalJobs'] as num?)?.toInt() ?? 0,
      yearsExperience: (map['yearsExperience'] as num?)?.toInt() ?? 0,
      isAvailable: map['isAvailable'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      workshopAddress: map['workshopAddress'] as String? ?? '',
      distanceKm: distanceKm,
      accreditations: accreditations,
      serviceEstimates: estimates,
    );
  }

  String get distanceLabel {
    if (distanceKm < 1) return '${(distanceKm * 1000).toInt()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

class ServiceEstimate {
  final String service;
  final int minPrice;
  final int maxPrice;

  const ServiceEstimate({
    required this.service,
    required this.minPrice,
    required this.maxPrice,
  });

  factory ServiceEstimate.fromMap(Map<String, dynamic> map) {
    return ServiceEstimate(
      service: map['service'] as String? ?? '',
      minPrice: (map['minPrice'] as num?)?.toInt() ?? 0,
      maxPrice: (map['maxPrice'] as num?)?.toInt() ?? 0,
    );
  }

  String get priceLabel {
    if (minPrice == maxPrice) return 'Dari Rp$minPrice';
    return 'Rp$minPrice - Rp$maxPrice';
  }
}