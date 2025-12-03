import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

class AttendanceMapper {
  const AttendanceMapper._();

  static AttendanceDto fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttendanceDto(
      attendanceId: data[FirebaseFieldName.attendanceId] as String? ?? doc.id,
      eventId: data[FirebaseFieldName.eventId] as String? ?? '',
      playerId: data[FirebaseFieldName.playerId] as String? ?? '',
      status: data[FirebaseFieldName.status] as String? ?? '',
      message: data[FirebaseFieldName.message] as String?,
    );
  }

  static Map<String, dynamic> toCreateMap(AttendanceDto attendance) => {
        FirebaseFieldName.attendanceId: attendance.attendanceId,
        FirebaseFieldName.eventId: attendance.eventId,
        FirebaseFieldName.playerId: attendance.playerId,
        FirebaseFieldName.status: attendance.status,
        FirebaseFieldName.message: attendance.message,
      };

  static Map<String, dynamic> toUpdateMap(AttendanceDto attendance) => {
        FirebaseFieldName.status: attendance.status,
        FirebaseFieldName.message: attendance.message,
      };
}
