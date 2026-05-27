import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_ext.dart';
import '../../auth/providers/auth_provider.dart';

class ClinicProfileMenuScreen extends ConsumerWidget {
  const ClinicProfileMenuScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMyClinic),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/clinic-profile/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          _ClinicMenuItem(
            icon: Icons.calendar_month_rounded,
            label: 'Mi Agenda',
            onTap: () => context.go('/clinic-agenda'),
          ),
          _ClinicMenuItem(
            icon: Icons.people_rounded,
            label: 'Mis Pacientes',
            onTap: () => context.go('/clinic-patients'),
          ),
          _ClinicMenuItem(
            icon: Icons.store_rounded,
            label: 'Configurar clínica',
            onTap: () => context.push('/clinic-profile/edit'),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _handleSignOut(context, ref),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: Text(l10n.signOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ClinicMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
          title: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondary,
          ),
          onTap: onTap,
        ),
        const Divider(color: AppTheme.divider, height: 1),
      ],
    );
  }
}
