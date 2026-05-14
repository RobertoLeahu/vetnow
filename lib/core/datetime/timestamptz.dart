/// Parses a Postgres `timestamptz` from Supabase / PostgREST JSON.
///
/// If the string has no explicit timezone (`Z` or `±HH:mm` at the end),
/// [DateTime.parse] treats it as **local** wall time, but the database
/// stores UTC — e.g. 09:30 Madrid is stored as `07:30:00` without `Z` and
/// would display as 07:30. This helper treats those naive strings as UTC
/// instants and returns [DateTime] in the device timezone.
DateTime parseTimestamptzToLocal(String raw) {
  var s = raw.trim();

  // PostgREST uses a space between date and time; DateTime.parse needs 'T'.
  if (RegExp(r'^\d{4}-\d{2}-\d{2} \d').hasMatch(s)) {
    s = s.replaceFirst(' ', 'T', 10);
  }

  // Dart's DateTime.parse only understands ±HH:MM, not bare ±HH.
  // Supabase sends "+00", "+02", etc. — expand to "+00:00", "+02:00".
  final bareOffset = RegExp(r'([+-])(\d{2})$');
  if (bareOffset.hasMatch(s)) {
    s = s.replaceFirstMapped(bareOffset, (m) => '${m[1]}${m[2]}:00');
  }

  final parsed = DateTime.parse(s);
  if (parsed.isUtc) return parsed.toLocal();

  // After normalization DateTime.parse should have recognised the zone,
  // but as a safety net keep the naive-string-as-UTC fallback.
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).toLocal();
}

/// [scheduled_at] / similar columns: PostgREST may send a [String] or a
/// decoded [DateTime]. Ensures a **local** [DateTime] for UI ([DateFormat]
/// shows UTC wall clock when [DateTime.isUtc] is true).
DateTime parseScheduledAtColumn(dynamic raw) {
  if (raw is DateTime) {
    return raw.isUtc ? raw.toLocal() : raw;
  }
  if (raw is String) {
    final local = parseTimestamptzToLocal(raw);
    return local.isUtc ? local.toLocal() : local;
  }
  throw FormatException(
    'Expected String or DateTime for timestamptz, got ${raw.runtimeType}: $raw',
  );
}
