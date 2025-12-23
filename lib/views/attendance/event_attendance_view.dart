import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/attendance_status.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/dto/attendance_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/attendance/providers/attendance_providers.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/players_for_team_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';

class EventAttendanceView extends ConsumerWidget {
  const EventAttendanceView({
    super.key,
    required this.event,
    required this.team,
  });

  final EventDto event;
  final TeamDto team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersForTeamProvider(team.teamId));
    final attendanceAsync = ref.watch(attendanceForEventProvider(event.eventId));

    final safeType = event.type.isNotEmpty ? event.type : 'event';
    final title = safeType[0].toUpperCase() + safeType.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Attendance'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventHeader(event: event, title: title, teamName: team.name),
          const Divider(height: 1),
          Expanded(
            child: playersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load players: $e')),
              data: (players) {
                if (players.isEmpty) {
                  return const Center(
                    child: Text('No players in this team yet.'),
                  );
                }

                final attendanceList = attendanceAsync.valueOrNull ?? [];
                final attendanceMap = {
                  for (final a in attendanceList) a.playerId: a
                };

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final attendance = attendanceMap[player.userId];
                    return _PlayerAttendanceTile(
                      player: player,
                      attendance: attendance,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  const _EventHeader({
    required this.event,
    required this.title,
    required this.teamName,
  });

  final EventDto event;
  final String title;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateStr = localizations.formatMediumDate(event.startTime);
    final timeStr = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.startTime),
      alwaysUse24HourFormat: true,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title - $teamName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateStr at $timeStr',
            style: TextStyle(color: Colors.grey[700]),
          ),
          if ((event.location ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  event.location!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerAttendanceTile extends StatefulWidget {
  const _PlayerAttendanceTile({
    required this.player,
    required this.attendance,
  });

  final UserDto player;
  final AttendanceDto? attendance;

  @override
  State<_PlayerAttendanceTile> createState() => _PlayerAttendanceTileState();
}

class _PlayerAttendanceTileState extends State<_PlayerAttendanceTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final status = AttendanceStatusExtension.fromString(widget.attendance?.status);
    final hasReason = (widget.attendance?.message ?? '').isNotEmpty;
    final canExpand = hasReason &&
        (status == AttendanceStatus.notComing || status == AttendanceStatus.maybe);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: canExpand
            ? () => setState(() => _isExpanded = !_isExpanded)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: status?.color.withValues(alpha: 0.2) ?? Colors.grey[200],
                    child: Icon(
                      status?.icon ?? Icons.help_outline,
                      color: status?.color ?? Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.player.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status?.label ?? 'No response',
                          style: TextStyle(
                            color: status?.color ?? Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canExpand)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
            if (_isExpanded && hasReason)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.attendance?.message ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
