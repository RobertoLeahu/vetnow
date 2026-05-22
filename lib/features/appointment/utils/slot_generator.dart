import '../../../shared/models/schedule.dart';

/// Convierte `DateTime.weekday` (1=Lunes ... 7=Domingo) a la convención del
/// modelo `Schedule.dayOfWeek` (0=Lunes ... 6=Domingo).
int weekdayToDayOfWeek(DateTime d) => d.weekday - 1;

/// Conjunto de días con horario configurado, en convención 0..6 (lunes..domingo).
Set<int> openDaysFromSchedules(List<Schedule> schedules) =>
    schedules.map((s) => s.dayOfWeek).toSet();

({int hour, int minute}) _parseHourMinute(String t) {
  final parts = t.split(':');
  return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Duración de cada slot de cita. Debe coincidir con la RPC
/// `complete_past_appointments` en Supabase.
const Duration kAppointmentSlotDuration = Duration(minutes: 30);

/// Genera los slots disponibles para una fecha concreta a partir de los
/// horarios semanales de la clínica.
///
/// Devuelve lista vacía si ese día no tiene horario configurado.
/// Los slots cubren desde `open_time` hasta `close_time` exclusivo, con
/// pasos de `step` (por defecto [kAppointmentSlotDuration]).
List<DateTime> generateSlotsForDate(
  DateTime date,
  List<Schedule> schedules, {
  Duration step = kAppointmentSlotDuration,
}) {
  final dow = weekdayToDayOfWeek(date);

  Schedule? schedule;
  for (final s in schedules) {
    if (s.dayOfWeek == dow) {
      schedule = s;
      break;
    }
  }
  if (schedule == null) return const [];

  final open = _parseHourMinute(schedule.openTime);
  final close = _parseHourMinute(schedule.closeTime);

  final start =
      DateTime(date.year, date.month, date.day, open.hour, open.minute);
  final end =
      DateTime(date.year, date.month, date.day, close.hour, close.minute);

  if (!start.isBefore(end)) return const [];

  final slots = <DateTime>[];
  var current = start;
  while (current.isBefore(end)) {
    slots.add(current);
    current = current.add(step);
  }
  return slots;
}
