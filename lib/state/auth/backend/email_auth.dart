import 'package:firebase_auth/firebase_auth.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';

class EmailAuth {
  const EmailAuth(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  UserId? get userId => _firebaseAuth.currentUser?.uid;

  bool get isAlreadyLoggedIn => userId != null;

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AuthResult> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success;
    } on FirebaseAuthException {
      return AuthResult.failure;
    } catch (_) {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return AuthResult.userAlreadyExists;
      }
      return AuthResult.failure;
    } catch (_) {
      return AuthResult.failure;
    }
  }
}
