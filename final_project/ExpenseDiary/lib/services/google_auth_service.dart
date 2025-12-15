import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static Future<UserCredential> signInWithGoogle({
    required bool isRegister,
  }) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("Google sign-in cancelled");
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final uid = userCredential.user!.uid;
    final usersRef =
        FirebaseFirestore.instance.collection('users');
    final userDoc = await usersRef.doc(uid).get();

    // 🔐 LOGIN FLOW
    if (!isRegister && !userDoc.exists) {
      await FirebaseAuth.instance.signOut();
      throw Exception("User not registered");
    }

    // ❌ REGISTER with existing account
    if (isRegister && userDoc.exists) {
      await FirebaseAuth.instance.signOut();
      throw Exception("Account already exists. Please login.");
    }

    // 🆕 REGISTER FLOW
    if (isRegister && !userDoc.exists) {
      await usersRef.doc(uid).set({
        'email': userCredential.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }
}

