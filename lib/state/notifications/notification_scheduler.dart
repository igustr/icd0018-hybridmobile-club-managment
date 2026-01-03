import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'local_notification_service.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._();
  static NotificationScheduler get instance => _instance;

  NotificationScheduler._();

  final LocalNotificationService _notificationService =
      LocalNotificationService.instance;

  /// Schedule reminders for a list of events
  /// [events] - List of upcoming events
  /// [attendanceMap] - Map of eventId to user's attendance (null if no decision)
  /// [userRole] - 'player' or 'coach'
  Future<void> scheduleEventReminders({
    required List<EventDto> events,
    required Map<String, AttendanceDto?> attendanceMap,
    required String userRole,
  }) async {
    final now = DateTime.now();

    for (final event in events) {
      // Only schedule for future events
      if (event.startTime.isBefore(now)) continue;

      // Schedule 1-hour reminder for everyone
      await _scheduleOneHourReminder(event);

      // Schedule 1-day reminder only for players without attendance decision
      if (userRole.toLowerCase() == 'player') {
        final hasDecision = attendanceMap[event.eventId] != null;
        if (!hasDecision) {
          await _scheduleOneDayReminder(event);
        } else {
          // Cancel any existing 1-day reminder if user already made decision
          await cancelOneDayReminder(event.eventId);
        }
      }
    }

    debugPrint('Scheduled reminders for ${events.length} events');
  }

  Future<void> _scheduleOneHourReminder(EventDto event) async {
    final reminderTime = event.startTime.subtract(const Duration(hours: 1));

    // Skip if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) return;

    final id = _generateNotificationId(event.eventId, '1h');
    final eventType = _capitalizeFirst(event.type);

    await _notificationService.scheduleNotification(
      id: id,
      title: '$eventType in 1 hour',
      body: event.location != null
          ? 'Get ready! Your $eventType is at ${event.location}'
          : 'Get ready for your $eventType!',
      scheduledDate: reminderTime,
      payload: event.eventId,
    );
  }

  Future<void> _scheduleOneDayReminder(EventDto event) async {
    final reminderTime = event.startTime.subtract(const Duration(days: 1));

    // Skip if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) return;

    final id = _generateNotificationId(event.eventId, '1d');
    final eventType = _capitalizeFirst(event.type);

    await _notificationService.scheduleNotification(
      id: id,
      title: 'Attendance Required',
      body: 'Please confirm your attendance for tomorrow\'s $eventType',
      scheduledDate: reminderTime,
      payload: event.eventId,
    );
  }

  /// Cancel only the 1-day attendance reminder (user made decision)
  Future<void> cancelOneDayReminder(String eventId) async {
    final id = _generateNotificationId(eventId, '1d');
    await _notificationService.cancelNotification(id);
  }

  /// Cancel all reminders for a specific event
  Future<void> cancelEventReminders(String eventId) async {
    await _notificationService.cancelNotification(
      _generateNotificationId(eventId, '1h'),
    );
    await _notificationService.cancelNotification(
      _generateNotificationId(eventId, '1d'),
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Generate a unique notification ID from event ID and type
  int _generateNotificationId(String eventId, String suffix) {
    return '${eventId}_$suffix'.hashCode.abs() % 2147483647;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
