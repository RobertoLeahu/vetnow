import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n_ext.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _deletingAccount = false;

  Future<void> _handleSignOut(BuildContext context) async {
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

    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        showAppError(context, e);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
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

    setState(() => _deletingAccount = true);

    try {
      await ref.read(authRepositoryProvider).deleteCurrentAccount();
      ref.invalidate(authStateProvider);
      ref.invalidate(profileProvider);
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        showAppError(context, e);
      }
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.settingsTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _deletingAccount ? null : () => Navigator.of(context).pop(),
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
                      enabled: !_deletingAccount,
                      onTap: () => context.push('/profile/settings/account'),
                    ),
                    _SettingsMenuItem(
                      icon: Icons.description_outlined,
                      label: l10n.termsAndConditions,
                      enabled: !_deletingAccount,
                      onTap: () => context.push('/legal/terms'),
                    ),
                    _SettingsMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: l10n.privacyAndPolicy,
                      enabled: !_deletingAccount,
                      onTap: () => context.push('/legal/privacy'),
                    ),
                    _SettingsMenuItem(
                      icon: Icons.tune_rounded,
                      label: l10n.personalization,
                      enabled: !_deletingAccount,
                      onTap: () =>
                          context.push('/profile/settings/personalization'),
                    ),
                    _SettingsMenuItem(
                      icon: Icons.logout_rounded,
                      label: l10n.signOut,
                      enabled: !_deletingAccount,
                      onTap: () => _handleSignOut(context),
                    ),
                    _SettingsMenuItem(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.deleteMyAccount,
                      enabled: !_deletingAccount,
                      onTap: () => _handleDeleteAccount(context),
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
        ),
        if (_deletingAccount)
          const ModalBarrier(dismissible: false, color: Colors.black26),
        if (_deletingAccount)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          enabled: enabled,
          leading: Icon(icon, color: AppTheme.textSecondary),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 20 - 4,
              color: AppTheme.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          onTap: enabled ? onTap : null,
        ),
        const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}
