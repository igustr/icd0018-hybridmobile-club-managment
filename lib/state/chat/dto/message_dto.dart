import 'package:flutter/foundation.dart';

@immutable
class MessageDto {
  const MessageDto({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String messageId;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
}
