import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

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
    this.createdAt,
  });

  final String eventId;
  final String teamId;
  final String type;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? note;
  final String createdByUserId;
  final DateTime? createdAt;

  factory EventDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return EventDto(
      eventId: data[FirebaseFieldName.eventId] as String? ?? doc.id,
      teamId: data[FirebaseFieldName.teamId] as String? ?? '',
      type: data[FirebaseFieldName.type] as String? ?? '',
      startTime: _asDate(data[FirebaseFieldName.startTime]) ?? DateTime.now(),
      endTime: _asDate(data[FirebaseFieldName.endTime]),
      location: data[FirebaseFieldName.location] as String?,
      note: data[FirebaseFieldName.note] as String?,
      createdByUserId:
          data[FirebaseFieldName.createdByUserId] as String? ?? '',
      createdAt: _asDate(data[FirebaseFieldName.createdAt]),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        FirebaseFieldName.teamId: teamId,
        FirebaseFieldName.type: type,
        FirebaseFieldName.startTime: Timestamp.fromDate(startTime),
        if (endTime != null) FirebaseFieldName.endTime: Timestamp.fromDate(endTime!),
        FirebaseFieldName.location: location,
        FirebaseFieldName.note: note,
        FirebaseFieldName.createdByUserId: createdByUserId,
        FirebaseFieldName.createdAt: createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        FirebaseFieldName.teamId: teamId,
        FirebaseFieldName.type: type,
        FirebaseFieldName.startTime: Timestamp.fromDate(startTime),
        if (endTime != null) FirebaseFieldName.endTime: Timestamp.fromDate(endTime!),
        FirebaseFieldName.location: location,
        FirebaseFieldName.note: note,
        FirebaseFieldName.createdByUserId: createdByUserId,
      };
}

DateTime? _asDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
