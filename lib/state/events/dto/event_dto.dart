import 'package:flutter/foundation.dart';

@immutable
class EventDto {
  const EventDto({
    required this.eventId,
    required this.teamId,
    required this.type,
    required this.startTime,
    required this.createdByUserId,
    this.endTime,
    this.location,
    this.note,
  });

  final String eventId;
  final String teamId;
  final String type;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? note;
  final String createdByUserId;
}
