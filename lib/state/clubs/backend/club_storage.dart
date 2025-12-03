import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/dto/club_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/mapper/club_mapper.dart';
import 'package:icd0018_hybridmobile_club_managment/state/constants/firebase_collection_name.dart';

class ClubStorage {
  const ClubStorage();

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(FirebaseCollectionName.clubs);

  Future<void> createClub(ClubDto club) {
    return _collection.doc(club.clubId).set(ClubMapper.toCreateMap(club));
  }

  Future<ClubDto?> fetchClub(String clubId) async {
    try {
      final doc = await _collection.doc(clubId).get();
      if (!doc.exists) return null;
      return ClubMapper.fromDocument(doc);
    } on FirebaseException catch (e) {
      debugPrint('Failed to fetch club $clubId: ${e.message}');
      return null;
    }
  }

  Stream<ClubDto?> watchClub(String clubId) {
    return _collection.doc(clubId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ClubMapper.fromDocument(doc);
    });
  }

  Future<List<ClubDto>> fetchClubsByIds(List<String> clubIds) async {
    if (clubIds.isEmpty) return const [];
    final futures = clubIds.map((id) => _collection.doc(id).get());
    final snapshots = await Future.wait(futures);
    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => ClubMapper.fromDocument(doc))
        .toList();
  }
}
