import 'package:resido/core/utils/inr_format.dart';

/// Money in Resido is always an `int` number of **paise** (₹1 = 100 paise).
///
/// Doubles are never used for stored amounts or calculations. User input is
/// parsed from text digit by digit, so there is no binary rounding.
abstract final class Money {
  /// Largest single amount accepted: ₹1,00,00,00,000.00 (100 crore).
  static const maxPaise = 1000000000 * 100;

  /// Largest running total kept exact on every platform (web ints are
  /// doubles, exact up to 2^53 - 1).
  static const maxSafeTotal = 9007199254740991;

  static const paisePerRupee = 100;

  /// Whole rupees to paise, rejecting negative or out-of-range values.
  static int fromRupees(int rupees) {
    if (rupees < 0) {
      throw ArgumentError.value(rupees, 'rupees', 'must not be negative');
    }
    if (rupees > maxPaise ~/ paisePerRupee) {
      throw ArgumentError.value(rupees, 'rupees', 'exceeds the maximum');
    }
    return rupees * paisePerRupee;
  }

  /// Parses rupee text into paise.
  ///
  /// Accepted: optional `₹`/`Rs`/`Rs.` prefix, surrounding spaces, digits
  /// with either no commas or correct Indian (`1,25,000`) or international
  /// (`125,000`) grouping, and at most two decimal places (`125.5` →
  /// 12550, `125.50` → 12550).
  ///
  /// Rejected with a [FormatException]: empty text, signs, more than two
  /// decimals (no silent rounding), a bare or trailing `.`, misplaced
  /// commas, any other character, and amounts above [maxPaise].
  static int parseRupees(String input) {
    var text = input.trim();
    for (final prefix in ['₹', 'Rs.', 'Rs', 'INR']) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trimLeft();
        break;
      }
    }
    if (text.isEmpty) throw const FormatException('Enter an amount');

    final match = RegExp(r'^([0-9,]+)(?:\.([0-9]+))?$').firstMatch(text);
    if (match == null) {
      throw FormatException('Not a valid rupee amount', input);
    }
    final whole = match.group(1)!;
    final fraction = match.group(2);

    if (whole.contains(',') && !_validGrouping(whole)) {
      throw FormatException('Misplaced comma in amount', input);
    }
    if (fraction != null && fraction.length > 2) {
      throw FormatException('Use at most two decimal places', input);
    }

    final digits = whole.replaceAll(',', '');
    // Reject before parsing so huge inputs cannot overflow.
    final significant = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (significant.length > 10) {
      throw FormatException('Amount is too large', input);
    }
    final rupees = int.parse(digits);
    final paise = fraction == null ? 0 : int.parse(fraction.padRight(2, '0'));
    final total = rupees * paisePerRupee + paise;
    if (total > maxPaise) throw FormatException('Amount is too large', input);
    return total;
  }

  /// Like [parseRupees] but returns null instead of throwing.
  static int? tryParseRupees(String input) {
    try {
      return parseRupees(input);
    } on FormatException {
      return null;
    }
  }

  static bool _validGrouping(String whole) =>
      RegExp(r'^\d{1,2}(,\d{2})*,\d{3}$').hasMatch(whole) ||
      RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(whole);

  /// Throws unless [paise] is a valid stored amount (0..[maxPaise]).
  static int checkAmount(int paise, {String name = 'amount'}) {
    if (paise < 0) {
      throw ArgumentError.value(paise, name, 'must not be negative');
    }
    if (paise > maxPaise) {
      throw ArgumentError.value(paise, name, 'exceeds the maximum');
    }
    return paise;
  }

  /// Sums amounts, throwing [StateError] if the total would leave the
  /// exactly representable range on any platform.
  static int sum(Iterable<int> amounts) {
    var total = 0;
    for (final a in amounts) {
      checkAmount(a);
      if (total > maxSafeTotal - a) {
        throw StateError('Total exceeds the supported range');
      }
      total += a;
    }
    return total;
  }

  /// "₹1,25,000.50", or "₹1,25,000.00" with [alwaysShowPaise].
  ///
  /// Whole rupees are grouped by the existing [InrFormat.grouped]; paise
  /// are appended from the integer remainder (no doubles involved).
  static String format(int paise, {bool alwaysShowPaise = true}) {
    final negative = paise < 0;
    final abs = paise.abs();
    final rupees = abs ~/ paisePerRupee;
    final rest = abs % paisePerRupee;
    final sign = negative ? '-' : '';
    if (!alwaysShowPaise && rest == 0) {
      return '$sign₹${InrFormat.grouped(rupees)}';
    }
    return '$sign₹${InrFormat.grouped(rupees)}.${rest.toString().padLeft(2, '0')}';
  }
}
