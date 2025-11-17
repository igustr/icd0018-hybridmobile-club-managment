import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';

class AppleAuth {
  const AppleAuth(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Future<AuthResult> loginWithApple() async {
    try {
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com');
        await _firebaseAuth.signInWithPopup(provider);
        return AuthResult.success;
      } else {
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        await _firebaseAuth.signInWithCredential(oauthCredential);
        return AuthResult.success;
      }
    } catch (_) {
      return AuthResult.failure;
    }
  }

  // Helpers
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
