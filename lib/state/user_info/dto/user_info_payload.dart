import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/typedef/user_id.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? displayName,
    required String? email,
  }) : super(
    {
      FirebaseFieldName.userId: userId,
      FirebaseFieldName.displayName: displayName ?? '',
      FirebaseFieldName.email: email ?? '',
    },
  );
}
