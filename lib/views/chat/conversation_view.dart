import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/conversation_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/message_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/unread_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/conversation_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/dto/message_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/providers/messages_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/components/message_bubble.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';

class ConversationView extends ConsumerStatefulWidget {
  const ConversationView({
    super.key,
    required this.conversation,
    required this.title,
  });

  final ConversationDto conversation;
  final String title;

  @override
  ConsumerState<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends ConsumerState<ConversationView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Map<String, UserDto> _userCache = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _loadParticipants();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    const storage = UnreadStorage();
    await storage.markAsRead(user.userId, widget.conversation.conversationId);
  }

  Future<void> _loadParticipants() async {
    const storage = UserStorage();
    final users = await storage.fetchUsersByIds(
      widget.conversation.participantIds,
    );

    if (mounted) {
      setState(() {
        _userCache = {for (final u in users) u.userId: u};
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSending = true);
    _textController.clear();

    try {
      const messageStorage = MessageStorage();
      const conversationStorage = ConversationStorage();
      const unreadStorage = UnreadStorage();

      final messageId = messageStorage.generateId();
      final message = MessageDto(
        messageId: messageId,
        conversationId: widget.conversation.conversationId,
        senderId: user.userId,
        text: text,
        createdAt: DateTime.now(),
      );

      await messageStorage.createMessage(message);
      await conversationStorage.updateLastMessage(
        widget.conversation.conversationId,
        message,
      );

      // Increment unread for other participants
      final otherParticipants = widget.conversation.participantIds
          .where((id) => id != user.userId)
          .toList();
      if (otherParticipants.isNotEmpty) {
        await unreadStorage.incrementUnread(
          widget.conversation.conversationId,
          otherParticipants,
        );
      }

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesForConversationProvider(widget.conversation.conversationId),
    );
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send the first message!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == currentUser?.userId;
                    final senderName = _userCache[message.senderId]?.displayName;

                    return MessageBubble(
                      text: message.text,
                      time: _formatTime(message.createdAt),
                      isMine: isMine,
                      senderName: senderName,
                      showAvatar: !isMine,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputOrBanner(currentUser),
        ],
      ),
    );
  }

  Widget _buildInputOrBanner(UserDto? currentUser) {
    // For team chats, only coaches can send messages
    if (widget.conversation.isTeamChat) {
      final isCoach = currentUser?.role.toLowerCase() == 'coach';
      if (!isCoach) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Only coaches can send messages here',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }
    }

    return _MessageInput(
      controller: _textController,
      isSending: _isSending,
      onSend: _sendMessage,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}
