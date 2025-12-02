import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';

import 'email_auth.dart';
import 'google_auth.dart';
import 'apple_auth.dart';

class Authenticator {
  Authenticator({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _emailAuth = EmailAuth(firebaseAuth ?? FirebaseAuth.instance),
      _googleAuth = GoogleAuth(
        firebaseAuth ?? FirebaseAuth.instance,
        kIsWeb ? null : (googleSignIn ?? GoogleSignIn()),
      ),
      _appleAuth = AppleAuth(firebaseAuth ?? FirebaseAuth.instance);

  final FirebaseAuth _firebaseAuth;
  final EmailAuth _emailAuth;
  final GoogleAuth _googleAuth;
  final AppleAuth _appleAuth;

  bool get isAlreadyLoggedIn => _emailAuth.isAlreadyLoggedIn;

  UserId? get userId => _firebaseAuth.currentUser?.uid;

  Future<void> logOut() async {
    await _emailAuth.logOut();
    await _googleAuth.logOut();
  }

  // EMAIL/PASSWORD

  Future<AuthResult> loginWithEmailAndPassword(String email, String password) {
    return _emailAuth.loginWithEmailAndPassword(email, password);
  }

  Future<AuthResult> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) {
    return _emailAuth.registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  // GOOGLE

  Future<AuthResult> loginWithGoogle() {
    return _googleAuth.loginWithGoogle();
  }

  // APPLE

  Future<AuthResult> loginWithApple() {
    return _appleAuth.loginWithApple();
  }
}
