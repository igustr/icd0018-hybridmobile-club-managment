import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';

class GoogleAuth {
  const GoogleAuth(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<AuthResult> loginWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await _firebaseAuth.signInWithPopup(provider);
        return AuthResult.success;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.aborted;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return AuthResult.success;
    } catch (_) {
      return AuthResult.failure;
    }
  }

  Future<void> logOut() async {
    await _googleSignIn.signOut();
  }
}
