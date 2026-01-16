import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smartreminders/services/api_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<bool> loginWithGoogle() async {
    try {
      UserCredential userCredential;
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      if (kIsWeb) {
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        //TODO: Implement mobile Google Sign-In flow for iOS
        userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
      }

      if (userCredential.user != null) {
        await _apiClient.post('/api/user',{})
            .then((resp) {
          if ((resp.statusCode < 200 || resp.statusCode >= 300) && resp.statusCode != 409) {
            throw Exception('Create user failed: ${resp.statusCode} ${resp.body}');
          }
        });
        return true;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
