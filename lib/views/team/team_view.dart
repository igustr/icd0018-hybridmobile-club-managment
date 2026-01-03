import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/chat/backend/conversation_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/backend/team_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/chat/conversation_view.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';
import 'package:icd0018_hybridmobile_club_managment/views/team/add_member_view.dart';

class TeamView extends ConsumerWidget {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final teamsAsync = ref.watch(teamsForCurrentUserProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please sign in to view teams.'));
        }

        final isCoach = user.role.toLowerCase().trim() == 'coach';

        return teamsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load teams: $e')),
          data: (teams) {
            if (teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No teams yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCoach
                          ? 'Create a team to get started'
                          : 'Ask your coach to add you to a team',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return _TeamRosterView(
              teams: teams,
              user: user,
              isCoach: isCoach,
              ref: ref,
            );
          },
        );
      },
    );
  }
}

class _TeamRosterView extends StatefulWidget {
  const _TeamRosterView({
    required this.teams,
    required this.user,
    required this.isCoach,
    required this.ref,
  });

  final List<TeamDto> teams;
  final UserDto user;
  final bool isCoach;
  final WidgetRef ref;

  @override
  State<_TeamRosterView> createState() => _TeamRosterViewState();
}

class _TeamRosterViewState extends State<_TeamRosterView> {
  late TeamDto _selectedTeam;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.teams.first;
  }

  @override
  void didUpdateWidget(_TeamRosterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If teams list changed, make sure selected team is still valid
    if (!widget.teams.any((t) => t.teamId == _selectedTeam.teamId)) {
      _selectedTeam = widget.teams.first;
    } else {
      // Update selected team with latest data
      _selectedTeam = widget.teams.firstWhere(
        (t) => t.teamId == _selectedTeam.teamId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _RosterList(
      team: _selectedTeam,
      teams: widget.teams,
      isCoach: widget.isCoach,
      ref: widget.ref,
      currentUserId: widget.user.userId,
      onTeamSelected: (team) {
        setState(() {
          _selectedTeam = team;
        });
      },
    );
  }
}

class _RosterList extends StatefulWidget {
  const _RosterList({
    required this.team,
    required this.teams,
    required this.isCoach,
    required this.ref,
    required this.onTeamSelected,
    required this.currentUserId,
  });

  final TeamDto team;
  final List<TeamDto> teams;
  final bool isCoach;
  final WidgetRef ref;
  final ValueChanged<TeamDto> onTeamSelected;
  final String currentUserId;

  @override
  State<_RosterList> createState() => _RosterListState();
}

class _RosterListState extends State<_RosterList> {
  List<UserDto> _coaches = [];
  List<UserDto> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void didUpdateWidget(_RosterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team.teamId != widget.team.teamId ||
        oldWidget.team.coachIds.length != widget.team.coachIds.length ||
        oldWidget.team.playerIds.length != widget.team.playerIds.length) {
      _loadMembers();
    }
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);

    const storage = UserStorage();

    final coaches = await storage.fetchUsersByIds(widget.team.coachIds);
    final players = await storage.fetchUsersByIds(widget.team.playerIds);

    if (mounted) {
      setState(() {
        _coaches = coaches;
        _players = players;
        _isLoading = false;
      });
    }
  }

  void _refreshTeams() {
    widget.ref.invalidate(teamsForCurrentUserProvider);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshTeams();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Roster',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isCoach
                          ? 'Manage your team members'
                          : 'Your teammates',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              if (widget.isCoach)
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddMemberView(team: widget.team),
                      ),
                    );
                    _refreshTeams();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.teams.length > 1)
            _TeamSelector(
              teams: widget.teams,
              selectedTeam: widget.team,
              onTeamSelected: widget.onTeamSelected,
            ),
          if (widget.teams.length > 1) const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_coaches.isEmpty && _players.isEmpty)
            _EmptyRoster(isCoach: widget.isCoach)
          else ...[
            if (_coaches.isNotEmpty) ...[
              _SectionHeader(title: 'Coaches', count: _coaches.length),
              const SizedBox(height: 8),
              ..._coaches.map((coach) => _MemberCard(
                    user: coach,
                    roleLabel: 'Coach',
                    roleColor: AppColors.primaryBlue,
                    isCoach: widget.isCoach,
                    isCoachMember: true,
                    team: widget.team,
                    onChanged: _refreshTeams,
                    ref: widget.ref,
                    currentUserId: widget.currentUserId,
                  )),
              const SizedBox(height: 24),
            ],
            if (_players.isNotEmpty) ...[
              _SectionHeader(title: 'Players', count: _players.length),
              const SizedBox(height: 8),
              ..._players.map((player) => _MemberCard(
                    user: player,
                    roleLabel: 'Player',
                    roleColor: Colors.green,
                    isCoach: widget.isCoach,
                    isCoachMember: false,
                    team: widget.team,
                    onChanged: _refreshTeams,
                    ref: widget.ref,
                    currentUserId: widget.currentUserId,
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _TeamSelector extends StatelessWidget {
  const _TeamSelector({
    required this.teams,
    required this.selectedTeam,
    required this.onTeamSelected,
  });

  final List<TeamDto> teams;
  final TeamDto selectedTeam;
  final ValueChanged<TeamDto> onTeamSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedTeam.teamId,
      decoration: const InputDecoration(
        labelText: 'Select Team',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: teams.map((team) {
        return DropdownMenuItem(
          value: team.teamId,
          child: Text(team.name),
        );
      }).toList(),
      onChanged: (teamId) {
        if (teamId != null) {
          final team = teams.firstWhere((t) => t.teamId == teamId);
          onTeamSelected(team);
        }
      },
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster({required this.isCoach});

  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No members yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (isCoach) ...[
            const SizedBox(height: 8),
            Text(
              'Tap "Add Member" to add players and coaches',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
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

class _MemberCard extends StatefulWidget {
  const _MemberCard({
    required this.user,
    required this.roleLabel,
    required this.roleColor,
    required this.isCoach,
    required this.isCoachMember,
    required this.team,
    required this.onChanged,
    required this.ref,
    required this.currentUserId,
  });

  final UserDto user;
  final String roleLabel;
  final Color roleColor;
  final bool isCoach;
  final bool isCoachMember;
  final TeamDto team;
  final VoidCallback onChanged;
  final WidgetRef ref;
  final String currentUserId;

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _isExpanded = false;
  bool _isLoading = false;

  Future<void> _startChat() async {
    final currentUser = widget.ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    // Don't allow chatting with yourself
    if (currentUser.userId == widget.user.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const storage = ConversationStorage();
      final conversation = await storage.getOrCreateDirectConversation(
        currentUser.userId,
        widget.user.userId,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ConversationView(
              conversation: conversation,
              title: widget.user.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e')),
        );
      }
    }
  }

  Future<void> _removeMember() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove member'),
        content: Text(
          'Are you sure you want to remove ${widget.user.displayName} from ${widget.team.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      const teamStorage = TeamStorage();
      const userStorage = UserStorage();

      await teamStorage.removeMemberFromTeam(
        teamId: widget.team.teamId,
        userId: widget.user.userId,
        isCoach: widget.isCoachMember,
      );

      await userStorage.removeTeamFromUser(
        widget.user.userId,
        widget.team.teamId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.user.displayName} removed from team'),
          ),
        );
        widget.onChanged();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: $e')),
        );
      }
    }
  }

  Future<void> _changeRole() async {
    final newRole = widget.isCoachMember ? 'Player' : 'Coach';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change role'),
        content: Text(
          'Change ${widget.user.displayName} to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      const teamStorage = TeamStorage();

      await teamStorage.changeMemberRole(
        teamId: widget.team.teamId,
        userId: widget.user.userId,
        toCoach: !widget.isCoachMember,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.user.displayName} is now a $newRole'),
          ),
        );
        widget.onChanged();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change role: $e')),
        );
      }
    }
  }

  bool get _isSelf => widget.user.userId == widget.currentUserId;

  // Can expand if not yourself
  bool get _canExpand => !_isSelf;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _canExpand
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.roleColor.withValues(alpha: 0.2),
                    child: Text(
                      widget.user.displayName.isNotEmpty
                          ? widget.user.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: widget.roleColor,
                        fontWeight: FontWeight.bold,
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
                            Text(
                              widget.user.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (_isSelf) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(You)',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.user.email != null &&
                            widget.user.email!.isNotEmpty)
                          Text(
                            widget.user.email!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.roleLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.roleColor,
                      ),
                    ),
                  ),
                  if (_canExpand) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
            if (_canExpand && _isExpanded)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        children: [
                          // Chat button - available to everyone
                          _ActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Chat',
                            color: AppColors.primaryBlue,
                            onTap: _startChat,
                          ),
                          // Coach-only options
                          if (widget.isCoach) ...[
                            const SizedBox(height: 8),
                            _ActionButton(
                              icon: widget.isCoachMember
                                  ? Icons.sports_soccer
                                  : Icons.sports,
                              label: widget.isCoachMember
                                  ? 'Make Player'
                                  : 'Make Coach',
                              color: widget.isCoachMember
                                  ? Colors.green
                                  : AppColors.primaryBlue,
                              onTap: _changeRole,
                            ),
                            const SizedBox(height: 8),
                            _ActionButton(
                              icon: Icons.person_remove,
                              label: 'Remove from team',
                              color: Colors.red,
                              onTap: _removeMember,
                            ),
                          ],
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
