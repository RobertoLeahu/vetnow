import 'package:flutter/material.dart';

import '../../../shared/models/schedule.dart';

/// Convierte `DateTime.weekday` (1=Lunes ... 7=Domingo) a la convención del
/// modelo `Schedule.dayOfWeek` (0=Lunes ... 6=Domingo).
int weekdayToDayOfWeek(DateTime d) => d.weekday - 1;

/// Conjunto de días con horario configurado, en convención 0..6 (lunes..domingo).
Set<int> openDaysFromSchedules(List<Schedule> schedules) =>
    schedules.map((s) => s.dayOfWeek).toSet();

Duration appointmentDurationFromMinutes(int minutes) =>
    Duration(minutes: minutes);

/// Slot ya reservado (inicio + duración de esa cita).
class BookedSlot {
  final DateTime scheduledAt;
  final Duration duration;

  const BookedSlot({
    required this.scheduledAt,
    required this.duration,
  });
}

/// `true` si [slot] solapa con alguna cita ya reservada.
bool isSlotBlocked(
  DateTime slot,
  Duration slotDuration,
  List<BookedSlot> booked,
) {
  final slotEnd = slot.add(slotDuration);
  for (final b in booked) {
    final bookedEnd = b.scheduledAt.add(b.duration);
    if (slot.isBefore(bookedEnd) && b.scheduledAt.isBefore(slotEnd)) {
      return true;
    }
  }
  return false;
}

({int hour, int minute}) _parseHourMinute(String t) {
  final parts = t.split(':');
  return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Genera los slots disponibles para una fecha concreta a partir de los
/// horarios semanales de la clínica.
///
/// Devuelve lista vacía si ese día no tiene horario configurado.
/// Los slots cubren desde `open_time` hasta `close_time` exclusivo, con
/// pasos de [step] (duración configurada por la clínica).
List<DateTime> generateSlotsForDate(
  DateTime date,
  List<Schedule> schedules, {
  required Duration step,
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
    final next = current.add(step);
    if (next.isAfter(end)) break;
    slots.add(current);
    current = next;
  }
  return slots;
}

/// `true` si el día tiene al menos un hueco reservable (horario configurado y,
/// si es hoy, algún slot cuya hora aún no haya pasado).
bool hasBookableSlotsForDate(
  DateTime date,
  List<Schedule> schedules, {
  required Duration step,
}) {
  final slots = generateSlotsForDate(date, schedules, step: step);
  if (slots.isEmpty) return false;

  final now = DateTime.now();
  if (!DateUtils.isSameDay(date, now)) return true;

  return slots.any((slot) {
    final isPast = !slot.isAfter(now) && DateUtils.isSameDay(slot, now);
    return !isPast;
  });
}
