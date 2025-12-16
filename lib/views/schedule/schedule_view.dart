import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/providers/clubs_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/backend/event_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/dto/event_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/events/providers/events_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/clubs/dto/club_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/providers/teams_for_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/providers/current_user_provider.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';

class ScheduleView extends ConsumerWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final eventsAsync = ref.watch(eventsForUserProvider);
    final teamsAsync = ref.watch(teamsForCurrentUserProvider);
    final clubsAsync = ref.watch(clubsForCurrentUserProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load user: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Sign in to see your schedule.'));
        }

        final isCoach = _isCoach(user);

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(eventsForUserProvider);
                ref.invalidate(teamsForCurrentUserProvider);
                ref.invalidate(clubsForCurrentUserProvider);
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
                              'Schedule',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCoach
                                  ? 'Manage matches and trainings'
                                  : 'Upcoming events for your teams',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      if (isCoach)
                        _AddEventButton(
                          user: user,
                          teamsAsync: teamsAsync,
                          clubsAsync: clubsAsync,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  eventsAsync.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return _EmptySchedule(isCoach: isCoach);
                      }
                      return Column(
                        children: events
                            .map(
                              (event) => _EventCard(
                                event: event,
                                teamLookup: teamsAsync.valueOrNull ?? const [],
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Could not load events: $e'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddEventButton extends StatelessWidget {
  const _AddEventButton({
    required this.user,
    required this.teamsAsync,
    required this.clubsAsync,
  });

  final UserDto user;
  final AsyncValue<List<TeamDto>> teamsAsync;
  final AsyncValue<Map<String, ClubDto>> clubsAsync;

  @override
  Widget build(BuildContext context) {
    final isLoadingTeams = teamsAsync.isLoading;
    final teams = teamsAsync.valueOrNull ?? const <TeamDto>[];
    final hasTeamsError = teamsAsync.hasError;

    void onPressed() {
      if (!_isCoach(user)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only coaches can create events.'),
          ),
        );
        return;
      }

      if (isLoadingTeams) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading your teams, please try again in a moment.'),
          ),
        );
        return;
      }

      if (hasTeamsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load teams right now.'),
          ),
        );
        return;
      }

      if (teams.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add a team before creating an event.'),
          ),
        );
        return;
      }

      _showCreateEventSheet(
        context,
        user,
        teams,
        clubsAsync.valueOrNull ?? const {},
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('New event'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.teamLookup,
  });

  final EventDto event;
  final List<TeamDto> teamLookup;

  @override
  Widget build(BuildContext context) {
    final teamName = teamLookup
            .firstWhere(
              (team) => team.teamId == event.teamId,
              orElse: () => TeamDto(
                teamId: event.teamId,
                clubId: '',
                name: 'Team ${event.teamId}',
                coachIds: const [],
              ),
            )
            .name;

    final subtitle = _formatDateRange(
      context,
      event.startTime,
      event.endTime,
    );

    final safeType = event.type.isNotEmpty ? event.type : 'event';
    final isTraining = safeType.toLowerCase() == 'training';
    final title = safeType[0].toUpperCase() + safeType.substring(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isTraining ? AppColors.lightBlue : AppColors.skyBlue,
              foregroundColor: AppColors.primaryBlue,
              child: Icon(isTraining ? Icons.fitness_center : Icons.sports_soccer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teamName,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if ((event.location ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location ?? '',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
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

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.isCoach});

  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'There are no upcoming events.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (isCoach) ...[
            const SizedBox(height: 8),
            Text(
              'Use Add event to schedule the next training or match.',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

bool _isCoach(UserDto user) =>
    user.role.trim().toLowerCase() == 'coach';

Future<void> _showCreateEventSheet(
  BuildContext context,
  UserDto user,
  List<TeamDto> teams,
  Map<String, ClubDto> clubs,
) async {
  if (!_isCoach(user)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only coaches can create events.'),
      ),
    );
    return;
  }

  if (teams.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add a team before creating an event.'),
      ),
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _CreateEventForm(
          user: user,
          teams: teams,
          clubs: clubs,
        ),
      );
    },
  );
}

class _CreateEventForm extends StatefulWidget {
  const _CreateEventForm({
    required this.user,
    required this.teams,
    required this.clubs,
  });

  final UserDto user;
  final List<TeamDto> teams;
  final Map<String, ClubDto> clubs;

  @override
  State<_CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<_CreateEventForm> {
  late String _selectedTeamId;
  late String _selectedType;
  late DateTime _startTime;
  DateTime? _endTime;
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.teams.first.teamId;
    _selectedType = 'training';
    _startTime = DateTime.now().add(const Duration(hours: 1));
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeam = widget.teams
        .firstWhere((team) => team.teamId == _selectedTeamId);
    final clubName = widget.clubs[selectedTeam.clubId]?.name ??
        'Club ${selectedTeam.clubId}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTeamId,
            items: widget.teams
                .map(
                  (team) => DropdownMenuItem(
                    value: team.teamId,
                    child: Text(team.name),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Team',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTeamId = value;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Club',
              border: OutlineInputBorder(),
            ),
            child: Text(clubName),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: const [
              DropdownMenuItem(
                value: 'training',
                child: Text('Training'),
              ),
              DropdownMenuItem(
                value: 'match',
                child: Text('Match'),
              ),
            ],
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _DateTimeField(
            label: 'Start',
            value: _startTime,
            onTap: () async {
              final picked = await _pickDateTime(context, _startTime);
              if (picked != null) {
                setState(() {
                  _startTime = picked;
                  if (_endTime != null && _endTime!.isBefore(picked)) {
                    _endTime = picked.add(const Duration(hours: 1));
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _DateTimeField(
            label: 'End (optional)',
            value: _endTime,
            onTap: () async {
              final picked = await _pickDateTime(
                context,
                _endTime ?? _startTime.add(const Duration(hours: 1)),
              );
              if (picked != null) {
                setState(() {
                  _endTime = picked;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _submit(context),
              child: const Text('Create event'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final selectedTeam = widget.teams
        .firstWhere((team) => team.teamId == _selectedTeamId);
    final eventId = const EventStorage().generateId();
    final locationText = _locationController.text.trim();
    final noteText = _noteController.text.trim();

    final event = EventDto(
      eventId: eventId,
      teamId: selectedTeam.teamId,
      type: _selectedType,
      startTime: _startTime,
      endTime: _endTime,
      location: locationText.isNotEmpty ? locationText : null,
      note: noteText.isNotEmpty ? noteText : null,
      createdByUserId: widget.user.userId,
    );

    try {
      await const EventStorage().createEvent(event);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? 'Select'
        : _formatDateRange(context, value!, null);

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(display),
      ),
    );
  }
}

Future<DateTime?> _pickDateTime(
  BuildContext context,
  DateTime initial,
) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime.now().subtract(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

String _formatDateRange(
  BuildContext context,
  DateTime start,
  DateTime? end,
) {
  final localizations = MaterialLocalizations.of(context);
  final startDate = localizations.formatMediumDate(start);
  final startTime = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(start),
    alwaysUse24HourFormat: true,
  );
  if (end == null) {
    return '$startDate • $startTime';
  }
  final endTime = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(end),
    alwaysUse24HourFormat: true,
  );
  return '$startDate • $startTime - $endTime';
}
