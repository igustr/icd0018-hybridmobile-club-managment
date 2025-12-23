import 'package:flutter/foundation.dart' show immutable;

@immutable
class FirebaseFieldName {
  static const userId = 'userId';
  static const displayName = 'displayName';
  static const email = 'email';
  static const role = 'role';
  static const clubId = 'clubId';
  static const teamIds = 'teamIds';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const teamId = 'teamId';
  static const name = 'name';
  static const ageGroup = 'ageGroup';
  static const coachId = 'coachId'; // legacy
  static const coachIds = 'coachIds';
  static const playerIds = 'playerIds';
  static const eventId = 'eventId';
  static const type = 'type';
  static const startTime = 'startTime';
  static const endTime = 'endTime';
  static const location = 'location';
  static const note = 'note';
  static const createdByUserId = 'createdByUserId';
  static const attendanceId = 'attendanceId';
  static const playerId = 'playerId';
  static const status = 'status';
  static const message = 'message';

  // Chat
  static const conversationId = 'conversationId';
  static const messageId = 'messageId';
  static const senderId = 'senderId';
  static const text = 'text';
  static const participantIds = 'participantIds';
  static const lastMessageText = 'lastMessageText';
  static const lastMessageTime = 'lastMessageTime';
  static const lastMessageSenderId = 'lastMessageSenderId';
  static const count = 'count';
  static const lastReadAt = 'lastReadAt';

  const FirebaseFieldName._();
}
