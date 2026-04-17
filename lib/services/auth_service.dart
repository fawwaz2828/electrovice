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

    // Buat user doc minimal — onboarding teknisi akan mengisi sisanya
    final Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(userData);

    // technicians_online & technicianProfile dibuat setelah onboarding selesai

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

            // User doc minimal — onboarding teknisi akan mengisi sisanya
            final Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? 'User',
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
            };

            await _firestore.collection('users').doc(user.uid).set(userData);
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

    Future<void> updateUserPhoto(String uid, String photoUrl) async {
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
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