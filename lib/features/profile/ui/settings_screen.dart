import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar mi cuenta'),
        content: const Text(
          'Esta acción eliminará tus datos personales y cerrará tu sesión. '
          'No se puede deshacer.\n\n¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Eliminar cuenta',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(authRepositoryProvider).deleteCurrentAccount();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar la cuenta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                  label: 'Cuenta',
                  onTap: () => context.push('/profile/settings/account'),
                ),
                const _SettingsMenuItem(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                ),
                _SettingsMenuItem(
                  icon: Icons.tune_rounded,
                  label: 'Personalización',
                  onTap: () =>
                      context.push('/profile/settings/personalization'),
                ),
                const _SettingsMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política y privacidad',
                ),
                _SettingsMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Eliminar mi cuenta',
                  onTap: () => _handleDeleteAccount(context, ref),
                ),
                _SettingsMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  onTap: () => _handleSignOut(context, ref),
                ),
                const _SettingsMenuItem(
                  icon: Icons.flag_outlined,
                  label: 'Cambiar el país',
                  trailingText: 'ES',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 18),
            child: Text(
              'App version: 5.271.0',
              style: TextStyle(
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
  final String? trailingText;
  final VoidCallback? onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    this.trailingText,
    this.onTap,
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
          onTap: onTap ?? () {},
        ),
        const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}
