import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/calendar_date.dart';

void main() {
  group('CalendarDate', () {
    test('validates real dates including leap years', () {
      expect(CalendarDate(2024, 2, 29).toIso(), '2024-02-29');
      expect(() => CalendarDate(2023, 2, 29), throwsArgumentError);
      expect(() => CalendarDate(1900, 2, 29), throwsArgumentError);
      expect(CalendarDate(2000, 2, 29).day, 29);
      expect(() => CalendarDate(2024, 13, 1), throwsArgumentError);
      expect(() => CalendarDate(2024, 4, 31), throwsArgumentError);
    });

    test('day arithmetic crosses months and years', () {
      expect(CalendarDate(2024, 12, 31).addDays(1), CalendarDate(2025, 1, 1));
      expect(CalendarDate(2024, 2, 28).addDays(1), CalendarDate(2024, 2, 29));
      expect(CalendarDate(2023, 2, 28).addDays(1), CalendarDate(2023, 3, 1));
      expect(CalendarDate(2024, 3, 1).addDays(-1), CalendarDate(2024, 2, 29));
      expect(
        CalendarDate(2024, 10, 1).daysUntil(CalendarDate(2024, 10, 24)),
        23,
      );
    });

    test('business date uses Asia/Kolkata (UTC+5:30), not device time', () {
      // 18:29 UTC is 23:59 IST on the same day.
      expect(
        CalendarDate.businessDateOf(DateTime.utc(2024, 10, 24, 18, 29)),
        CalendarDate(2024, 10, 24),
      );
      // 18:30 UTC is midnight IST: the next business day.
      expect(
        CalendarDate.businessDateOf(DateTime.utc(2024, 10, 24, 18, 30)),
        CalendarDate(2024, 10, 25),
      );
      // New Year in IST starts at 18:30 UTC on 31 Dec.
      expect(
        CalendarDate.businessDateOf(DateTime.utc(2024, 12, 31, 19)),
        CalendarDate(2025, 1, 1),
      );
    });

    test('ISO round trip and parse errors', () {
      expect(CalendarDate.parse('2024-10-05'), CalendarDate(2024, 10, 5));
      expect(() => CalendarDate.parse('2024-02-30'), throwsFormatException);
      expect(() => CalendarDate.parse('5 Oct 2024'), throwsFormatException);
    });
  });

  group('RentPeriod', () {
    test('keys are YYYY-MM and parse back', () {
      expect(RentPeriod(2024, 3).key, '2024-03');
      expect(RentPeriod.parse('2024-10'), RentPeriod(2024, 10));
      expect(() => RentPeriod.parse('2024-13'), throwsFormatException);
      expect(() => RentPeriod.parse('2024-1'), throwsFormatException);
    });

    test('December to January and back', () {
      expect(RentPeriod(2024, 12).next, RentPeriod(2025, 1));
      expect(RentPeriod(2025, 1).previous, RentPeriod(2024, 12));
      expect(
        RentPeriod(2024, 11).through(RentPeriod(2025, 2)).map((p) => p.key),
        ['2024-11', '2024-12', '2025-01', '2025-02'],
      );
      expect(RentPeriod(2025, 1).through(RentPeriod(2024, 12)), isEmpty);
    });

    test('due dates for due days 1-28, including February', () {
      expect(RentPeriod(2023, 2).dueDate(28), CalendarDate(2023, 2, 28));
      expect(RentPeriod(2024, 10).dueDate(1), CalendarDate(2024, 10, 1));
      expect(() => RentPeriod(2024, 10).dueDate(0), throwsArgumentError);
      expect(() => RentPeriod(2024, 10).dueDate(29), throwsArgumentError);
      expect(RentPeriod(2024, 2).lastDay, CalendarDate(2024, 2, 29));
    });
  });
}
