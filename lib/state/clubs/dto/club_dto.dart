import 'package:flutter/foundation.dart';

@immutable
class ClubDto {
  const ClubDto({
    required this.clubId,
    required this.name,
  });

  final String clubId;
  final String name;
}
