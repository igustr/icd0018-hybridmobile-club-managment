import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/backend/team_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

/// Fetches all players for a specific team
final playersForTeamProvider =
    FutureProvider.autoDispose.family<List<UserDto>, String>(
  (ref, teamId) async {
    const teamStorage = TeamStorage();
    const userStorage = UserStorage();

    final team = await teamStorage.fetchTeam(teamId);
    if (team == null || team.playerIds.isEmpty) {
      return const [];
    }

    return userStorage.fetchUsersByIds(team.playerIds);
  },
);
