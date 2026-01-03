import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';

class UnreadStorage {
  const UnreadStorage();

  CollectionReference<Map<String, dynamic>> _unreadCollection(String userId) =>
      FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .doc(userId)
          .collection('unread');

  Future<void> incrementUnread(
    String conversationId,
    List<String> userIds,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final userId in userIds) {
      final docRef = _unreadCollection(userId).doc(conversationId);
      batch.set(
        docRef,
        {
          FirebaseFieldName.conversationId: conversationId,
          FirebaseFieldName.count: FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> markAsRead(String userId, String conversationId) async {
    try {
      await _unreadCollection(userId).doc(conversationId).set({
        FirebaseFieldName.conversationId: conversationId,
        FirebaseFieldName.count: 0,
        FirebaseFieldName.lastReadAt: Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Failed to mark as read: ${e.message}');
    }
  }

  Stream<Map<String, int>> watchUnreadCounts(String userId) {
    return _unreadCollection(userId).snapshots().map((snapshot) {
      final Map<String, int> counts = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final count = data[FirebaseFieldName.count] as int? ?? 0;
        if (count > 0) {
          counts[doc.id] = count;
        }
      }
      return counts;
    });
  }

  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final snapshot = await _unreadCollection(userId).get();
      int total = 0;
      for (final doc in snapshot.docs) {
        final count = doc.data()[FirebaseFieldName.count] as int? ?? 0;
        total += count;
      }
      return total;
    } on FirebaseException catch (e) {
      debugPrint('Failed to get unread count: ${e.message}');
      return 0;
    }
  }
}
