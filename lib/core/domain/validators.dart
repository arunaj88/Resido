import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/money.dart';

/// Widget-free validators. Each returns `null` when the value is valid and
/// a user-facing message otherwise (the same contract as Flutter form
/// validators), so they can back forms later and be unit tested now.
abstract final class Validators {
  // Field length limits used across the domain.
  static const nameMax = 80;
  static const titleMax = 80;
  static const shortTextMax = 120;
  static const notesMax = 500;

  /// Trimmed, non-empty and at most [max] characters.
  static String? requiredText(String? value, String field, {int max = 120}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field is required';
    if (text.length > max) return '$field must be $max characters or fewer';
    return null;
  }

  /// Empty is fine; otherwise at most [max] characters after trimming.
  static String? optionalText(String? value, String field, {int max = 500}) {
    final text = value?.trim() ?? '';
    if (text.length > max) return '$field must be $max characters or fewer';
    return null;
  }

  /// Canonical Indian mobile number: `+91` followed by 10 digits starting
  /// with 6–9, e.g. `+919847023411`.
  static final _canonicalMobile = RegExp(r'^\+91[6-9]\d{9}$');

  static bool isCanonicalIndianMobile(String value) =>
      _canonicalMobile.hasMatch(value);

  /// Normalizes an Indian mobile number to `+91XXXXXXXXXX`, or returns null.
  ///
  /// Accepted inputs: a 10-digit number starting with 6–9, optionally
  /// preceded by `+91`, `91` or the trunk prefix `0`. A single space or
  /// hyphen may separate the prefix from the number and digit groups within
  /// the number, e.g. `9847023411`, `98470 23411`, `98470-23411`,
  /// `09847023411`, `919847023411`, `+919847023411`, `+91 98470 23411`,
  /// `+91-98470-23411`.
  ///
  /// Rejected: separators inside the country code (`+9-1…`), leading,
  /// trailing or doubled separators, other country codes, letters and other
  /// symbols, and the wrong digit count — numbers are never reinterpreted
  /// as Indian.
  static String? normalizeIndianMobile(String? input) {
    final raw = input?.trim() ?? '';
    final match = _mobilePattern.firstMatch(raw);
    if (match == null) return null;
    final national = match.group(2)!.replaceAll(RegExp(r'[ -]'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(national)) return null;
    return '+91$national';
  }

  /// Optional prefix (`+91`, `91` or `0`, then at most one separator) and a
  /// 10-digit number with at most one separator between digits.
  static final _mobilePattern = RegExp(
    r'^(?:(\+91|91|0)[ -]?)?(\d(?:[ -]?\d){9})$',
  );

  static String? indianMobile(String? value, {bool required = true}) {
    if ((value?.trim() ?? '').isEmpty) {
      return required ? 'Mobile number is required' : null;
    }
    return normalizeIndianMobile(value) == null
        ? 'Enter a valid 10-digit Indian mobile number'
        : null;
  }

  /// Six-digit Indian PIN code (first digit 1–9). When [kerala] is true the
  /// PIN must also start with 67, 68 or 69, the same rule the Add Property
  /// form uses. Other states are never held to the Kerala rule.
  static String? pinCode(String? value, {required bool kerala}) {
    final pin = value?.trim() ?? '';
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pin)) {
      return 'Enter a valid 6-digit PIN code';
    }
    if (kerala && !RegExp(r'^(67|68|69)').hasMatch(pin)) {
      return 'Kerala PIN codes start with 67, 68 or 69';
    }
    return null;
  }

  static bool isKeralaState(String state) =>
      state.trim().toLowerCase() == 'kerala';

  /// Money in paise between [min] and [Money.maxPaise].
  static String? amount(int? paise, String field, {int min = 0}) {
    if (paise == null) return '$field is required';
    if (paise < min) {
      return min == 0
          ? '$field cannot be negative'
          : '$field must be at least ${Money.format(min)}';
    }
    if (paise > Money.maxPaise) return '$field is too large';
    return null;
  }

  /// A rent due day of 1–28, so every month has it.
  static String? dueDay(int? day) {
    if (day == null || day < 1 || day > 28) {
      return 'Due day must be between 1 and 28';
    }
    return null;
  }

  static String? graceDays(int? days) {
    if (days == null || days < 0 || days > 31) {
      return 'Grace period must be 0-31 days';
    }
    return null;
  }

  /// End date is optional (open-ended) but may not precede the start date.
  /// The end date is inclusive: the last day of the tenancy.
  static String? dateRange(CalendarDate? start, CalendarDate? end) {
    if (start == null) return 'Start date is required';
    if (end != null && end.isBefore(start)) {
      return 'End date cannot be before the start date';
    }
    return null;
  }

  /// A required reference to another record (e.g. a tenancy's unit).
  static String? requiredId(String? id, String field) =>
      (id == null || id.trim().isEmpty) ? '$field is required' : null;
}
