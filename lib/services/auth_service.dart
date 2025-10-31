import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartreminders/models/user.dart' as models;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<models.User?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
        // For web, use popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // For mobile, use redirect which will be handled by the OS
        // GoogleAuthProvider googleProvider = GoogleAuthProvider();
        // await _firebaseAuth.signInWithRedirect(googleProvider);
        var userC = {
          "kind": "identitytoolkit#VerifyPasswordResponse",
          "localId": "9VQ8UDZaVGN6FJu4sahI0ABwtYJ3",
          "email": "test@gmail.com",
          "displayName": "",
          "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU0NTEzMjA5OWFkNmJmNjEzODJiNmI0Y2RlOWEyZGZlZDhjYjMwZjAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vc21hcnRyZW1pbmRlci05Y2NjMyIsImF1ZCI6InNtYXJ0cmVtaW5kZXItOWNjYzMiLCJhdXRoX3RpbWUiOjE3NjE5NTM5MTEsInVzZXJfaWQiOiI5VlE4VURaYVZHTjZGSnU0c2FoSTBBQnd0WUozIiwic3ViIjoiOVZROFVEWmFWR042Rkp1NHNhaEkwQUJ3dFlKMyIsImlhdCI6MTc2MTk1MzkxMSwiZXhwIjoxNzYxOTU3NTExLCJlbWFpbCI6InRlc3RAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInRlc3RAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.XXbV3VW1sxcnVPtzaToSs5Bk_qDWy-GFeMJW2QdnfZBzVfDlT3JUNatblH9U5D0i6oAwIVMMuT4XpMlfvDdZk9ROhlqCtbZ2MZ5nUTAnWasLAh36qGD4ybN6WMmmCb3NBR8INR_jt6pq05Hd0n6Ny3e3HAagZI9zPlKuuvFQRXRU627fbTp0odCWM5xfKUVDhmyvcffJtkK-hh4z_TofnjTE5jdydU3MKt9WxgG1nHp6F7ALy6ZBHOlmK68RTShG0WYFFjsJmmdFZ2oTAu66UXOAKVUVMBJNDKoO3DRcBH09SBv2MkzQ4aWhthD67XBcVlTh-l3ENIk3i-2b6_xNcQ",
          "registered": true,
          "refreshToken": "AMf-vBxJxSCjre5dgRpoPkyoQi2ET_6i2v3og2W88TOFsWOGfbGtlHi4sSGKqNgHzfMZQDRzc6qYXCTtxfRpmLdtY10ACRuxuu9bkU5D8vXJMuBBorvlctAbeiBP6aH1U2tKHDd_GWOTfwKWEMkB492K4v92XDOS527cMlU7V0weJ-_vbO6n1B2HnrGuTEFl09sqv6JW-SvrtAsceYvuSQn2x7sjcUVTAw",
          "expiresIn": "3600"
        };
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: "test@gmail.com", password: "asdasd");
        // userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
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

        await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
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

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return models.User.fromJson(doc.data()!);
    }
    return null;
  }
}
