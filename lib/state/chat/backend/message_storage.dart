import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/message_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/mapper/message_mapper.dart';

class MessageStorage {
  const MessageStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.messages);

  String generateId() => _collection.doc().id;

  Future<void> createMessage(MessageDto message) {
    return _collection.doc(message.messageId).set(
          MessageMapper.toCreateMap(message),
        );
  }

  Stream<List<MessageDto>> watchMessagesForConversation(String conversationId) {
    return _collection
        .where(FirebaseFieldName.conversationId, isEqualTo: conversationId)
        .orderBy(FirebaseFieldName.createdAt, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageMapper.fromDocument(doc))
            .toList());
  }

  Future<List<MessageDto>> fetchMessages(
    String conversationId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where(FirebaseFieldName.conversationId, isEqualTo: conversationId)
          .orderBy(FirebaseFieldName.createdAt, descending: true)
          .limit(limit);

      if (before != null) {
        query = query.where(
          FirebaseFieldName.createdAt,
          isLessThan: Timestamp.fromDate(before),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MessageMapper.fromDocument(doc))
          .toList()
          .reversed
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch messages: ${e.message}');
      return [];
    }
  }
}
