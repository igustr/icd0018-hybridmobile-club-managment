import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

class UserStorage {
  const UserStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.users);

  String generateId() => _collection.doc().id;

  Future<void> createUser(UserDto user) {
    return _collection.doc(user.userId).set(
          user.toCreateMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateUser(UserDto user) {
    return _collection.doc(user.userId).set(
          user.toUpdateMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserDto?> fetchUser(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return UserDto.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch user $userId: ${e.message}');
      return null;
    }
  }

  Stream<UserDto?> watchUser(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserDto.fromDocument(doc);
    });
  }
}
