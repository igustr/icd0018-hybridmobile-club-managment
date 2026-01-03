import 'package:flutter/material.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
    this.avatarText,
    this.avatarIcon,
    this.unreadCount = 0,
    this.isTeamChat = false,
  });

  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onTap;
  final String? avatarText;
  final IconData? avatarIcon;
  final int unreadCount;
  final bool isTeamChat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isTeamChat
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : Colors.grey[300],
                radius: 24,
                child: avatarIcon != null
                    ? Icon(
                        avatarIcon,
                        color: isTeamChat
                            ? AppColors.primaryBlue
                            : Colors.grey[600],
                      )
                    : Text(
                        avatarText ?? '?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isTeamChat
                              ? AppColors.primaryBlue
                              : Colors.grey[700],
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 15,
                              color: unreadCount > 0
                                  ? Colors.black
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: unreadCount > 0
                                ? AppColors.primaryBlue
                                : Colors.grey[500],
                            fontWeight: unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey[500],
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
