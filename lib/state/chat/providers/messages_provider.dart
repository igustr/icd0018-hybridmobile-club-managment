import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/message_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/message_dto.dart';

final messagesForConversationProvider =
    StreamProvider.autoDispose.family<List<MessageDto>, String>(
  (ref, conversationId) {
    const storage = MessageStorage();
    return storage.watchMessagesForConversation(conversationId);
  },
);
