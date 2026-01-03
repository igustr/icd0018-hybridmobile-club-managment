import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/conversation_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/conversation_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

final conversationsForUserProvider =
    StreamProvider.autoDispose<List<ConversationDto>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final teamsAsync = ref.watch(teamsForCurrentUserProvider);
  final user = userAsync.valueOrNull;
  final teams = teamsAsync.valueOrNull;

  if (user == null) {
    return const Stream.empty();
  }

  const storage = ConversationStorage();

  // Ensure team conversations exist for all user's teams
  if (teams != null && teams.isNotEmpty) {
    Future(() async {
      for (final team in teams) {
        final allMemberIds = [...team.playerIds, ...team.coachIds];
        await storage.getOrCreateTeamConversation(team.teamId, allMemberIds);
      }
    });
  }

  return storage.watchConversationsForUser(user.userId);
});

final teamConversationsProvider =
    Provider.autoDispose<List<ConversationDto>>((ref) {
  final conversationsAsync = ref.watch(conversationsForUserProvider);
  return conversationsAsync.valueOrNull
          ?.where((c) => c.isTeamChat)
          .toList() ??
      [];
});

final directConversationsProvider =
    Provider.autoDispose<List<ConversationDto>>((ref) {
  final conversationsAsync = ref.watch(conversationsForUserProvider);
  return conversationsAsync.valueOrNull
          ?.where((c) => c.isDirectChat)
          .toList() ??
      [];
});
