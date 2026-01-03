import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/attendance_status.dart';
import 'package:icd0018_hybridmobile_club_managment/state/auth/providers/authentication_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/providers/unread_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/home/providers/home_data_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/attendance/event_attendance_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/chat_list_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/conversation_view.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/providers/conversations_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';
import 'package:icd0018_hybridmobile_club_managment/views/schedule/schedule_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/team/team_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authenticationProvider.notifier).logOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    final pages = <Widget>[
      _HomeContent(
        onNavigateToTeam: () => _onNavTap(2),
        onNavigateToSchedule: () => _onNavTap(1),
      ),
      const ScheduleView(),
      const TeamView(),
      const ChatListView(),
    ];

    final titles = ['Home', 'Schedule', 'Team', 'Chat'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                user?.displayName.isNotEmpty == true
                    ? user!.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider);
    final attentionCount = ref.watch(eventsNeedingAttentionCountProvider);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: attentionCount > 0,
            label: Text(
              '$attentionCount',
              style: const TextStyle(fontSize: 10),
            ),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.home_rounded),
          ),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.schedule_rounded),
          label: 'Schedule',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Team',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: const TextStyle(fontSize: 10),
            ),
            child: const Icon(Icons.chat_bubble_rounded),
          ),
          label: 'Chat',
        ),
      ],
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.onNavigateToTeam,
    required this.onNavigateToSchedule,
  });

  final VoidCallback onNavigateToTeam;
  final VoidCallback onNavigateToSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please sign in'));
        }

        final isCoach = user.role.toLowerCase() == 'coach';

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingEventsWithAttendanceProvider);
            ref.invalidate(upcomingEventsWithStatsProvider);
          },
          child: isCoach
              ? _CoachHomeContent(
                  user: user,
                  onNavigateToTeam: onNavigateToTeam,
                  onNavigateToSchedule: onNavigateToSchedule,
                )
              : _PlayerHomeContent(
                  user: user,
                  onNavigateToTeam: onNavigateToTeam,
                ),
        );
      },
    );
  }
}

// ============ PLAYER HOME ============

class _PlayerHomeContent extends ConsumerWidget {
  const _PlayerHomeContent({required this.user, required this.onNavigateToTeam});

