/// Calendar dates and rent periods with no time-of-day and no timezone.
///
/// **Business-date convention.** Resido's business timezone is
/// `Asia/Kolkata` (IST, UTC+05:30, no daylight saving). An instant is turned
/// into a business date with [CalendarDate.businessDateOf], which shifts the
/// UTC instant by +5:30 and reads the calendar fields. Everything else works
/// on plain year/month/day values, so results never depend on the device's
/// timezone or clock. Callers always pass the business date explicitly.
library;

/// A date without time or timezone. Day arithmetic uses UTC internally so
/// daylight-saving changes on the device cannot shift a day.
class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(this.year, this.month, this.day) {
    if (year < minYear || year > maxYear) {
      throw ArgumentError.value(year, 'year', 'must be 1-9999');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be 1-12');
    }
    if (day < 1 || day > daysInMonth(year, month)) {
      throw ArgumentError.value(day, 'day', 'not in $year-$month');
    }
  }

  /// Supported years, shared with [RentPeriod] so every date has a period
  /// and its `YYYY-MM-DD` text round-trips.
  static const minYear = 1;
  static const maxYear = 9999;

  /// IST offset used for [businessDateOf].
  static const istOffset = Duration(hours: 5, minutes: 30);

  /// The `Asia/Kolkata` calendar date of [instant].
  factory CalendarDate.businessDateOf(DateTime instant) {
    final ist = instant.toUtc().add(istOffset);
    return CalendarDate(ist.year, ist.month, ist.day);
  }

  /// Parses `YYYY-MM-DD`.
  factory CalendarDate.parse(String text) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (m == null) throw FormatException('Expected YYYY-MM-DD', text);
    try {
      return CalendarDate(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    } on ArgumentError {
      throw FormatException('Not a real calendar date', text);
    }
  }

  final int year;
  final int month;
  final int day;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) => switch (month) {
    2 => isLeapYear(year) ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  DateTime get _utc => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) {
    final d = _utc.add(Duration(days: days));
    return CalendarDate(d.year, d.month, d.day);
  }

  /// Whole days from this date to [other] (negative if [other] is earlier).
  int daysUntil(CalendarDate other) => other._utc.difference(_utc).inDays;

  RentPeriod get period => RentPeriod(year, month);

  bool isBefore(CalendarDate other) => compareTo(other) < 0;
  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  /// `YYYY-MM-DD`.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';

  @override
  int compareTo(CalendarDate other) => year != other.year
      ? year.compareTo(other.year)
      : month != other.month
      ? month.compareTo(other.month)
      : day.compareTo(other.day);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// A rent period: one calendar month, keyed `YYYY-MM`.
class RentPeriod implements Comparable<RentPeriod> {
  RentPeriod(this.year, this.month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be 1-12');
    }
    if (year < CalendarDate.minYear || year > CalendarDate.maxYear) {
      throw ArgumentError.value(year, 'year', 'must be 1-9999');
    }
  }

  /// Parses a `YYYY-MM` key.
  factory RentPeriod.parse(String key) {
    final m = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(key);
    if (m == null) throw FormatException('Expected YYYY-MM', key);
    try {
      return RentPeriod(int.parse(m.group(1)!), int.parse(m.group(2)!));
    } on ArgumentError {
      throw FormatException('Not a real month', key);
    }
  }

  final int year;
  final int month;

  /// `YYYY-MM`.
  String get key => '${year.toString().padLeft(4, '0')}-${_two(month)}';

  RentPeriod get next =>
      month == 12 ? RentPeriod(year + 1, 1) : RentPeriod(year, month + 1);

  RentPeriod get previous =>
      month == 1 ? RentPeriod(year - 1, 12) : RentPeriod(year, month - 1);

  CalendarDate get firstDay => CalendarDate(year, month, 1);
  CalendarDate get lastDay =>
      CalendarDate(year, month, CalendarDate.daysInMonth(year, month));

  /// The due date in this month for a due day of 1–28 (28 so every month,
  /// including February, has that day).
  CalendarDate dueDate(int dueDay) {
    if (dueDay < 1 || dueDay > 28) {
      throw ArgumentError.value(dueDay, 'dueDay', 'must be 1-28');
    }
    return CalendarDate(year, month, dueDay);
  }

  /// Periods from this one to [last], inclusive (empty if [last] is earlier).
  List<RentPeriod> through(RentPeriod last) {
    final result = <RentPeriod>[];
    if (compareTo(last) > 0) return result;
    // Stop at [last] before computing the next month, so a range ending at
    // 9999-12 never constructs year 10000.
    for (var p = this; ; p = p.next) {
      result.add(p);
      if (p == last) return result;
    }
  }

  @override
  int compareTo(RentPeriod other) => year != other.year
      ? year.compareTo(other.year)
      : month.compareTo(other.month);

  @override
  bool operator ==(Object other) =>
      other is RentPeriod && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => key;
}

String _two(int v) => v.toString().padLeft(2, '0');
