import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

@immutable
class UserDto {
  const UserDto({
    required this.userId,
    required this.displayName,
    required this.role,
    this.email,
    this.clubId,
    this.teamIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String displayName;
  final String role;
  final String? email;
  final String? clubId;
  final List<String> teamIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserDto.fromDocument(
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
      createdAt: _asDate(data[FirebaseFieldName.createdAt]),
      updatedAt: _asDate(data[FirebaseFieldName.updatedAt]),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        FirebaseFieldName.userId: userId,
        FirebaseFieldName.displayName: displayName,
        FirebaseFieldName.email: email,
        FirebaseFieldName.role: role,
        FirebaseFieldName.clubId: clubId,
        FirebaseFieldName.teamIds: teamIds,
        FirebaseFieldName.createdAt: createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        FirebaseFieldName.updatedAt: updatedAt != null
            ? Timestamp.fromDate(updatedAt!)
            : FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        FirebaseFieldName.displayName: displayName,
        FirebaseFieldName.email: email,
        FirebaseFieldName.clubId: clubId,
        FirebaseFieldName.teamIds: teamIds,
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

List<String> _asStringList(dynamic value) {
  if (value is Iterable) {
    return value.whereType<String>().toList();
  }
  return const [];
}
