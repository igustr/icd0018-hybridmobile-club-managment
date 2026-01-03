import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/conversation_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/providers/conversations_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/providers/unread_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/components/conversation_tile.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/conversation_view.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsForUserProvider);
    final teamsAsync = ref.watch(teamsForCurrentUserProvider);
    final unreadCounts = ref.watch(unreadCountsProvider).valueOrNull ?? {};

    return conversationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (conversations) {
        final teamChats = conversations.where((c) => c.isTeamChat).toList();
        final directChats = conversations.where((c) => c.isDirectChat).toList();

        if (conversations.isEmpty) {
          return _EmptyChats();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(conversationsForUserProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (teamChats.isNotEmpty) ...[
                _SectionHeader(title: 'Team Chats', count: teamChats.length),
                const SizedBox(height: 8),
                ...teamChats.map((conv) {
                  final team = teamsAsync.valueOrNull
                      ?.firstWhere(
                        (t) => t.teamId == conv.teamId,
                        orElse: () => throw StateError('not found'),
                      );
                  final teamName = team?.name ?? 'Team Chat';
                  return ConversationTile(
                    title: teamName,
                    subtitle: conv.lastMessageText ?? 'No messages yet',
                    time: _formatTime(conv.lastMessageTime),
                    avatarIcon: Icons.groups,
                    isTeamChat: true,
                    unreadCount: unreadCounts[conv.conversationId] ?? 0,
                    onTap: () => _openConversation(context, ref, conv, teamName),
                  );
                }),
                const SizedBox(height: 24),
              ],
              if (directChats.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Direct Messages',
                  count: directChats.length,
                ),
                const SizedBox(height: 8),
                ...directChats.map((conv) {
                  return _DirectChatTile(
                    conversation: conv,
                    unreadCount: unreadCounts[conv.conversationId] ?? 0,
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openConversation(
    BuildContext context,
    WidgetRef ref,
    ConversationDto conversation,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationView(
          conversation: conversation,
          title: title,
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}

class _DirectChatTile extends ConsumerStatefulWidget {
  const _DirectChatTile({
    required this.conversation,
    required this.unreadCount,
  });

  final ConversationDto conversation;
  final int unreadCount;

  @override
  ConsumerState<_DirectChatTile> createState() => _DirectChatTileState();
}

class _DirectChatTileState extends ConsumerState<_DirectChatTile> {
  UserDto? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final otherUserId = widget.conversation.participantIds
        .firstWhere((id) => id != currentUser.userId, orElse: () => '');

    if (otherUserId.isEmpty) return;

    const storage = UserStorage();
    final user = await storage.fetchUser(otherUserId);

    if (mounted) {
      setState(() {
        _otherUser = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final userName = _otherUser?.displayName ?? 'Unknown';
    final avatarText = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return ConversationTile(
      title: userName,
      subtitle: widget.conversation.lastMessageText ?? 'No messages yet',
      time: _formatTime(widget.conversation.lastMessageTime),
      avatarText: avatarText,
      unreadCount: widget.unreadCount,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationView(
              conversation: widget.conversation,
              title: userName,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a chat from the Team tab',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
