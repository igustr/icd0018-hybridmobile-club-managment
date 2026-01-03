import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/conversation_dto.dart';

class ConversationMapper {
  const ConversationMapper._();

  static ConversationDto fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ConversationDto(
      conversationId: data[FirebaseFieldName.conversationId] as String? ?? doc.id,
      type: data[FirebaseFieldName.type] as String? ?? 'direct',
      participantIds: _asStringList(data[FirebaseFieldName.participantIds]),
      teamId: data[FirebaseFieldName.teamId] as String?,
      lastMessageText: data[FirebaseFieldName.lastMessageText] as String?,
      lastMessageTime: _asDate(data[FirebaseFieldName.lastMessageTime]),
      lastMessageSenderId: data[FirebaseFieldName.lastMessageSenderId] as String?,
      createdAt: _asDate(data[FirebaseFieldName.createdAt]) ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreateMap(ConversationDto conversation) => {
        FirebaseFieldName.conversationId: conversation.conversationId,
        FirebaseFieldName.type: conversation.type,
        FirebaseFieldName.participantIds: conversation.participantIds,
        FirebaseFieldName.teamId: conversation.teamId,
        FirebaseFieldName.lastMessageText: conversation.lastMessageText,
        FirebaseFieldName.lastMessageTime: conversation.lastMessageTime != null
            ? Timestamp.fromDate(conversation.lastMessageTime!)
            : null,
        FirebaseFieldName.lastMessageSenderId: conversation.lastMessageSenderId,
        FirebaseFieldName.createdAt: Timestamp.fromDate(conversation.createdAt),
      };

  static Map<String, dynamic> toUpdateMap(ConversationDto conversation) => {
        FirebaseFieldName.participantIds: conversation.participantIds,
        FirebaseFieldName.lastMessageText: conversation.lastMessageText,
        FirebaseFieldName.lastMessageTime: conversation.lastMessageTime != null
            ? Timestamp.fromDate(conversation.lastMessageTime!)
            : null,
        FirebaseFieldName.lastMessageSenderId: conversation.lastMessageSenderId,
      };

  static DateTime? _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is Iterable) return value.whereType<String>().toList();
    return const [];
  }
}
