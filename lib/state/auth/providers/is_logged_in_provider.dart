import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/models/auth_result.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/authentication_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_logged_in_provider.g.dart';

@riverpod
bool isLoggedIn(Ref ref) {
  final authProvider = ref.watch(authenticationProvider);
  return authProvider.result == AuthResult.success;
}
