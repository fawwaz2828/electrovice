import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    User? get currentUser => _auth.currentUser;
    Stream<User?> get authStateChanges => _auth.authStateChanges();

    // Register email/password
    Future<User?> registerWithEmail({
        required String email,
        required String password,
        required String role,
        required String name,
    }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
    );
    final user = credential.user!;

    final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
    };

    // Jika teknisi, langsung buat technicianProfile kosong
    if (role == 'technician') {
        userData['technicianProfile'] = {
        'category': 'electronic', // default, bisa diubah di profile setup
        'bio': '',
        'specialty': '',
        'rating': 0.0,
        'totalRatings': 0,
        'totalJobs': 0,
        'yearsExperience': 0,
        'successRate': 100,
        'serviceRadius': 10.0,
        'isAvailable': false,
        };
    }

    await _firestore.collection('users').doc(user.uid).set(userData);

    // Buat dokumen awal di technicians_online agar profile edit bisa langsung dipakai
    if (role == 'technician') {
      await _firestore.collection('technicians_online').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'specialty': '',
        'category': 'electronic',
        'isAvailable': false,
        'workshopAddress': '',
        'accreditations': [],
        'serviceEstimates': [],
        'serviceRadius': 10.0,
        'rating': 0.0,
        'totalJobs': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
    }

    // Login email/password
    Future<User?> loginWithEmail({
        required String email,
        required String password,
    }) async {
        final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
        );
        return credential.user;
    }

    // Google Sign-In
    Future<Map<String, dynamic>?> signInWithGoogle({String role = 'customer'}) async {
        await _googleSignIn.signOut();

        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user!;
        bool isNew = false;

        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
            isNew = true;

            final Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? 'User',
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
            };

            if (role == 'technician') {
                userData['technicianProfile'] = {
                    'category': 'electronic',
                    'bio': '',
                    'specialty': '',
                    'rating': 0.0,
                    'totalRatings': 0,
                    'totalJobs': 0,
                    'yearsExperience': 0,
                    'successRate': 100,
                    'serviceRadius': 10.0,
                    'isAvailable': false,
                };
            }

            await _firestore.collection('users').doc(user.uid).set(userData);

            // Buat dokumen awal di technicians_online
            if (role == 'technician') {
              await _firestore.collection('technicians_online').doc(user.uid).set({
                'uid': user.uid,
                'name': user.displayName ?? 'User',
                'specialty': '',
                'category': 'electronic',
                'isAvailable': false,
                'workshopAddress': '',
                'accreditations': [],
                'serviceEstimates': [],
                'serviceRadius': 10.0,
                'rating': 0.0,
                'totalJobs': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
        }
        return {'user': user, 'isNew': isNew};
    }

    // Tambah method baru — fetch sebagai UserModel
    Future<UserModel?> getUserModel(String uid) async {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromMap(uid, doc.data()!);
    }

    Future<void> logout() async {
        await _auth.signOut();        // Firebase dulu
        await _googleSignIn.signOut(); // Hapus sesi Google
        // disconnect() tidak perlu — cukup signOut
    }

    Future<void> updateUserProfile(
      String uid, {
      required String name,
      required String phone,
    }) async {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    Future<String?> getUserRole(String uid) async {
        final doc = await _firestore.collection('users').doc(uid).get();
        return doc.data()?['role'];
    }

    Future<Map<String, dynamic>?> getUserData(String uid) async {
        final doc = await _firestore.collection('users').doc(uid).get();
        return doc.data();
    }
}