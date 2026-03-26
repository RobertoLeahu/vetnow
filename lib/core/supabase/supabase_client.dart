import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso global al cliente. Úsalo en todos los repositorios.
final supabase = Supabase.instance.client;