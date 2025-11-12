import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';

class Authenticator {
  const Authenticator();

  bool get isAlreadyLoggedIn => userId != null;

  UserId? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  // Email + Password
  Future<AuthResult> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  // Google Authentication
  Future<AuthResult> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return AuthResult.aborted;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  // Apple Authentication
  Future<AuthResult> loginWithApple() async {
    try {
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com');
        await FirebaseAuth.instance.signInWithPopup(provider);
        return AuthResult.success;
      } else {
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
          nonce: nonce,
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        return AuthResult.success;
      }
    } catch (_) {
      return AuthResult.failure;
    }
  }

  // Apple sign-in helpers
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(length, (_) {
      final index = DateTime.now().microsecondsSinceEpoch % charset.length;
      return charset[index];
    });
    return random.join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
