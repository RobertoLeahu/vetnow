import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../app/theme.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personalización',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text(
              'Modo oscuro',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              isDark ? 'Activado' : 'Desactivado',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            value: isDark,
            activeColor: AppTheme.primary,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(height: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}
