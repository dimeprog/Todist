// lib/modules/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todist/models/user_model.dart';
import 'package:todist/modules/profile/vms/profile_provider.dart';

import '../../../core/logger.dart';
import '../../todos/vms/todolist_provider.dart';
import '../vms/states/profile_state.dart';
import 'streak_calender.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final nameController = useTextEditingController();
    final isEditing = useState(false);

    void saveChanges() async {
      final newName = nameController.text.trim();
      if (newName.isEmpty) return;

      // Update profile
      final notifier = ref.read(profileActionsProvider.notifier);
      notifier.update(fullName: newName);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (isEditing.value)
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final isLoading =
                    ref.watch(profileActionsProvider) is UpdatingProfile;
                ref.listen(profileActionsProvider, (p, n) {
                  n.maybeWhen(
                    orElse: () {},
                    updated: (user) {
                      isEditing.value = false;
                      // log.d(user.toJson());
                    },
                    updateError: (message) {
                      isEditing.value = !isEditing.value;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    },
                  );
                });
                return isLoading
                    ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : TextButton(
                        onPressed: () {
                          saveChanges();
                        },
                        child: const Text('Save'),
                      );
              },
            ),
        ],
      ),
      body: profileAsync.when(
        data: (user) {
          // Initialize controller with user data when loaded
          if (nameController.text.isEmpty && user.fullName != null) {
            nameController.text = user.fullName ?? '';
          }

          return RefreshIndicator(
            onRefresh: () async {
               return ref
                  .read(profileProvider.future);
                
            },
            child: CustomScrollView(
              slivers: [
                // Header Section with Avatar and Name
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    nameController: nameController,
                    user: user,
                    isEditing: isEditing.value,
                    onSaveChanges: (v) {
                      isEditing.value = v;
                    },
                  ),
                ),
            
                // Streak Section
                SliverToBoxAdapter(
                  child: ProfileSteakSection(
                    currentStreak: user.currentStreak,
                    longestStreak: user.longestStreak,
                    lastStreakDate: user.lastStreakDate,
                  ),
                ),
            
                // Stats Cards
                SliverToBoxAdapter(child: _buildStatsSection(user)),
            
                // Streak Calendar
                SliverToBoxAdapter(child: StreakCalendar(userId: user.id)),
            
                // Profile Information Section
                SliverToBoxAdapter(child: _buildInfoSection(user)),
            
                // Action Buttons
                SliverToBoxAdapter(child: _buildActionButtons(context)),
            
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load profile: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 5 / 4,
        children: [
          _buildStatCard(
            icon: Icons.check_circle_outline,
            value: '${user.totalCompletions}',
            label: 'Tasks Completed',
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.pending_outlined,
            value: '${user.totalCompletions}',
            label: 'Pending Tasks',
            color: Colors.orange,
          ),
          Consumer(
            builder: (_, WidgetRef ref, __) {
              final reminders = ref.watch(
                todoStatsProvider.select((v) => v.reminders),
              );
              return _buildStatCard(
                icon: Icons.notifications_none,
                value: "$reminders",
                label: 'Active Reminders',
                color: Colors.blue,
              );
            },
          ),
          _buildStatCard(
            icon: Icons.verified,
            value: '${user.longestStreak}',
            label: 'Best Streak',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email ?? 'Not set',
          ),
          const Divider(),
          _buildInfoTile(
            icon: Icons.calendar_today,
            label: 'Account Created',
            value: _formatDate(user.createdAt),
            // isMonospace: true
          ),
          const Divider(),
          _buildInfoTile(
            icon: Icons.update,
            label: 'Last Updated',
            value: _formatDate(user.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,

    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),

                Text(
                  value,
                  style: isMonospace
                      ? TextStyle(fontFamily: 'monospace', fontSize: 13)
                      : GoogleFonts.poppins(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Delete Account Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeleteAccountDialog(context);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.red.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete account
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Unknown';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  final bool isEditing;
  final TextEditingController nameController;
  final Function(bool)? onSaveChanges;
  const ProfileHeader({
    super.key,
    required this.user,
    required this.isEditing,
    this.onSaveChanges,
    required this.nameController,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarPlaceholder(user),
                        ),
                      )
                    : _buildAvatarPlaceholder(user),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 16),
                    onPressed: () async {
                      onSaveChanges?.call(true);
                      final pickedPath = await _showAvatarOptions(context, ref);
                      if (pickedPath != null) {
                        ref
                            .read(profileActionsProvider.notifier)
                            .updateAvatar(pickedPath);
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Name (editable or display)
          if (isEditing)
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          else
            GestureDetector(
              onTap: () {
                onSaveChanges?.call(true);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.fullName ?? 'Add Your Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 18, color: Colors.grey[500]),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                user.email ?? 'No email',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Member since
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Member since ${_formatDate(user.createdAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showAvatarOptions(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  Navigator.pop(context, pickedFile.path);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  Navigator.pop(context, pickedFile.path);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove photo'),
              onTap: () {
                ref
                    .read(profileActionsProvider.notifier)
                    .update(avatarUrl: null);
                Navigator.pop(context);
                // Implement remove avatar
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserModel user) {
    return Container(
      color: Colors.grey[700],
      child: Center(
        child: Text(
          user.fullName?.isNotEmpty == true
              ? user.fullName![0].toUpperCase()
              : user.email?.isNotEmpty == true
              ? user.email![0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ProfileSteakSection extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakDate;
  const ProfileSteakSection({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStreakDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: currentStreak > 0
              ? [Colors.orange.shade400, Colors.red.shade400]
              : [Colors.grey.shade600, Colors.grey.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            icon: Icons.local_fire_department,
            value: currentStreak,
            label: 'Current Streak',
            color: Colors.orange,
          ),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          _buildStreakItem(
            icon: Icons.emoji_events,
            value: longestStreak,
            label: 'Best Streak',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
