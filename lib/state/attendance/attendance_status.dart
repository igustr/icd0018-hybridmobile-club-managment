import 'package:flutter/material.dart';

enum AttendanceStatus {
  coming,
  notComing,
  maybe,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.coming:
        return 'coming';
      case AttendanceStatus.notComing:
        return 'not_coming';
      case AttendanceStatus.maybe:
        return 'maybe';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.coming:
        return 'Coming';
      case AttendanceStatus.notComing:
        return 'Not Coming';
      case AttendanceStatus.maybe:
        return 'Maybe';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.coming:
        return Colors.green;
      case AttendanceStatus.notComing:
        return Colors.red;
      case AttendanceStatus.maybe:
        return Colors.amber;
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceStatus.coming:
        return Icons.check_circle;
      case AttendanceStatus.notComing:
        return Icons.cancel;
      case AttendanceStatus.maybe:
        return Icons.help;
    }
  }

  bool get requiresReason {
    switch (this) {
      case AttendanceStatus.coming:
        return false;
      case AttendanceStatus.notComing:
      case AttendanceStatus.maybe:
        return true;
    }
  }

  static AttendanceStatus? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'coming':
        return AttendanceStatus.coming;
      case 'not_coming':
        return AttendanceStatus.notComing;
      case 'maybe':
        return AttendanceStatus.maybe;
      default:
        return null;
    }
  }
}
