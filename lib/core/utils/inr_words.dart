/// Spells a rupee amount in Indian words for helper text under amount
/// inputs: 24000 → "Twenty Four Thousand Indian Rupees only".
abstract final class InrWords {
  static const _ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];
  static const _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String of(int amount) {
    if (amount <= 0) return '';
    return '${_words(amount)} Indian Rupees only';
  }

  static String _words(int n) {
    final parts = <String>[];
    void add(int value, String unit) {
      if (value > 0) parts.add('${_belowHundred(value)} $unit');
    }

    add(n ~/ 10000000, 'Crore');
    n %= 10000000;
    add(n ~/ 100000, 'Lakh');
    n %= 100000;
    add(n ~/ 1000, 'Thousand');
    n %= 1000;
    add(n ~/ 100, 'Hundred');
    n %= 100;
    if (n > 0) parts.add(_belowHundred(n));
    return parts.join(' ');
  }

  static String _belowHundred(int n) {
    if (n < 20) return _ones[n];
    final rest = n % 10;
    return rest == 0 ? _tens[n ~/ 10] : '${_tens[n ~/ 10]} ${_ones[rest]}';
  }
}
