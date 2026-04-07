import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateTechnicianProfile(
    String uid, {
    required String name,
    required String category,
    required String specialty,
    required String bio,
    required int yearsExperience,
    required double serviceRadius,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'technicianProfile.category': category,
      'technicianProfile.specialty': specialty,
      'technicianProfile.bio': bio,
      'technicianProfile.yearsExperience': yearsExperience,
      'technicianProfile.serviceRadius': serviceRadius,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}