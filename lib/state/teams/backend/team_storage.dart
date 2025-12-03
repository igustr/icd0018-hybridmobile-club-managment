import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';

class TeamStorage {
  const TeamStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.teams);

  Future<void> createTeam(TeamDto team) {
    return _collection.doc(team.teamId).set(team.toCreateMap());
  }

  Future<void> updateTeam(TeamDto team) {
    return _collection.doc(team.teamId).set(
          team.toUpdateMap(),
          SetOptions(merge: true),
        );
  }

  Future<TeamDto?> fetchTeam(String teamId) async {
    try {
      final doc = await _collection.doc(teamId).get();
      if (!doc.exists) return null;
      return TeamDto.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch team $teamId: ${e.message}');
      return null;
    }
  }

  Stream<TeamDto?> watchTeam(String teamId) {
    return _collection.doc(teamId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TeamDto.fromDocument(doc);
    });
  }

  Future<List<TeamDto>> fetchTeamsByIds(List<String> teamIds) async {
    if (teamIds.isEmpty) return const [];
    final futures = teamIds.map((id) => _collection.doc(id).get());
    final snapshots = await Future.wait(futures);
    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => TeamDto.fromDocument(doc))
        .toList();
  }
}
