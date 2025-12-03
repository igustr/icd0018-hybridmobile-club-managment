import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';

class EventMapper {
  const EventMapper._();

  static EventDto fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
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
    );
  }

  static Map<String, dynamic> toCreateMap(EventDto event) => {
        FirebaseFieldName.teamId: event.teamId,
        FirebaseFieldName.type: event.type,
        FirebaseFieldName.startTime: Timestamp.fromDate(event.startTime),
        if (event.endTime != null)
          FirebaseFieldName.endTime: Timestamp.fromDate(event.endTime!),
        FirebaseFieldName.location: event.location,
        FirebaseFieldName.note: event.note,
        FirebaseFieldName.createdByUserId: event.createdByUserId,
      };

  static Map<String, dynamic> toUpdateMap(EventDto event) => {
        FirebaseFieldName.teamId: event.teamId,
        FirebaseFieldName.type: event.type,
        FirebaseFieldName.startTime: Timestamp.fromDate(event.startTime),
        if (event.endTime != null)
          FirebaseFieldName.endTime: Timestamp.fromDate(event.endTime!),
        FirebaseFieldName.location: event.location,
        FirebaseFieldName.note: event.note,
        FirebaseFieldName.createdByUserId: event.createdByUserId,
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
