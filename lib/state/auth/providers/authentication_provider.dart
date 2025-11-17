import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/authenticator.dart';

part 'authentication_provider.g.dart';

@riverpod
class Authentication extends _$Authentication {
  final Authenticator _authenticator = Authenticator();

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

    // TODO: Save user info to database (Firestore or your backend)

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );

    return result;
  }
}
