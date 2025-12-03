import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

@immutable
class ClubDto {
  const ClubDto({
    required this.clubId,
    required this.name,
    this.createdAt,
  });

  final String clubId;
  final String name;
  final DateTime? createdAt;

  factory ClubDto.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ClubDto(
      clubId: data[FirebaseFieldName.clubId] as String? ?? doc.id,
      name: data[FirebaseFieldName.name] as String? ?? '',
      createdAt: _asDate(data[FirebaseFieldName.createdAt]),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        FirebaseFieldName.name: name,
        FirebaseFieldName.createdAt: createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
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
