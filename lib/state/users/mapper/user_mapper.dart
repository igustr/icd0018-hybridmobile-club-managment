import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

class UserMapper {
  const UserMapper._();

  static UserDto fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserDto(
      userId: data[FirebaseFieldName.userId] as String? ?? doc.id,
      displayName: data[FirebaseFieldName.displayName] as String? ?? '',
      email: data[FirebaseFieldName.email] as String?,
      role: data[FirebaseFieldName.role] as String? ?? 'player',
      clubId: data[FirebaseFieldName.clubId] as String?,
      teamIds: _asStringList(data[FirebaseFieldName.teamIds]),
    );
  }

  static Map<String, dynamic> toCreateMap(UserDto user) => {
        FirebaseFieldName.userId: user.userId,
        FirebaseFieldName.displayName: user.displayName,
        FirebaseFieldName.email: user.email,
        FirebaseFieldName.role: user.role,
        FirebaseFieldName.clubId: user.clubId,
        FirebaseFieldName.teamIds: user.teamIds,
      };

  static Map<String, dynamic> toUpdateMap(UserDto user) => {
        FirebaseFieldName.displayName: user.displayName,
        FirebaseFieldName.email: user.email,
        FirebaseFieldName.clubId: user.clubId,
        FirebaseFieldName.teamIds: user.teamIds,
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

List<String> _asStringList(dynamic value) {
  if (value is Iterable) {
    return value.whereType<String>().toList();
  }
  return const [];
}
