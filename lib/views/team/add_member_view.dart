import 'package:flutter/material.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/backend/team_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/teams/dto/team_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/backend/user_storage.dart';
import 'package:icd0018_hybridmobile_club_managment/state/users/dto/user_dto.dart';
import 'package:icd0018_hybridmobile_club_managment/views/constants/app_colors.dart';

class AddMemberView extends StatefulWidget {
  const AddMemberView({super.key, required this.team});

  final TeamDto team;

  @override
  State<AddMemberView> createState() => _AddMemberViewState();
}

class _AddMemberViewState extends State<AddMemberView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserDto? _foundUser;
  bool _isSearching = false;
  bool _isAdding = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _foundUser = null;
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    const storage = UserStorage();
    final user = await storage.findUserByEmail(email);

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _foundUser = user;
      if (user == null) {
        _errorMessage = 'No user found with this email';
      }
    });
  }

  Future<void> _addMember({required bool asCoach}) async {
    if (_foundUser == null) return;

    final userId = _foundUser!.userId;
    final teamId = widget.team.teamId;

    // Check if already in team
    if (widget.team.playerIds.contains(userId) ||
        widget.team.coachIds.contains(userId)) {
      setState(() {
        _errorMessage = 'This user is already in the team';
      });
      return;
    }

    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    try {
      const teamStorage = TeamStorage();
      const userStorage = UserStorage();

      await teamStorage.addMemberToTeam(
        teamId: teamId,
        userId: userId,
        asCoach: asCoach,
      );

      await userStorage.addTeamToUser(userId, teamId);

      if (!mounted) return;

      setState(() {
        _isAdding = false;
        _successMessage =
            '${_foundUser!.displayName} added as ${asCoach ? 'Coach' : 'Player'}';
        _foundUser = null;
        _emailController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
        _errorMessage = 'Failed to add member: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team Member'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to: ${widget.team.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        hintText: 'Enter user email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _searchUser(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSearching ? null : _searchUser,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(56, 56),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_foundUser != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Found user:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _UserFoundCard(
                user: _foundUser!,
                isAdding: _isAdding,
                onAddAsPlayer: () => _addMember(asCoach: false),
                onAddAsCoach: () => _addMember(asCoach: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserFoundCard extends StatelessWidget {
  const _UserFoundCard({
    required this.user,
    required this.isAdding,
    required this.onAddAsPlayer,
    required this.onAddAsCoach,
  });

  final UserDto user;
  final bool isAdding;
  final VoidCallback onAddAsPlayer;
  final VoidCallback onAddAsCoach;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  radius: 28,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Role: ${user.role}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (isAdding)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAddAsPlayer,
                      icon: const Icon(Icons.sports_soccer),
                      label: const Text('Add as Player'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAddAsCoach,
                      icon: const Icon(Icons.sports),
                      label: const Text('Add as Coach'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
