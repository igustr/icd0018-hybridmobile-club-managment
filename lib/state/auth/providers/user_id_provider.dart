import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/authentication_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_id_provider.g.dart';

@riverpod
UserId? userId(Ref ref) {
  return ref.watch(authenticationProvider).userId;
}
