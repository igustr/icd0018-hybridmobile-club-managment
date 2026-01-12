import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/user_id_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/storage/local_storage_service.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

/// Provider that streams the current user with offline caching support.
///
/// Flow:
/// 1. First emits cached user (if available) for instant loading
/// 2. Streams live updates from Firestore
/// 3. Caches user data locally for offline access
final currentUserProvider = StreamProvider.autoDispose<UserDto?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }

  return _createUserStreamWithCache(userId);
});

/// Creates a stream that combines cached data with live Firestore updates
Stream<UserDto?> _createUserStreamWithCache(String userId) async* {
  final localStorage = LocalStorageService.instance;
  const storage = UserStorage();

  // First, try to emit cached user for instant loading
  try {
    final cachedUser = await localStorage.getCachedUser();
    if (cachedUser != null && cachedUser.userId == userId) {
      debugPrint('Loaded user from cache: ${cachedUser.displayName}');
      yield cachedUser;
    }
  } catch (e) {
    debugPrint('Failed to load cached user: $e');
  }

  // Then stream live updates from Firestore and cache them
  await for (final user in storage.watchUser(userId)) {
    if (user != null) {
      // Cache the fresh user data
      try {
        await localStorage.cacheUser(user);
      } catch (e) {
        debugPrint('Failed to cache user update: $e');
      }
    }
    yield user;
  }
}
