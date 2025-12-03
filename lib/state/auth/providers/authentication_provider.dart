import 'package:firebase_auth/firebase_auth.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_state.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/authenticator.dart';

part 'authentication_provider.g.dart';

@riverpod
class Authentication extends _$Authentication {
  final Authenticator _authenticator = Authenticator();
  final _userStorage = const UserStorage();

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

    if (result == AuthResult.success) {
      await _ensureUserDocument();
    }

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

    if (result == AuthResult.success) {
      await _ensureUserDocument();
    }

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

    if (result == AuthResult.success) {
      await _ensureUserDocument();
    }

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
          displayName: name,
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
    required String displayName,
    required String email,
  }) {
    final dto = UserDto(
      userId: userId,
      displayName: displayName,
      email: email,
      role: 'player',
    );

    return _userStorage
        .createUser(dto)
        .then((_) => true)
        .catchError((_) => false);
  }

  Future<void> _ensureUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      return;
    }

    final existing = await _userStorage.fetchUser(uid);
    if (existing != null) {
      return;
    }

    final dto = UserDto(
      userId: uid,
      displayName: user?.displayName ?? '',
      email: user?.email,
      role: 'player',
    );

    await _userStorage.createUser(dto);
  }
}
