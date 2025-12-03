import 'package:flutter/foundation.dart';

@immutable
class TeamDto {
  const TeamDto({
    required this.teamId,
    required this.clubId,
    required this.name,
    required this.coachIds,
    this.ageGroup,
    this.playerIds = const [],
  });

  final String teamId;
  final String clubId;
  final String name;
  final List<String> coachIds;
  final String? ageGroup;
  final List<String> playerIds;
}
