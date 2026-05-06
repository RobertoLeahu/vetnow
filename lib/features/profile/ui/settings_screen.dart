import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                _SettingsMenuItem(
                  icon: Icons.person_rounded,
                  label: 'Cuenta',
                ),
                _SettingsMenuItem(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                ),
                _SettingsMenuItem(
                  icon: Icons.tune_rounded,
                  label: 'Personalización',
                ),
                _SettingsMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política y privacidad',
                ),
                _SettingsMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Eliminar mi cuenta',
                ),
                _SettingsMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                ),
                _SettingsMenuItem(
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

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    this.trailingText,
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
          onTap: () {},
        ),
        const Divider(height: 1, color: AppTheme.divider),
      ],
    );
  }
}
