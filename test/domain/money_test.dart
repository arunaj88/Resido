import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/utils/inr_format.dart';

void main() {
  group('Money.parseRupees', () {
    test('converts rupee text to integer paise without rounding', () {
      expect(Money.parseRupees('1000'), 100000);
      expect(Money.parseRupees('1000.00'), 100000);
      expect(Money.parseRupees('125.50'), 12550);
      expect(Money.parseRupees('125.5'), 12550);
      expect(Money.parseRupees('0.01'), 1);
      expect(Money.parseRupees('0'), 0);
      // Values that are inexact as binary doubles stay exact.
      expect(Money.parseRupees('0.29'), 29);
      expect(Money.parseRupees('1.15'), 115);
    });

    test('accepts prefixes, spaces and correct grouping', () {
      expect(Money.parseRupees('₹24,000'), 2400000);
      expect(Money.parseRupees(' Rs. 1,25,000.75 '), 12500075);
      expect(Money.parseRupees('INR 125,000'), 12500000);
      expect(Money.parseRupees('₹ 1,00,00,000'), 1000000000);
    });

    test('rejects malformed input and extra precision', () {
      for (final bad in [
        '',
        '   ',
        '₹',
        '-100',
        '+100',
        '12.345',
        '1.000',
        '12.',
        '.5',
        '1,,000',
        '1,00',
        '10,0000',
        ',100',
        '1e3',
        '12a',
        '1 000',
        '१००',
      ]) {
        expect(
          () => Money.parseRupees(bad),
          throwsFormatException,
          reason: '"$bad"',
        );
        expect(Money.tryParseRupees(bad), isNull, reason: '"$bad"');
      }
    });

    test('enforces the maximum without overflowing', () {
      expect(Money.parseRupees('1000000000'), Money.maxPaise);
      expect(Money.parseRupees('1000000000.00'), Money.maxPaise);
      expect(() => Money.parseRupees('1000000000.01'), throwsFormatException);
      expect(
        () => Money.parseRupees('99999999999999999999999'),
        throwsFormatException,
      );
      expect(Money.parseRupees('0000000000001'), 100);
    });
  });

  group('amount checks', () {
    test('zero, minimum and maximum are valid; negatives are not', () {
      expect(Money.checkAmount(0), 0);
      expect(Money.checkAmount(1), 1);
      expect(Money.checkAmount(Money.maxPaise), Money.maxPaise);
      expect(() => Money.checkAmount(-1), throwsArgumentError);
      expect(() => Money.checkAmount(Money.maxPaise + 1), throwsArgumentError);
      expect(() => Money.fromRupees(-5), throwsArgumentError);
      expect(Money.fromRupees(24000), 2400000);
    });

    test('sum is exact and guards the safe range', () {
      expect(Money.sum([1300000, 1100000]), 2400000);
      expect(Money.sum(const []), 0);
      expect(() => Money.sum([-1]), throwsArgumentError);
      expect(
        () => Money.sum(List.filled(100000, Money.maxPaise)),
        throwsStateError,
      );
    });
  });

  group('Money.format', () {
    test('matches the existing InrFormat grouping', () {
      expect(Money.format(2400000), '₹24,000.00');
      expect(Money.format(12500075), '₹1,25,000.75');
      expect(Money.format(5), '₹0.05');
      expect(
        Money.format(2400000, alwaysShowPaise: false),
        InrFormat.full(24000),
      );
      expect(Money.format(15215000, alwaysShowPaise: false), '₹1,52,150');
      expect(Money.format(-150), '-₹1.50');
    });
  });
}
