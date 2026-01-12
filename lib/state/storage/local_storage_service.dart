import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';

/// Service for caching data locally using SharedPreferences.
/// Provides offline functionality by storing user data on device.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._();
  static LocalStorageService get instance => _instance;

  LocalStorageService._();

  static const String _userKey = 'cached_user';
  static const String _lastSyncKey = 'last_sync_timestamp';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    debugPrint('LocalStorageService initialized');
  }

  /// Ensure prefs is initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  /// Cache user data locally
  Future<void> cacheUser(UserDto user) async {
    try {
      final prefs = await _preferences;
      final userJson = jsonEncode({
        'userId': user.userId,
        'displayName': user.displayName,
        'role': user.role,
        'email': user.email,
        'clubId': user.clubId,
        'teamIds': user.teamIds,
      });
      await prefs.setString(_userKey, userJson);
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('User cached locally: ${user.displayName}');
    } catch (e) {
      debugPrint('Failed to cache user: $e');
    }
  }

  Future<UserDto?> getCachedUser() async {
    try {
      final prefs = await _preferences;
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;

      final Map<String, dynamic> data = jsonDecode(userJson);
      return UserDto(
        userId: data['userId'] as String,
        displayName: data['displayName'] as String,
        role: data['role'] as String,
        email: data['email'] as String?,
        clubId: data['clubId'] as String?,
        teamIds: List<String>.from(data['teamIds'] ?? []),
      );
    } catch (e) {
      debugPrint('Failed to get cached user: $e');
      return null;
    }
  }

  Future<void> clearUserCache() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_userKey);
      await prefs.remove(_lastSyncKey);
      debugPrint('User cache cleared');
    } catch (e) {
      debugPrint('Failed to clear user cache: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _preferences;
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isCacheStale({Duration maxAge = const Duration(hours: 24)}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }
}
