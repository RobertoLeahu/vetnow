import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n_ext.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = ref.read(localeProvider).languageCode;

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('es'),
            child: Row(
              children: [
                if (current == 'es')
                  const Icon(Icons.check, color: AppTheme.primary, size: 20),
                if (current == 'es') const SizedBox(width: 8),
                Text(l10n.languageSpanish),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop('en'),
            child: Row(
              children: [
                if (current == 'en')
                  const Icon(Icons.check, color: AppTheme.primary, size: 20),
                if (current == 'en') const SizedBox(width: 8),
                Text(l10n.languageEnglish),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected != null && selected != current) {
      await ref
          .read(localeProvider.notifier)
          .setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final locale = ref.watch(localeProvider);
    final languageLabel = locale.languageCode == 'en'
        ? l10n.languageEnglish
        : l10n.languageSpanish;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.personalization,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            secondary: const Icon(Icons.dark_mode_rounded),
            title: Text(
              l10n.darkMode,
              style: const TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              isDark ? l10n.enabled : l10n.disabled,
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
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.language_rounded),
            title: Text(
              l10n.language,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          const Divider(height: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}
