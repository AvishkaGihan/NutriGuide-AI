import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriguide/core/theme/colors.dart';
import 'package:nutriguide/features/auth/presentation/providers/auth_provider.dart'; // For logout
import 'package:nutriguide/features/profile/presentation/providers/profile_provider.dart';
import 'package:nutriguide/features/profile/presentation/widgets/preference_editor.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'This will permanently delete your data in 30 days. This action cannot be undone immediately.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(profileProvider.notifier).deleteAccount();
      if (success && mounted) {
        _handleLogout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account scheduled for deletion.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(profile.email,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Preferences Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dietary Preferences',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (!_isEditing)
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isEditing)
                  PreferenceEditor(
                    currentProfile: profile,
                    onCancel: () => setState(() => _isEditing = false),
                    onSave: (updatedProfile) async {
                      await ref
                          .read(profileProvider.notifier)
                          .updatePreferences(updatedProfile);
                      setState(() => _isEditing = false);
                    },
                  )
                else
                  _buildSummaryCard(profile),

                const SizedBox(height: 48),
                const Divider(),

                // Account Settings
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download),
                  title: const Text('Export My Data'),
                  onTap: () {
                    // Trigger export logic
                    ref.read(profileProvider.notifier).exportData();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export started...')));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Delete Account',
                      style: TextStyle(color: AppColors.error)),
                  onTap: _handleDeleteAccount,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Goal', profile.dietaryGoals?.join(', ') ?? 'None'),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Restrictions', profile.restrictions?.join(', ') ?? 'None'),
            const SizedBox(height: 12),
            _buildInfoRow('Allergies', profile.allergies?.join(', ') ?? 'None'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
