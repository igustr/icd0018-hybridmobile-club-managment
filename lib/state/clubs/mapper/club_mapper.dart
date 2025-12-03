import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/dto/club_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

class ClubMapper {
  const ClubMapper._();

  static ClubDto fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubDto(
      clubId: data[FirebaseFieldName.clubId] as String? ?? doc.id,
      name: data[FirebaseFieldName.name] as String? ?? '',
    );
  }

  static Map<String, dynamic> toCreateMap(ClubDto club) => {
        FirebaseFieldName.name: club.name,
      };
}
