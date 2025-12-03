import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/user_id_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

final currentUserProvider = StreamProvider.autoDispose<UserDto?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }

  const storage = UserStorage();
  return storage.watchUser(userId);
});
