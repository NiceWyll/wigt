import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/time/lima_time.dart';

void main() {
  group('LimaTime.weekDays()', () {
    test('devuelve 7 días comenzando en lunes', () {
      // Lunes 24 noviembre 2026
      final days = LimaTime.weekDays('2026-11-24');
      expect(days.length, 7);
      expect(days[0], '2026-11-23'); // lunes de esa semana
      expect(days[6], '2026-11-29'); // domingo
    });

    test('desde un miércoles sigue siendo lunes a domingo', () {
      // Miércoles 25 noviembre 2026
      final days = LimaTime.weekDays('2026-11-25');
      expect(days.length, 7);
      expect(days[0], '2026-11-23'); // lunes
      expect(days[6], '2026-11-29'); // domingo
    });

    test('desde el domingo devuelve la semana correcta', () {
      // Domingo 29 noviembre 2026
      final days = LimaTime.weekDays('2026-11-29');
      expect(days.length, 7);
      expect(days[0], '2026-11-23'); // lunes
      expect(days[6], '2026-11-29'); // domingo
    });

    test('desde el lunes devuelve exactamente esa semana', () {
      // Lunes 23 noviembre 2026
      final days = LimaTime.weekDays('2026-11-23');
      expect(days.length, 7);
      expect(days[0], '2026-11-23');
      expect(days[6], '2026-11-29');
    });

    test('funciona a través de cambio de mes', () {
      // Jueves 26 noviembre 2026
      final days = LimaTime.weekDays('2026-11-26');
      expect(days[0], '2026-11-23');
      expect(days[6], '2026-11-29');
    });

    test('funciona con cambio de mes diciembre-enero', () {
      // Semana del 28 dic 2026 al 3 ene 2027
      final days = LimaTime.weekDays('2026-12-31');
      expect(days[0], '2026-12-28'); // lunes
      expect(days[6], '2027-01-03'); // domingo
    });
  });

  group('LimaTime.startOfWeek()', () {
    test('lunes → mismo día', () {
      expect(LimaTime.startOfWeek('2026-11-23'), '2026-11-23');
    });
    test('domingo → lunes de esa semana', () {
      expect(LimaTime.startOfWeek('2026-11-29'), '2026-11-23');
    });
    test('miércoles → lunes de esa semana', () {
      expect(LimaTime.startOfWeek('2026-11-25'), '2026-11-23');
    });
  });

  group('LimaTime helpers', () {
    test('minutesToHHmm', () {
      expect(LimaTime.minutesToHHmm(0), '00:00');
      expect(LimaTime.minutesToHHmm(540), '09:00');
      expect(LimaTime.minutesToHHmm(870), '14:30');
      expect(LimaTime.minutesToHHmm(1439), '23:59');
    });

    test('hhmmToMinutes', () {
      expect(LimaTime.hhmmToMinutes('00:00'), 0);
      expect(LimaTime.hhmmToMinutes('09:00'), 540);
      expect(LimaTime.hhmmToMinutes('14:30'), 870);
    });

    test('addDays', () {
      expect(LimaTime.addDays('2026-11-28', 2), '2026-11-30');
      expect(LimaTime.addDays('2026-11-30', 1), '2026-12-01');
    });

    test('compareDate', () {
      expect(LimaTime.compareDate('2026-11-23', '2026-11-24'), isNegative);
      expect(LimaTime.compareDate('2026-11-24', '2026-11-24'), 0);
      expect(LimaTime.compareDate('2026-11-25', '2026-11-24'), isPositive);
    });

    test('formatShortDay formato LUN 24', () {
      final r = LimaTime.formatShortDay('2026-11-23'); // lunes
      expect(r, 'LUN 23');
    });

    test('dayName correcto', () {
      expect(LimaTime.dayName('2026-11-23'), 'Lunes');
      expect(LimaTime.dayName('2026-11-29'), 'Domingo');
    });
  });
}
