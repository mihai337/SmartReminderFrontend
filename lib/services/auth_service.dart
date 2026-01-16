import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartreminders/models/user.dart' as models;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<models.User?> loginWithGoogle() async {
    try {
      UserCredential userCredential;
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      if (kIsWeb) {
        // For web, use popup
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // For mobile, use redirect which will be handled by the OS

        // TODO: Implement proper Google Sign-In flow for mobile platforms
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: "test@gmail.com", password: "asdasd");
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final now = DateTime.now();
        final user = models.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          createdAt: now,
          updatedAt: now,
        );

        // await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
        return user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<models.User?> getCurrentUserData() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) return null;

    // final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    // if (doc.exists) {
    //   return models.User.fromJson(doc.data()!);
    // }
    return null;
  }
}
