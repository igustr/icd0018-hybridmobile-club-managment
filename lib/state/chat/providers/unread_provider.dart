import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/unread_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';

final unreadCountsProvider =
    StreamProvider.autoDispose<Map<String, int>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;

  if (user == null) {
    return const Stream.empty();
  }

  const storage = UnreadStorage();
  return storage.watchUnreadCounts(user.userId);
});

final totalUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final countsAsync = ref.watch(unreadCountsProvider);
  final counts = countsAsync.valueOrNull ?? {};
  return counts.values.fold(0, (sum, count) => sum + count);
});

final unreadCountForConversationProvider =
    Provider.autoDispose.family<int, String>((ref, conversationId) {
  final countsAsync = ref.watch(unreadCountsProvider);
  final counts = countsAsync.valueOrNull ?? {};
  return counts[conversationId] ?? 0;
});
