// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env
  await dotenv.load(fileName: ".env");

  // COMPROBACIÓN TEMPORAL:
  print("--- TEST CONFIG ---");
  print("URL: ${dotenv.env['SUPABASE_URL']}");
  print("ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10)}..."); 
  print("-------------------");

  // Inicializar Supabase
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: App()));
}