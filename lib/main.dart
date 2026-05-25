// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await initializeDateFormatting('es', null);
  await initializeDateFormatting('en', null);

  final savedLocale = await loadSavedLocale();

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) {
          final notifier = LocaleNotifier();
          notifier.setInitial(savedLocale);
          return notifier;
        }),
      ],
      child: const App(),
    ),
  );
}
