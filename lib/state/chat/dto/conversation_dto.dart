import 'package:flutter/foundation.dart';

@immutable
class ConversationDto {
  const ConversationDto({
    required this.conversationId,
    required this.type,
    required this.participantIds,
    required this.createdAt,
    this.teamId,
    this.lastMessageText,
    this.lastMessageTime,
    this.lastMessageSenderId,
  });

  final String conversationId;
  final String type; // "direct" or "team"
  final List<String> participantIds;
  final String? teamId;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final DateTime createdAt;

  bool get isTeamChat => type == 'team';
  bool get isDirectChat => type == 'direct';
}
