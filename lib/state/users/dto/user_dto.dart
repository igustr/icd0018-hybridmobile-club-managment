import 'package:flutter/foundation.dart';

@immutable
class UserDto {
  const UserDto({
    required this.userId,
    required this.displayName,
    required this.role,
    this.email,
    this.clubId,
    this.teamIds = const [],
  });

  final String userId;
  final String displayName;
  final String role;
  final String? email;
  final String? clubId;
  final List<String> teamIds;
}
