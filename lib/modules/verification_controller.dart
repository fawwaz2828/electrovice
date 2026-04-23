import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String? phone;
  final TechnicianProfile? technicianProfile;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
    this.technicianProfile,
    this.createdAt,
  });

  bool get isTechnician => role == 'technician';

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'customer',
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      technicianProfile: map['technicianProfile'] != null
          ? TechnicianProfile.fromMap(
              map['technicianProfile'] as Map<String, dynamic>)
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phone != null) 'phone': phone,
      if (technicianProfile != null)
        'technicianProfile': technicianProfile!.toMap(),
    };
  }
}

class TechnicianProfile {
  final String category;
  final String bio;
  final String specialty;
  final double rating;
  final int totalRatings;
  final int totalJobs;
  final int yearsExperience;
  final int successRate;
  final double serviceRadius;
  final bool isAvailable;
  final String? photoUrl;

  const TechnicianProfile({
    required this.category,
    required this.bio,
    required this.specialty,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalJobs = 0,
    this.yearsExperience = 0,
    this.successRate = 100,
    this.serviceRadius = 10,
    this.isAvailable = false,
    this.photoUrl,
  });

  factory TechnicianProfile.fromMap(Map<String, dynamic> map) {
    return TechnicianProfile(
      category: map['category'] as String? ?? 'electronic',
      bio: map['bio'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (map['totalRatings'] as num?)?.toInt() ?? 0,
      totalJobs: (map['totalJobs'] as num?)?.toInt() ?? 0,
      // yearsExperience may be stored as String (RxString from onboarding) or int
      yearsExperience: _parseInt(map['yearsExperience']),
      successRate: _parseInt(map['successRate'], fallback: 100),
      serviceRadius: (map['serviceRadius'] as num?)?.toDouble() ?? 10,
      isAvailable: map['isAvailable'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v is num) return v.toInt();
    if (v is String) {
      // Direct parse first (e.g. "5")
      final direct = int.tryParse(v);
      if (direct != null) return direct;
      // Handle range strings: '<1yr' → 0, '1-2yr' → 1, '3-5yr' → 3, '5yr+' → 5
      final match = RegExp(r'(\d+)').firstMatch(v);
      if (match != null) return int.parse(match.group(1)!);
      return fallback;
    }
    return fallback;
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'bio': bio,
      'specialty': specialty,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalJobs': totalJobs,
      'yearsExperience': yearsExperience,
      'successRate': successRate,
      'serviceRadius': serviceRadius,
      'isAvailable': isAvailable,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  // Default kosong untuk teknisi baru — TIDAK ada data palsu
  factory TechnicianProfile.empty(String category) {
    return TechnicianProfile(
      category: category,
      bio: '',
      specialty: '',
    );
  }
}