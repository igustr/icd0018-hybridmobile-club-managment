import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/conversation_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/message_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/mapper/conversation_mapper.dart';

class ConversationStorage {
  const ConversationStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.conversations);

  String generateId() => _collection.doc().id;

  Future<void> createConversation(ConversationDto conversation) {
    return _collection.doc(conversation.conversationId).set(
          ConversationMapper.toCreateMap(conversation),
        );
  }

  Future<ConversationDto?> fetchConversation(String conversationId) async {
    try {
      final doc = await _collection.doc(conversationId).get();
      if (!doc.exists) return null;
      return ConversationMapper.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch conversation $conversationId: ${e.message}');
      return null;
    }
  }

  Stream<List<ConversationDto>> watchConversationsForUser(String userId) {
    return _collection
        .where(FirebaseFieldName.participantIds, arrayContains: userId)
        .orderBy(FirebaseFieldName.lastMessageTime, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationMapper.fromDocument(doc))
            .toList());
  }

  Future<ConversationDto?> findDirectConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      // Query for direct conversations containing userId1
      final query = await _collection
          .where(FirebaseFieldName.type, isEqualTo: 'direct')
          .where(FirebaseFieldName.participantIds, arrayContains: userId1)
          .get();

      // Filter to find one that also contains userId2
      for (final doc in query.docs) {
        final conversation = ConversationMapper.fromDocument(doc);
        if (conversation.participantIds.contains(userId2)) {
          return conversation;
        }
      }
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Failed to find direct conversation: ${e.message}');
      return null;
    }
  }

  Future<ConversationDto?> findTeamConversation(String teamId) async {
    try {
      // Team chat uses teamId as document ID for uniqueness
      final doc = await _collection.doc('team_$teamId').get();
      if (!doc.exists) return null;
      return ConversationMapper.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to find team conversation: ${e.message}');
      return null;
    }
  }

  Future<ConversationDto> getOrCreateDirectConversation(
    String userId1,
    String userId2,
  ) async {
    final existing = await findDirectConversation(userId1, userId2);
    if (existing != null) return existing;

    final conversationId = generateId();
    final conversation = ConversationDto(
      conversationId: conversationId,
      type: 'direct',
      participantIds: [userId1, userId2],
      createdAt: DateTime.now(),
    );

    await createConversation(conversation);
    return conversation;
  }

  Future<ConversationDto> getOrCreateTeamConversation(
    String teamId,
    List<String> memberIds,
  ) async {
    final existing = await findTeamConversation(teamId);
    if (existing != null) {
      // Update participants if needed (in case team members changed)
      if (!_sameParticipants(existing.participantIds, memberIds)) {
        await _collection.doc('team_$teamId').update({
          FirebaseFieldName.participantIds: memberIds,
        });
      }
      return existing;
    }

    // Use fixed ID based on teamId to prevent duplicates
    final conversationId = 'team_$teamId';
    final conversation = ConversationDto(
      conversationId: conversationId,
      type: 'team',
      teamId: teamId,
      participantIds: memberIds,
      createdAt: DateTime.now(),
    );

    await createConversation(conversation);
    return conversation;
  }

  bool _sameParticipants(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final setA = Set.of(a);
    final setB = Set.of(b);
    return setA.containsAll(setB) && setB.containsAll(setA);
  }

  Future<void> addParticipant(String conversationId, String userId) async {
    await _collection.doc(conversationId).update({
      FirebaseFieldName.participantIds: FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeParticipant(String conversationId, String userId) async {
    await _collection.doc(conversationId).update({
      FirebaseFieldName.participantIds: FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateLastMessage(
    String conversationId,
    MessageDto message,
  ) async {
    await _collection.doc(conversationId).update({
      FirebaseFieldName.lastMessageText: message.text,
      FirebaseFieldName.lastMessageTime: Timestamp.fromDate(message.createdAt),
      FirebaseFieldName.lastMessageSenderId: message.senderId,
    });
  }
}
