import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/backend/club_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/dto/club_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';

final clubsForCurrentUserProvider =
    FutureProvider.autoDispose<Map<String, ClubDto>>((ref) async {
  final teams = await ref.watch(teamsForCurrentUserProvider.future);
  if (teams.isEmpty) return {};

  final clubIds = {
    for (final team in teams) if (team.clubId.isNotEmpty) team.clubId
  }.toList();

  const storage = ClubStorage();
  final clubs = await storage.fetchClubsByIds(clubIds);
  return {for (final club in clubs) club.clubId: club};
});
