import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/mapper/user_mapper.dart';

class UserStorage {
  const UserStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.users);

  String generateId() => _collection.doc().id;

  Future<void> createUser(UserDto user) {
    return _collection.doc(user.userId).set(
          UserMapper.toCreateMap(user),
          SetOptions(merge: true),
        );
  }

  Future<void> updateUser(UserDto user) {
    return _collection.doc(user.userId).set(
          UserMapper.toUpdateMap(user),
          SetOptions(merge: true),
        );
  }

  Future<UserDto?> fetchUser(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return UserMapper.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch user $userId: ${e.message}');
      return null;
    }
  }

  Stream<UserDto?> watchUser(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserMapper.fromDocument(doc);
    });
  }

  Future<List<UserDto>> fetchUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return const [];
    final futures = userIds.map((id) => _collection.doc(id).get());
    final snapshots = await Future.wait(futures);
    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => UserMapper.fromDocument(doc))
        .toList();
  }

  Future<UserDto?> findUserByEmail(String email) async {
    try {
      final query = await _collection
          .where(FirebaseFieldName.email, isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return UserMapper.fromDocument(query.docs.first);
    } on FirebaseException catch (e) {
      debugPrint('Failed to find user by email $email: ${e.message}');
      return null;
    }
  }

  Future<void> addTeamToUser(String userId, String teamId) async {
    final user = await fetchUser(userId);
    if (user == null) return;

    final updatedTeamIds = [...user.teamIds];
    if (!updatedTeamIds.contains(teamId)) {
      updatedTeamIds.add(teamId);
    }

    await _collection.doc(userId).update({
      FirebaseFieldName.teamIds: updatedTeamIds,
    });
  }

  Future<void> removeTeamFromUser(String userId, String teamId) async {
    final user = await fetchUser(userId);
    if (user == null) return;

    final updatedTeamIds = [...user.teamIds];
    updatedTeamIds.remove(teamId);

    await _collection.doc(userId).update({
      FirebaseFieldName.teamIds: updatedTeamIds,
    });
  }
}
