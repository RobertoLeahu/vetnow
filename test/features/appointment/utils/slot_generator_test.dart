import 'package:flutter_test/flutter_test.dart';
import 'package:vetnow/features/appointment/utils/slot_generator.dart';
import 'package:vetnow/shared/models/schedule.dart';

void main() {
  const clinicId = 'clinic-1';

  Schedule scheduleForDay(int dayOfWeek) => Schedule(
        clinicId: clinicId,
        dayOfWeek: dayOfWeek,
        openTime: '09:00:00',
        closeTime: '12:00:00',
      );

  group('isSlotBlocked', () {
    test('T-U3 bloquea solapamiento parcial por duración', () {
      final bookedStart = DateTime(2026, 6, 15, 10, 0);
      final slotStart = DateTime(2026, 6, 15, 10, 30);

      final blocked = isSlotBlocked(
        slotStart,
        const Duration(minutes: 30),
        [
          BookedSlot(
            scheduledAt: bookedStart,
            duration: const Duration(minutes: 60),
          ),
        ],
      );

      expect(blocked, isTrue);
    });

    test('T-U7 no bloquea slot adyacente sin solapar', () {
      final bookedStart = DateTime(2026, 6, 15, 10, 0);
      final slotStart = DateTime(2026, 6, 15, 11, 0);

      final blocked = isSlotBlocked(
        slotStart,
        const Duration(minutes: 30),
        [
          BookedSlot(
            scheduledAt: bookedStart,
            duration: const Duration(minutes: 60),
          ),
        ],
      );

      expect(blocked, isFalse);
    });
  });

  group('generateSlotsForDate', () {
    test('T-U4 devuelve lista vacía en día sin horario', () {
      final mondayOnly = [scheduleForDay(0)];
      final tuesday = DateTime(2026, 6, 16); // weekday 2 → dayOfWeek 1

      final slots = generateSlotsForDate(
        tuesday,
        mondayOnly,
        step: const Duration(minutes: 30),
      );

      expect(slots, isEmpty);
    });

    test('genera slots cada 30 min en día con horario', () {
      final monday = DateTime(2026, 6, 15); // lunes
      final schedules = [scheduleForDay(0)];

      final slots = generateSlotsForDate(
        monday,
        schedules,
        step: const Duration(minutes: 30),
      );

      expect(slots, hasLength(6));
      expect(slots.first, DateTime(2026, 6, 15, 9, 0));
      expect(slots.last, DateTime(2026, 6, 15, 11, 30));
    });

    test('T-U8 con step 90 min no desborda el cierre', () {
      final monday = DateTime(2026, 6, 15);
      final schedules = [scheduleForDay(0)];

      final slots = generateSlotsForDate(
        monday,
        schedules,
        step: const Duration(minutes: 90),
      );

      expect(slots, hasLength(2));
      expect(slots, [
        DateTime(2026, 6, 15, 9, 0),
        DateTime(2026, 6, 15, 10, 30),
      ]);
    });
  });
}
