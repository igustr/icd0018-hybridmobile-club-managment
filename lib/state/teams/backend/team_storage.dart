import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/mapper/team_mapper.dart';

class TeamStorage {
  const TeamStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.teams);

  Future<void> createTeam(TeamDto team) {
    return _collection.doc(team.teamId).set(TeamMapper.toCreateMap(team));
  }

  Future<void> updateTeam(TeamDto team) {
    return _collection.doc(team.teamId).set(
          TeamMapper.toUpdateMap(team),
          SetOptions(merge: true),
        );
  }

  Future<TeamDto?> fetchTeam(String teamId) async {
    try {
      final doc = await _collection.doc(teamId).get();
      if (!doc.exists) return null;
      return TeamMapper.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch team $teamId: ${e.message}');
      return null;
    }
  }

  Stream<TeamDto?> watchTeam(String teamId) {
    return _collection.doc(teamId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TeamMapper.fromDocument(doc);
    });
  }

  Future<List<TeamDto>> fetchTeamsByIds(List<String> teamIds) async {
    if (teamIds.isEmpty) return const [];
    final futures = teamIds.map((id) => _collection.doc(id).get());
    final snapshots = await Future.wait(futures);
    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => TeamMapper.fromDocument(doc))
        .toList();
  }

  Future<void> addMemberToTeam({
    required String teamId,
    required String userId,
    required bool asCoach,
  }) async {
    final team = await fetchTeam(teamId);
    if (team == null) {
      throw Exception('Team not found');
    }

    if (asCoach) {
      final updatedCoachIds = [...team.coachIds];
      if (!updatedCoachIds.contains(userId)) {
        updatedCoachIds.add(userId);
      }
      await _collection.doc(teamId).update({
        FirebaseFieldName.coachIds: updatedCoachIds,
      });
    } else {
      final updatedPlayerIds = [...team.playerIds];
      if (!updatedPlayerIds.contains(userId)) {
        updatedPlayerIds.add(userId);
      }
      await _collection.doc(teamId).update({
        FirebaseFieldName.playerIds: updatedPlayerIds,
      });
    }
  }

  Future<void> removeMemberFromTeam({
    required String teamId,
    required String userId,
    required bool isCoach,
  }) async {
    final team = await fetchTeam(teamId);
    if (team == null) {
      throw Exception('Team not found');
    }

    if (isCoach) {
      final updatedCoachIds = [...team.coachIds];
      updatedCoachIds.remove(userId);
      await _collection.doc(teamId).update({
        FirebaseFieldName.coachIds: updatedCoachIds,
      });
    } else {
      final updatedPlayerIds = [...team.playerIds];
      updatedPlayerIds.remove(userId);
      await _collection.doc(teamId).update({
        FirebaseFieldName.playerIds: updatedPlayerIds,
      });
    }
  }

  Future<void> changeMemberRole({
    required String teamId,
    required String userId,
    required bool toCoach,
  }) async {
    final team = await fetchTeam(teamId);
    if (team == null) {
      throw Exception('Team not found');
    }

    if (toCoach) {
      // Move from playerIds to coachIds
      final updatedPlayerIds = [...team.playerIds];
      final updatedCoachIds = [...team.coachIds];
      updatedPlayerIds.remove(userId);
      if (!updatedCoachIds.contains(userId)) {
        updatedCoachIds.add(userId);
      }
      await _collection.doc(teamId).update({
        FirebaseFieldName.playerIds: updatedPlayerIds,
        FirebaseFieldName.coachIds: updatedCoachIds,
      });
    } else {
      // Move from coachIds to playerIds
      final updatedCoachIds = [...team.coachIds];
      final updatedPlayerIds = [...team.playerIds];
      updatedCoachIds.remove(userId);
      if (!updatedPlayerIds.contains(userId)) {
        updatedPlayerIds.add(userId);
      }
      await _collection.doc(teamId).update({
        FirebaseFieldName.coachIds: updatedCoachIds,
        FirebaseFieldName.playerIds: updatedPlayerIds,
      });
    }
  }
}
