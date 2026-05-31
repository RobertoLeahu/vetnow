import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/onboarding/onboarding_provider.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/models/profile.dart';
import '../../auth/providers/auth_provider.dart';

class ClinicSettingsScreen extends ConsumerWidget {
  const ClinicSettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go('/login');
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMyAccount),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(authRepositoryProvider).deleteCurrentAccount();
    ref.invalidate(authStateProvider);
    ref.invalidate(profileProvider);
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _SettingsMenuItem(
                  icon: Icons.person_rounded,
                  label: l10n.account,
                  onTap: () => context.push('/clinic-profile/settings/account'),
                ),
                _SettingsMenuItem(
                  icon: Icons.description_outlined,
                  label: l10n.termsAndConditions,
                  onTap: () => context.push('/legal/terms'),
                ),
                _SettingsMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.privacyAndPolicy,
                  onTap: () => context.push('/legal/privacy'),
                ),
                _SettingsMenuItem(
                  icon: Icons.tune_rounded,
                  label: l10n.personalization,
                  onTap: () =>
                      context.push('/clinic-profile/settings/personalization'),
                ),
                _SettingsMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: l10n.settingsShowAppGuide,
                  onTap: () async {
                    await replayOnboarding(ref, UserRole.clinic);
                    if (context.mounted) {
                      context.go('/clinic-home');
                    }
                  },
                ),
                _SettingsMenuItem(
                  icon: Icons.logout_rounded,
                  label: l10n.signOut,
                  onTap: () => _handleSignOut(context, ref),
                ),
                _SettingsMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.deleteMyAccount,
                  onTap: () => _handleDeleteAccount(context, ref),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              l10n.appVersionLabel,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Icon(icon, color: AppTheme.textSecondary),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}
