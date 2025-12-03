import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';

class TeamMapper {
  const TeamMapper._();

  static TeamDto fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TeamDto(
      teamId: data[FirebaseFieldName.teamId] as String? ?? doc.id,
      clubId: data[FirebaseFieldName.clubId] as String? ?? '',
      name: data[FirebaseFieldName.name] as String? ?? '',
      ageGroup: data[FirebaseFieldName.ageGroup] as String?,
      coachIds: _asStringList(
        data[FirebaseFieldName.coachIds] ?? data[FirebaseFieldName.coachId],
      ),
      playerIds: _asStringList(data[FirebaseFieldName.playerIds]),
    );
  }

  static Map<String, dynamic> toCreateMap(TeamDto team) => {
        FirebaseFieldName.clubId: team.clubId,
        FirebaseFieldName.name: team.name,
        FirebaseFieldName.ageGroup: team.ageGroup,
        FirebaseFieldName.coachIds: team.coachIds,
        FirebaseFieldName.playerIds: team.playerIds,
      };

  static Map<String, dynamic> toUpdateMap(TeamDto team) => {
        FirebaseFieldName.clubId: team.clubId,
        FirebaseFieldName.name: team.name,
        FirebaseFieldName.ageGroup: team.ageGroup,
        FirebaseFieldName.coachIds: team.coachIds,
        FirebaseFieldName.playerIds: team.playerIds,
      };
}

List<String> _asStringList(dynamic value) {
  if (value is String) {
    return [value];
  }
  if (value is Iterable) {
    return value.whereType<String>().toList();
  }
  return const [];
}
