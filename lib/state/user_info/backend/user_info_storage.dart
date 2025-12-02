
import 'package:cloud_firestore/cloud_firestore.dart';
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
      var userInfo = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: userId)
          .limit(1)
          .get();

      if (userInfo.docs.isNotEmpty) {
        // we already have this user's profile, save the new data instead
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email ?? '',
        });
        return true;
      }

      final payload = UserInfoPayload(
          userId: userId, displayName: displayName, email: email);

      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .add(payload);

      return true;
    } catch (_) {
      return false;
    }
  }
}
