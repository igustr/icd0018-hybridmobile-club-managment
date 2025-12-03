import 'package:flutter/foundation.dart';

@immutable
class AttendanceDto {
  const AttendanceDto({
    required this.attendanceId,
    required this.eventId,
    required this.playerId,
    required this.status,
    this.message,
  });

  final String attendanceId;
  final String eventId;
  final String playerId;
  final String status;
  final String? message;
}
