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
    required String displayName,
    required String? email,
  }) async {
    try {
      final payload = UserInfoPayload(
        userId: userId,
        displayName: displayName,
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

  Future<Map<String, dynamic>?> fetchUserInfo({
    required UserId userId,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch user info (code: ${e.code}): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Failed to fetch user info: $e');
      return null;
    }
  }

  Future<String?> fetchDisplayName({
    required UserId userId,
  }) async {
    final userData = await fetchUserInfo(userId: userId);
    final displayName = userData?[FirebaseFieldName.displayName];
    if (displayName is String && displayName.isNotEmpty) {
      return displayName;
    }
    final fallbackName = userData?[FirebaseFieldName.name];
    if (fallbackName is String && fallbackName.isNotEmpty) {
      return fallbackName;
    }
    return null;
  }
}
