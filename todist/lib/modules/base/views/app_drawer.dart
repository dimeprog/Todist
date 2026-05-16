// lib/widgets/custom_drawer.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todist/main.dart';
import 'package:todist/modules/profile/vms/profile_provider.dart';
import 'package:todist/modules/settings/views/settings_page.dart';
import 'package:todist/modules/todos/data/todo_providers.dart';
import '../../auth/view_model/auth_notifier.dart';
import '../../profile/views/profile_page.dart';
import '../../todos/vms/todolist_provider.dart';



class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider).valueOrNull;
    final completed = ref.watch(todoStatsProvider.select((v) => v.completed));
    final pending = ref.watch(todoStatsProvider.select((v) => v.pending));
    final reminder = ref.watch(todoStatsProvider.select((v) => v.reminders));

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      width: 280,
      child: Column(
        children: [
          // Header with User Info
          DrawerHeader(
            decoration: BoxDecoration(
              // color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColorDark.withOpacity(0.9),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: user?.avatarUrl != null
                          ? Image.network(
                              user!.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // User Name
                  Text(
                    user?.fullName ?? 'Guest User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User Email
                  Text(
                    user?.email ?? 'Not signed in',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                  child: Text(
                    'ACCOUNT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey[500],
                    ),
                  ),
                ),

                // Profile Menu Item
                _buildDrawerTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),

                // Settings Menu Item
                _buildDrawerTile(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),

                const Divider(height: 32, thickness: 1),

                // Statistics Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                  child: Text(
                    'STATISTICS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey[500],
                    ),
                  ),
                ),

                // Stats Cards
                _buildStatsTile(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '$completed',
                  color: Colors.green,
                ),
                _buildStatsTile(
                  context,
                  icon: Icons.pending_outlined,
                  label: 'Pending',
                  value: '$pending',
                  color: Colors.orange,
                ),
                _buildStatsTile(
                  context,
                  icon: Icons.notifications_none,
                  label: 'Reminders',
                  value: '$reminder',
                  color: Colors.blue,
                ),

                const Divider(height: 32, thickness: 1),

                // Support Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                  child: Text(
                    'SUPPORT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.grey[500],
                    ),
                  ),
                ),

                // Share App
                _buildDrawerTile(
                  context,
                  icon: Icons.share_outlined,
                  label: 'Share App',
                  onTap: () {
                    _shareApp(context);
                  },
                ),

                // Rate App
                _buildDrawerTile(
                  context,
                  icon: Icons.star_outline,
                  label: 'Rate App',
                  onTap: () {
                    _rateApp(context);
                  },
                ),

                // About
                _buildDrawerTile(
                  context,
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red.shade800, Colors.red.shade900],
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        _showLogoutDialog(context, ref);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version Number
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[700],
      child: const Icon(Icons.person, size: 35, color: Colors.white),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400], size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey[500]),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildStatsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.trending_up, size: 20, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    /// check if i have pending tasks in unsynced if yes ask me if i would discard sync and logout or wait
    final pending = container.read(todoRepositoryProvider).getPending();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 14),
            ),
            if (pending.isNotEmpty)
              Text(
                'You still haave ${pending.length} pending tasks that is yet to but uploaded. By logging out you would lose this data',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              container.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
  }

  void _rateApp(BuildContext context) {
    // Implement rate app functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rate feature coming soon!')));
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Todist',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Todist. All rights reserved.',
      applicationIcon: Icon(
        Icons.checklist_rounded,
        size: 40,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'Todist is a beautiful and powerful todo app that helps you stay organized and productive.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
