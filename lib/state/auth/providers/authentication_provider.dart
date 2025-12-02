import 'package:firebase_auth/firebase_auth.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_state.dart';
import 'package:icd0018_hybridmobile_club_managment/state/user_info/backend/user_info_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/authenticator.dart';

part 'authentication_provider.g.dart';

@riverpod
class Authentication extends _$Authentication {
  final Authenticator _authenticator = Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  @override
  AuthState build() {
    if (_authenticator.isAlreadyLoggedIn) {
      return AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
    return AuthState.unknown();
  }

  // LOGIN SECTION
  Future<AuthResult> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithEmailAndPassword(
      email,
      password,
    );

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );

    return result;
  }

  Future<AuthResult> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithGoogle();

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );

    return result;
  }

  Future<AuthResult> loginWithApple() async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithApple();

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );

    return result;
  }

  Future<void> logOut() async {
    await _authenticator.logOut();
    state = AuthState.unknown();
  }

  // REGISTER SECTION
  Future<AuthResult> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );

    var nextResult = result;
    UserId? userId;

    if (result == AuthResult.success) {
      userId = FirebaseAuth.instance.currentUser?.uid ?? _authenticator.userId;

      if (userId != null) {
        final didSave = await _saveUserInfo(
          userId: userId,
          name: name,
          email: email,
        );

        if (!didSave) {
          nextResult = AuthResult.failure;
        }
      } else {
        nextResult = AuthResult.failure;
      }
    }

    state = AuthState(
      result: nextResult,
      isLoading: false,
      userId: userId,
    );

    return nextResult;
  }

  Future<bool> _saveUserInfo({
    required UserId userId,
    required String name,
    required String email,
  }) {
    return _userInfoStorage.saveUserInfo(
      userId: userId,
      name: name,
      email: email,
    );
  }
}
