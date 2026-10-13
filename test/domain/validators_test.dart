import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/validators.dart';

void main() {
  test('required and optional text are trimmed and length limited', () {
    expect(Validators.requiredText('  Palm Grove ', 'Name'), isNull);
    expect(Validators.requiredText('   ', 'Name'), 'Name is required');
    expect(Validators.requiredText(null, 'Name'), 'Name is required');
    expect(Validators.requiredText('x' * 81, 'Title', max: 80), isNotNull);
    expect(Validators.requiredText(' ${'x' * 80} ', 'Title', max: 80), isNull);
    expect(Validators.optionalText('', 'Notes'), isNull);
    expect(Validators.optionalText('x' * 501, 'Notes'), isNotNull);
  });

  group('Indian mobile numbers', () {
    test('normalizes accepted formats to +91XXXXXXXXXX', () {
      for (final input in [
        '9847023411',
        '98470 23411',
        '98470-23411',
        '09847023411',
        '919847023411',
        '+919847023411',
        '+91 98470 23411',
        ' +91-98470-23411 ',
      ]) {
        expect(
          Validators.normalizeIndianMobile(input),
          '+919847023411',
          reason: input,
        );
      }
    });

    test('rejects malformed and non-Indian numbers', () {
      for (final input in [
        '',
        '5847023411', // mobiles start with 6-9
        '984702341', // 9 digits
        '98470234111', // 11 digits without 0
        '+1 202 555 0143', // US
        '+44 7911 123456', // UK
        '+9198470234', // too short after +91
        '0091 98470 23411', // international prefix not accepted
        '98470a23411',
        '(984) 702-3411',
        '+ 91 98470 23411',
      ]) {
        expect(Validators.normalizeIndianMobile(input), isNull, reason: input);
      }
      expect(Validators.indianMobile(''), 'Mobile number is required');
      expect(Validators.indianMobile('', required: false), isNull);
      expect(Validators.isCanonicalIndianMobile('+919847023411'), isTrue);
      expect(Validators.isCanonicalIndianMobile('9847023411'), isFalse);
    });
  });

  test('PIN codes: 6 digits; Kerala rule only for Kerala', () {
    expect(Validators.pinCode('682036', kerala: true), isNull);
    expect(Validators.pinCode('673004', kerala: true), isNull);
    expect(Validators.pinCode('560001', kerala: true), isNotNull);
    expect(Validators.pinCode('560001', kerala: false), isNull);
    expect(Validators.pinCode('110001', kerala: false), isNull);
    expect(Validators.pinCode('012345', kerala: false), isNotNull);
    expect(Validators.pinCode('68203', kerala: false), isNotNull);
    expect(Validators.pinCode('68203a', kerala: false), isNotNull);
    expect(Validators.isKeralaState(' kerala '), isTrue);
    expect(Validators.isKeralaState('Karnataka'), isFalse);
  });

  test('business constraints', () {
    expect(Validators.amount(0, 'Rent'), isNull);
    expect(Validators.amount(0, 'Rent', min: 1), isNotNull);
    expect(Validators.amount(-1, 'Rent'), isNotNull);
    expect(Validators.amount(Money.maxPaise + 1, 'Rent'), isNotNull);
    expect(Validators.amount(null, 'Rent'), isNotNull);

    expect(Validators.dueDay(1), isNull);
    expect(Validators.dueDay(28), isNull);
    expect(Validators.dueDay(0), isNotNull);
    expect(Validators.dueDay(29), isNotNull);

    final start = CalendarDate(2024, 10, 1);
    expect(Validators.dateRange(start, null), isNull);
    expect(Validators.dateRange(start, start), isNull);
    expect(Validators.dateRange(start, CalendarDate(2024, 9, 30)), isNotNull);
    expect(Validators.dateRange(null, null), isNotNull);

    expect(Validators.requiredId('palm-grove', 'Property'), isNull);
    expect(Validators.requiredId(' ', 'Property'), isNotNull);
  });
}
