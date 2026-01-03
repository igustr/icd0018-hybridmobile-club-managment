import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/backend/attendance_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/providers/events_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/notifications/notification_scheduler.dart';

class UpcomingEventWithAttendance {
  final EventDto event;
  final AttendanceDto? myAttendance;
  final bool needsAttention; // Within 48 hours and no decision

  const UpcomingEventWithAttendance({
    required this.event,
    this.myAttendance,
    required this.needsAttention,
  });
}

/// Upcoming events with user's attendance status
final upcomingEventsWithAttendanceProvider =
    FutureProvider.autoDispose<List<UpcomingEventWithAttendance>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final eventsAsync = ref.watch(eventsForUserProvider);

  final user = userAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;

  if (user == null || events == null) {
    return [];
  }

  final now = DateTime.now();
  final in48Hours = now.add(const Duration(hours: 48));

  // Filter to upcoming events only
  final upcomingEvents = events
      .where((e) => e.startTime.isAfter(now))
      .take(10) // Limit to 10 upcoming
      .toList();

  if (upcomingEvents.isEmpty) {
    return [];
  }

  // Fetch attendance for each event
  const storage = AttendanceStorage();
  final results = <UpcomingEventWithAttendance>[];

  for (final event in upcomingEvents) {
    final attendanceList = await storage
        .watchAttendanceForEvent(event.eventId)
        .first;

    final myAttendance = attendanceList
        .where((a) => a.playerId == user.userId)
        .firstOrNull;

    final needsAttention = event.startTime.isBefore(in48Hours) &&
        myAttendance == null &&
        user.role.toLowerCase() == 'player';

    results.add(UpcomingEventWithAttendance(
      event: event,
      myAttendance: myAttendance,
      needsAttention: needsAttention,
    ));
  }

  // Schedule notifications for upcoming events
  final attendanceMap = <String, AttendanceDto?>{};
  for (final result in results) {
    attendanceMap[result.event.eventId] = result.myAttendance;
  }

  await NotificationScheduler.instance.scheduleEventReminders(
    events: results.map((r) => r.event).toList(),
    attendanceMap: attendanceMap,
    userRole: user.role,
  );

  return results;
});

/// Events needing attention (within 48h, no response)
final eventsNeedingAttentionProvider =
    Provider.autoDispose<List<UpcomingEventWithAttendance>>((ref) {
  final upcomingAsync = ref.watch(upcomingEventsWithAttendanceProvider);
  final upcoming = upcomingAsync.valueOrNull ?? [];
  return upcoming.where((e) => e.needsAttention).toList();
});

/// Count of events needing attention
final eventsNeedingAttentionCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(eventsNeedingAttentionProvider).length;
});

class EventAttendanceStats {
  final EventDto event;
  final int coming;
  final int notComing;
  final int maybe;
  final int noResponse;
  final int total;

  const EventAttendanceStats({
    required this.event,
    required this.coming,
    required this.notComing,
    required this.maybe,
    required this.noResponse,
    required this.total,
  });

  double get attendanceRate => total > 0 ? coming / total : 0;
}

/// For coaches: upcoming events with attendance stats
final upcomingEventsWithStatsProvider =
    FutureProvider.autoDispose<List<EventAttendanceStats>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final eventsAsync = ref.watch(eventsForUserProvider);

  final user = userAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;

  if (user == null || events == null) {
    return [];
  }

  final now = DateTime.now();

  // Filter to upcoming events only
  final upcomingEvents = events
      .where((e) => e.startTime.isAfter(now))
      .take(5)
      .toList();

  if (upcomingEvents.isEmpty) {
    return [];
  }

  const storage = AttendanceStorage();
  final results = <EventAttendanceStats>[];

  for (final event in upcomingEvents) {
    final attendanceList = await storage
        .watchAttendanceForEvent(event.eventId)
        .first;

    int coming = 0;
    int notComing = 0;
    int maybe = 0;

    for (final a in attendanceList) {
      switch (a.status) {
        case 'coming':
          coming++;
          break;
        case 'not_coming':
          notComing++;
          break;
        case 'maybe':
          maybe++;
          break;
      }
    }

    // Total is estimated from team size - we'd need team info for accurate count
    final responded = coming + notComing + maybe;

    results.add(EventAttendanceStats(
      event: event,
      coming: coming,
      notComing: notComing,
      maybe: maybe,
      noResponse: 0, // Would need team size to calculate
      total: responded > 0 ? responded : 1,
    ));
  }

  return results;
});

/// Player's personal attendance statistics
class PlayerAttendanceStats {
  final int totalPastEvents;
  final int attended;
  final int missed;
  final int maybe;

  const PlayerAttendanceStats({
    required this.totalPastEvents,
    required this.attended,
    required this.missed,
    required this.maybe,
  });

  double get attendanceRate =>
      totalPastEvents > 0 ? attended / totalPastEvents : 0;

  int get respondedCount => attended + missed + maybe;
}

/// For coaches: last past event with attendance stats (when no upcoming events)
final lastPastEventWithStatsProvider =
    FutureProvider.autoDispose<EventAttendanceStats?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final eventsAsync = ref.watch(eventsForUserProvider);

  final user = userAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;

  if (user == null || events == null) {
    return null;
  }

  final now = DateTime.now();

  // Get the most recent past event
  final pastEvents = events
      .where((e) => e.startTime.isBefore(now))
      .toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  if (pastEvents.isEmpty) {
    return null;
  }

  final lastEvent = pastEvents.first;

  const storage = AttendanceStorage();
  final attendanceList = await storage
      .watchAttendanceForEvent(lastEvent.eventId)
      .first;

  int coming = 0;
  int notComing = 0;
  int maybe = 0;

  for (final a in attendanceList) {
    switch (a.status) {
      case 'coming':
        coming++;
        break;
      case 'not_coming':
        notComing++;
        break;
      case 'maybe':
        maybe++;
        break;
    }
  }

  final responded = coming + notComing + maybe;

  return EventAttendanceStats(
    event: lastEvent,
    coming: coming,
    notComing: notComing,
    maybe: maybe,
    noResponse: 0,
    total: responded > 0 ? responded : 1,
  );
});

/// For players: their personal attendance stats
final playerAttendanceStatsProvider =
    FutureProvider.autoDispose<PlayerAttendanceStats>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final eventsAsync = ref.watch(eventsForUserProvider);

  final user = userAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;

  if (user == null || events == null) {
    return const PlayerAttendanceStats(
      totalPastEvents: 0,
      attended: 0,
      missed: 0,
      maybe: 0,
    );
  }

  final now = DateTime.now();

  // Filter to past events only
  final pastEvents = events.where((e) => e.startTime.isBefore(now)).toList();

  if (pastEvents.isEmpty) {
    return const PlayerAttendanceStats(
      totalPastEvents: 0,
      attended: 0,
      missed: 0,
      maybe: 0,
    );
  }

  const storage = AttendanceStorage();
  int attended = 0;
  int missed = 0;
  int maybe = 0;

  for (final event in pastEvents) {
    final attendanceList =
        await storage.watchAttendanceForEvent(event.eventId).first;

    final myAttendance = attendanceList
        .where((a) => a.playerId == user.userId)
        .firstOrNull;

    if (myAttendance != null) {
      switch (myAttendance.status) {
        case 'coming':
          attended++;
          break;
        case 'not_coming':
          missed++;
          break;
        case 'maybe':
          maybe++;
          break;
      }
    }
  }

  return PlayerAttendanceStats(
    totalPastEvents: pastEvents.length,
    attended: attended,
    missed: missed,
    maybe: maybe,
  );
});
