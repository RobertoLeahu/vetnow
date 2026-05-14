/// Parses a Postgres `timestamptz` from Supabase / PostgREST JSON.
///
/// If the string has no explicit timezone (`Z` or `±HH:mm` at the end),
/// [DateTime.parse] treats it as **local** wall time, but the database
/// stores UTC — e.g. 09:30 Madrid is stored as `07:30:00` without `Z` and
/// would display as 07:30. This helper treats those naive strings as UTC
/// instants and returns [DateTime] in the device timezone.
DateTime parseTimestamptzToLocal(String raw) {
  final s = raw.trim();
  final parsed = DateTime.parse(s);
  if (parsed.isUtc) return parsed.toLocal();

  final hasExplicitZone =
      s.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(s);
  if (hasExplicitZone) return parsed.toLocal();

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
