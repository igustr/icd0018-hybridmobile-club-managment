import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/backend/attendance_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

/// All attendance for event. For the coach
final attendanceForEventProvider =
    StreamProvider.autoDispose.family<List<AttendanceDto>, String>(
  (ref, eventId) {
    const storage = AttendanceStorage();
    return storage.watchAttendanceForEvent(eventId);
  },
);

/// All users attendance. For the coach
final userAttendanceForEventProvider =
    StreamProvider.autoDispose.family<AttendanceDto?, String>(
  (ref, eventId) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    if (user == null) {
      return Stream.value(null);
    }

    final attendanceAsync = ref.watch(attendanceForEventProvider(eventId));
    final attendanceList = attendanceAsync.valueOrNull ?? [];

    final userAttendance = attendanceList.where(
      (a) => a.playerId == user.userId,
    );

    if (userAttendance.isEmpty) {
      return Stream.value(null);
    }

    return Stream.value(userAttendance.first);
  },
);
