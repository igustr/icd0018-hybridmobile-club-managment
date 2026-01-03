import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/message_dto.dart';

class MessageMapper {
  const MessageMapper._();

  static MessageDto fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MessageDto(
      messageId: data[FirebaseFieldName.messageId] as String? ?? doc.id,
      conversationId: data[FirebaseFieldName.conversationId] as String? ?? '',
      senderId: data[FirebaseFieldName.senderId] as String? ?? '',
      text: data[FirebaseFieldName.text] as String? ?? '',
      createdAt: _asDate(data[FirebaseFieldName.createdAt]) ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toCreateMap(MessageDto message) => {
        FirebaseFieldName.messageId: message.messageId,
        FirebaseFieldName.conversationId: message.conversationId,
        FirebaseFieldName.senderId: message.senderId,
        FirebaseFieldName.text: message.text,
        FirebaseFieldName.createdAt: Timestamp.fromDate(message.createdAt),
      };

  static DateTime? _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
