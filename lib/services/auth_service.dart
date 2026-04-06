import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': email,
            'name': name,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
        });
        // await _auth.signOut(); // User stays logged in
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

        // Cek apakah user sudah ada di Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
            isNew = true;
            // User baru via Google — simpan ke Firestore
            await _firestore.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'email': user.email,
                'name': user.displayName ?? 'User',
                'role': role,
                'createdAt': FieldValue.serverTimestamp(),
            });
        }

        return { 'user': user, 'isNew': isNew };
    }



    Future<void> logout() async {
        try {
            await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
        await _auth.signOut();
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