  final UserDto user;
  final VoidCallback onNavigateToTeam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsWithAttendanceProvider);
    final statsAsync = ref.watch(playerAttendanceStatsProvider);
    final conversationsAsync = ref.watch(conversationsForUserProvider);
    final teamsAsync = ref.watch(teamsForCurrentUserProvider);
    final teams = teamsAsync.valueOrNull ?? [];

    // Show waiting message if user has no team
    if (teamsAsync.hasValue && teams.isEmpty) {
      return const _WaitingForTeamCard();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player attendance stats
          _PlayerStatsCard(statsAsync: statsAsync),
          const SizedBox(height: 16),

          // Attendance alerts
          upcomingAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (events) {
              final needsAttention =
                  events.where((e) => e.needsAttention).toList();
              if (needsAttention.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AttentionWarningCard(count: needsAttention.length),
              );
            },
          ),

          // Team chats section
          _TeamChatsSection(
            conversationsAsync: conversationsAsync,
            teams: teams,
          ),

          // Upcoming events list
          upcomingAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (events) {
              if (events.isEmpty) {
                return _NoEventsCard(onNavigateToTeam: onNavigateToTeam);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Upcoming Events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...events.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlayerEventCard(eventData: e),
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlayerStatsCard extends StatelessWidget {
  const _PlayerStatsCard({required this.statsAsync});

  final AsyncValue<PlayerAttendanceStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.totalPastEvents == 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.insert_chart, color: Colors.white70, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your attendance stats will appear here after events',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          );
        }

        final percentage = (stats.attendanceRate * 100).round();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Attendance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Big percentage
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Stats breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatRow(
                          icon: Icons.check_circle,
                          label: 'Attended',
                          value: stats.attended,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 6),
                        _StatRow(
                          icon: Icons.cancel,
                          label: 'Missed',
                          value: stats.missed,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 6),
                        _StatRow(
                          icon: Icons.help,
                          label: 'Maybe',
                          value: stats.maybe,
                          color: Colors.amberAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${stats.totalPastEvents} total events',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TeamChatsSection extends StatelessWidget {
  const _TeamChatsSection({
    required this.conversationsAsync,
    required this.teams,
  });

  final AsyncValue conversationsAsync;
  final List<TeamDto> teams;

  @override
  Widget build(BuildContext context) {
    return conversationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (conversations) {
        final teamChats = (conversations as List)
            .where((c) => c.isTeamChat == true)
            .toList();

        if (teamChats.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Chats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...teamChats.map((conv) {
              final team = teams.where((t) => t.teamId == conv.teamId).firstOrNull;
              final teamName = team?.name ?? 'Team Chat';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TeamChatCard(
                  conversation: conv,
                  teamName: teamName,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _TeamChatCard extends StatelessWidget {
  const _TeamChatCard({
    required this.conversation,
    required this.teamName,
  });

  final dynamic conversation;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationView(
              conversation: conversation,
              title: teamName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessageText ?? 'No messages yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionWarningCard extends StatelessWidget {
  const _AttentionWarningCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count event${count > 1 ? 's' : ''} starting soon need${count == 1 ? 's' : ''} your response',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerEventCard extends StatelessWidget {
  const _PlayerEventCard({required this.eventData});

  final UpcomingEventWithAttendance eventData;

  @override
  Widget build(BuildContext context) {
    final event = eventData.event;
    final status = AttendanceStatusExtension.fromString(
      eventData.myAttendance?.status,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: eventData.needsAttention
            ? Border.all(color: Colors.orange.shade300, width: 2)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: _getEventColor(event.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatEventType(event.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateShort(event.startTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, color: status.color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: eventData.needsAttention
                    ? Colors.orange.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                eventData.needsAttention ? 'Respond!' : 'Pending',
                style: TextStyle(
                  color: eventData.needsAttention
                      ? Colors.orange.shade700
                      : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============ COACH HOME ============

class _CoachHomeContent extends ConsumerWidget {
  const _CoachHomeContent({
    required this.user,
    required this.onNavigateToTeam,
    required this.onNavigateToSchedule,
  });

  final UserDto user;
  final VoidCallback onNavigateToTeam;
  final VoidCallback onNavigateToSchedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(upcomingEventsWithStatsProvider);
    final lastEventAsync = ref.watch(lastPastEventWithStatsProvider);
    final teamsAsync = ref.watch(teamsForCurrentUserProvider);
    final conversationsAsync = ref.watch(conversationsForUserProvider);
    final teams = teamsAsync.valueOrNull ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance overview first (or last event stats if no upcoming)
          statsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (events) {
              if (events.isEmpty) {
                // Show last event stats if no upcoming events
                return lastEventAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (lastEvent) {
                    if (lastEvent == null) {
                      return const SizedBox.shrink();
                    }
                    final team = teams.where(
                      (t) => t.teamId == lastEvent.event.teamId,
                    ).firstOrNull;
                    return _LastEventStats(stats: lastEvent, team: team);
                  },
                );
              }
              return _CoachQuickStats(events: events);
            },
          ),
          const SizedBox(height: 16),

          // Team chats section
          _TeamChatsSection(
            conversationsAsync: conversationsAsync,
            teams: teams,
          ),

          // Upcoming events with attendance
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (events) {
              if (events.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _GoToTeamCard(onTap: onNavigateToTeam),
                    const SizedBox(height: 16),
                    _NoEventsCard(
                      isCoach: true,
                      onAddSession: onNavigateToSchedule,
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Upcoming Events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...events.map((e) {
                    final team = teams.where(
                      (t) => t.teamId == e.event.teamId,
                    ).firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CoachEventCard(stats: e, team: team),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CoachQuickStats extends StatelessWidget {
  const _CoachQuickStats({required this.events});

  final List<EventAttendanceStats> events;

  @override
  Widget build(BuildContext context) {
    final totalComing = events.fold(0, (sum, e) => sum + e.coming);
    final totalNotComing = events.fold(0, (sum, e) => sum + e.notComing);
    final totalMaybe = events.fold(0, (sum, e) => sum + e.maybe);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBubble(
                icon: Icons.check_circle,
                value: totalComing,
                label: 'Coming',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatBubble(
                icon: Icons.cancel,
                value: totalNotComing,
                label: 'Not coming',
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _StatBubble(
                icon: Icons.help,
                value: totalMaybe,
                label: 'Maybe',
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${events.length} upcoming event${events.length > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastEventStats extends StatelessWidget {
  const _LastEventStats({required this.stats, this.team});

  final EventAttendanceStats stats;
  final TeamDto? team;

  @override
  Widget build(BuildContext context) {
    final event = stats.event;
    final dateStr = '${event.startTime.day}/${event.startTime.month}/${event.startTime.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Event Statistics',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatEventType(event.type)} - $dateStr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          if (team != null) ...[
            Text(
              team!.name,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBubble(
                icon: Icons.check_circle,
                value: stats.coming,
                label: 'Came',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _StatBubble(
                icon: Icons.cancel,
                value: stats.notComing,
                label: 'Missed',
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _StatBubble(
                icon: Icons.help,
                value: stats.maybe,
                label: 'Maybe',
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachEventCard extends StatelessWidget {
  const _CoachEventCard({
    required this.stats,
    this.team,
  });

  final EventAttendanceStats stats;
  final TeamDto? team;

  @override
  Widget build(BuildContext context) {
    final event = stats.event;
    final total = stats.coming + stats.notComing + stats.maybe;

    return GestureDetector(
      onTap: team != null
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventAttendanceView(
                    event: event,
                    team: team!,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: _getEventColor(event.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatEventType(event.type),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDateShort(event.startTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$total responses',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  if (stats.coming > 0)
                    Expanded(
                      flex: stats.coming,
                      child: Container(height: 6, color: Colors.green),
                    ),
                  if (stats.maybe > 0)
                    Expanded(
                      flex: stats.maybe,
                      child: Container(height: 6, color: Colors.amber),
                    ),
                  if (stats.notComing > 0)
                    Expanded(
                      flex: stats.notComing,
                      child: Container(height: 6, color: Colors.red),
                    ),
                  if (total == 0)
                    Expanded(
                      child: Container(height: 6, color: Colors.grey.shade200),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttendanceChip(
                  icon: Icons.check_circle,
                  count: stats.coming,
                  color: Colors.green,
                ),
                _AttendanceChip(
                  icon: Icons.help,
                  count: stats.maybe,
                  color: Colors.amber,
                ),
                _AttendanceChip(
                  icon: Icons.cancel,
                  count: stats.notComing,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  const _AttendanceChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============ SHARED COMPONENTS ============

class _WaitingForTeamCard extends StatelessWidget {
  const _WaitingForTeamCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Team Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wait until your coach adds you to a team',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoToTeamCard extends StatelessWidget {
  const _GoToTeamCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.group,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View and manage your team',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoEventsCard extends StatelessWidget {
  const _NoEventsCard({
    this.isCoach = false,
    this.onAddSession,
    this.onNavigateToTeam,
  });

  final bool isCoach;
  final VoidCallback? onAddSession;
  final VoidCallback? onNavigateToTeam;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCoach
                  ? 'Schedule a training or match'
                  : 'Check back later for new events',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isCoach && onAddSession != null)
              ElevatedButton.icon(
                onPressed: onAddSession,
                icon: const Icon(Icons.add),
                label: const Text('Add Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              )
            else if (onNavigateToTeam != null)
              OutlinedButton.icon(
                onPressed: onNavigateToTeam,
                icon: const Icon(Icons.group),
                label: const Text('Go to Team'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============ HELPERS ============

String _formatEventType(String type) {
  switch (type.toLowerCase()) {
    case 'training':
      return 'Training';
    case 'match':
      return 'Match';
    case 'meeting':
      return 'Meeting';
    default:
      return type[0].toUpperCase() + type.substring(1);
  }
}

String _formatDateShort(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final eventDay = DateTime(dt.year, dt.month, dt.day);

  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');

  if (eventDay == today) {
    return 'Today, $hour:$minute';
  } else if (eventDay == tomorrow) {
    return 'Tomorrow, $hour:$minute';
  }

  final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${weekdays[dt.weekday - 1]} ${dt.day}/${dt.month}, $hour:$minute';
}

Color _getEventColor(String type) {
  switch (type.toLowerCase()) {
    case 'training':
      return AppColors.primaryBlue;
    case 'match':
      return Colors.green;
    case 'meeting':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

IconData _getEventIcon(String type) {
  switch (type.toLowerCase()) {
    case 'training':
      return Icons.fitness_center;
    case 'match':
      return Icons.sports_soccer;
    case 'meeting':
      return Icons.groups;
    default:
      return Icons.event;
  }
}
