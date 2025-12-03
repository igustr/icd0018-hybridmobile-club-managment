import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

@immutable
class AttendanceDto {
  const AttendanceDto({
    required this.attendanceId,
    required this.eventId,
    required this.playerId,
    required this.status,
    this.message,
    this.updatedAt,
  });

  final String attendanceId;
  final String eventId;
  final String playerId;
  final String status;
  final String? message;
  final DateTime? updatedAt;

  factory AttendanceDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttendanceDto(
      attendanceId: data[FirebaseFieldName.attendanceId] as String? ?? doc.id,
      eventId: data[FirebaseFieldName.eventId] as String? ?? '',
      playerId: data[FirebaseFieldName.playerId] as String? ?? '',
      status: data[FirebaseFieldName.status] as String? ?? '',
      message: data[FirebaseFieldName.message] as String?,
      updatedAt: _asDate(data[FirebaseFieldName.updatedAt]),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        FirebaseFieldName.attendanceId: attendanceId,
        FirebaseFieldName.eventId: eventId,
        FirebaseFieldName.playerId: playerId,
        FirebaseFieldName.status: status,
        FirebaseFieldName.message: message,
        FirebaseFieldName.updatedAt: updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        FirebaseFieldName.status: status,
        FirebaseFieldName.message: message,
        FirebaseFieldName.updatedAt: FieldValue.serverTimestamp(),
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
