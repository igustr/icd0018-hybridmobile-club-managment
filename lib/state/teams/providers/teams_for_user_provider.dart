import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/backend/team_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

final teamsForCurrentUserProvider =
    FutureProvider.autoDispose<List<TeamDto>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.teamIds.isEmpty) {
    return const [];
  }
  const storage = TeamStorage();
  return storage.fetchTeamsByIds(user.teamIds);
});
