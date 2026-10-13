/// Indian rupee formatting without extra packages.
abstract final class InrFormat {
  /// Full amount with Indian digit grouping: 152000 → ₹1,52,000.
  static String full(int amount) =>
      '${amount < 0 ? '-' : ''}₹${grouped(amount.abs())}';

  /// Indian digit grouping without the symbol: 152000 → 1,52,000.
  static String grouped(int value) {
    final digits = value.toString();
    String grouped;
    if (digits.length <= 3) {
      grouped = digits;
    } else {
      final head = digits.substring(0, digits.length - 3);
      final tail = digits.substring(digits.length - 3);
      final buffer = StringBuffer();
      for (var i = 0; i < head.length; i++) {
        if (i > 0 && (head.length - i).isEven) buffer.write(',');
        buffer.write(head[i]);
      }
      grouped = '$buffer,$tail';
    }
    return grouped;
  }

  /// Compact amount: 152000 → ₹1.52L, 33000 → ₹33K, 12500000 → ₹1.25Cr.
  static String compact(int amount) {
    String trim(double v) {
      final text = v.toStringAsFixed(2);
      return text.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final value = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (value >= 10000000) return '$sign₹${trim(value / 10000000)}Cr';
    if (value >= 100000) return '$sign₹${trim(value / 100000)}L';
    if (value >= 1000) return '$sign₹${trim(value / 1000)}K';
    return '$sign₹$value';
  }
}
