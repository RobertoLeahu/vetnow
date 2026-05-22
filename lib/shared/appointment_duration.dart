/// Duración por defecto de cada franja de cita (minutos).
const int kDefaultAppointmentDurationMinutes = 30;

/// Opciones configurables en "Mi clínica".
const List<int> kAllowedAppointmentDurationsMinutes = [
  30,
  45,
  60,
  90,
  120,
];

String formatAppointmentDurationLabel(int minutes) {
  if (minutes < 60) return '$minutes minutos';
  if (minutes == 60) return '1 hora';
  if (minutes == 90) return '1 hora 30 min';
  if (minutes == 120) return '2 horas';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h horas';
  return '$h h $m min';
}
