import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/backend/authenticator.dart';

part 'authentication_provider.g.dart';

@riverpod
class Authentication extends _$Authentication {
  final _authenticator = const Authenticator();

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

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithEmailAndPassword(email, password);

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithGoogle();

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> loginWithApple() async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.loginWithApple();

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> logOut() async {
    await _authenticator.logOut();
    state = AuthState.unknown();
  }
}
