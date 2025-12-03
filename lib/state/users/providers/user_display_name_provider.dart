import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

final userDisplayNameProvider =
    Provider.autoDispose<AsyncValue<String?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.whenData((value) => value?.displayName);
});
