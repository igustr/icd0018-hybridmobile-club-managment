import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/backend/event_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

final eventsForUserProvider =
    StreamProvider.autoDispose<List<EventDto>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;

  if (user == null || user.teamIds.isEmpty) {
    return const Stream.empty();
  }

  final storage = EventStorage();
  return storage.watchEventsForTeams(user.teamIds).map((events) {
    events.sort(
      (a, b) => a.startTime.compareTo(b.startTime),
    );
    return events;
  });
});
