import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_field_name.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';

class EventStorage {
  const EventStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.events);

  String generateId() => _collection.doc().id;

  Future<void> createEvent(EventDto event) {
    return _collection.doc(event.eventId).set(event.toCreateMap());
  }

  Future<void> updateEvent(EventDto event) {
    return _collection.doc(event.eventId).set(
          event.toUpdateMap(),
          SetOptions(merge: true),
        );
  }

  Future<EventDto?> fetchEvent(String eventId) async {
    try {
      final doc = await _collection.doc(eventId).get();
      if (!doc.exists) return null;
      return EventDto.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch event $eventId: ${e.message}');
      return null;
    }
  }

  Stream<EventDto?> watchEvent(String eventId) {
    return _collection.doc(eventId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return EventDto.fromDocument(doc);
    });
  }

  Stream<List<EventDto>> watchEventsForTeams(List<String> teamIds) {
    if (teamIds.isEmpty) {
      return Stream.value(const []);
    }

    return _collection
        .where(FirebaseFieldName.teamId, whereIn: teamIds)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventDto.fromDocument(doc)).toList());
  }
}
