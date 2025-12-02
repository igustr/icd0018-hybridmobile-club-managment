
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/user_info/dto/user_info_payload.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';

class UserInfoStorage {
  const UserInfoStorage();

  Future<bool> saveUserInfo({
    required UserId userId,
    required String name,
    required String? email,
  }) async {
    try {
      final payload = UserInfoPayload(
        userId: userId,
        name: name,
        email: email,
      );

      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .doc(userId)
          .set(payload, SetOptions(merge: true));

      return true;
    } on FirebaseException catch (e) {
      debugPrint('Failed to save user info (code: ${e.code}): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to save user info: $e');
      return false;
    }
  }
}
