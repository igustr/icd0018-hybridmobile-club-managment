import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

@immutable
class TeamDto {
  const TeamDto({
    required this.teamId,
    required this.clubId,
    required this.name,
    required this.coachId,
    this.ageGroup,
    this.playerIds = const [],
    this.createdAt,
  });

  final String teamId;
  final String clubId;
  final String name;
  final String coachId;
  final String? ageGroup;
  final List<String> playerIds;
  final DateTime? createdAt;

  factory TeamDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return TeamDto(
      teamId: data[FirebaseFieldName.teamId] as String? ?? doc.id,
      clubId: data[FirebaseFieldName.clubId] as String? ?? '',
      name: data[FirebaseFieldName.name] as String? ?? '',
      ageGroup: data[FirebaseFieldName.ageGroup] as String?,
      coachId: data[FirebaseFieldName.coachId] as String? ?? '',
      playerIds: _asStringList(data[FirebaseFieldName.playerIds]),
      createdAt: _asDate(data[FirebaseFieldName.createdAt]),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        FirebaseFieldName.clubId: clubId,
        FirebaseFieldName.name: name,
        FirebaseFieldName.ageGroup: ageGroup,
        FirebaseFieldName.coachId: coachId,
        FirebaseFieldName.playerIds: playerIds,
        FirebaseFieldName.createdAt: createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        FirebaseFieldName.clubId: clubId,
        FirebaseFieldName.name: name,
        FirebaseFieldName.ageGroup: ageGroup,
        FirebaseFieldName.coachId: coachId,
        FirebaseFieldName.playerIds: playerIds,
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
