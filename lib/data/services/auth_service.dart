import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth? _authInstance;
  final FirebaseFirestore? _firestoreInstance;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _authInstance = auth,
        _firestoreInstance = firestore;

  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  String? get currentUserId {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  String? get currentUserEmail {
    try {
      return _auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    String fName = firstName?.trim() ?? '';
    String lName = lastName?.trim() ?? '';

    if (fullName != null && fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      fName = parts.first;
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final computedFullName = [fName, lName].where((s) => s.isNotEmpty).join(' ');

    if (computedFullName.isNotEmpty && credential.user != null) {
      await credential.user!.updateDisplayName(computedFullName);
      await credential.user!.reload();
    }

    // Persist user record in Cloud Firestore for future uses
    if (credential.user != null) {
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'firstName': fName,
          'lastName': lName,
          'fullName': computedFullName,
          'email': email.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Non-blocking write so user registration is never aborted
      }
    }

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
