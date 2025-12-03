import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

class AttendanceStorage {
  const AttendanceStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.attendance);

  Future<void> setAttendance(AttendanceDto attendance) {
    return _collection.doc(attendance.attendanceId).set(
          attendance.toCreateMap(),
          SetOptions(merge: true),
        );
  }

  Future<AttendanceDto?> fetchAttendance(String attendanceId) async {
    try {
      final doc = await _collection.doc(attendanceId).get();
      if (!doc.exists) return null;
      return AttendanceDto.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch attendance $attendanceId: ${e.message}');
      return null;
    }
  }

  Stream<AttendanceDto?> watchAttendance(String attendanceId) {
    return _collection.doc(attendanceId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AttendanceDto.fromDocument(doc);
    });
  }

  Stream<List<AttendanceDto>> watchAttendanceForEvent(String eventId) {
    return _collection
        .where(FirebaseFieldName.eventId, isEqualTo: eventId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AttendanceDto.fromDocument).toList());
  }
}
