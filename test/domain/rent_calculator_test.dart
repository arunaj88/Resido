import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_calculator.dart';
import 'package:resido/features/rent/domain/rent_due.dart';

import 'fixtures.dart';

Matcher throwsDomain(String code) =>
    throwsA(isA<DomainException>().having((e) => e.code, 'code', code));

void main() {
  final tenancy = tenancyA();
  final october = RentDue.forTenancy(tenancy, RentPeriod(2024, 10));
  const grace = 5;

  RentDueSummary summary(
    List<Payment> payments, {
    CalendarDate? asOf,
    RentDue? due,
  }) => RentCalculator.summarize(
    due ?? october,
    payments,
    asOf: asOf ?? CalendarDate(2024, 10, 24),
    graceDays: grace,
  );

  group('totals and status', () {
    test('no payments: full amount outstanding', () {
      final s = summary(const []);
      expect(s.amountPaise, 2400000);
      expect(s.paidPaise, 0);
      expect(s.outstandingPaise, 2400000);
      expect(s.status, RentDueStatus.overdue);
    });

    test('one full payment settles the due', () {
      final s = summary([paymentFor(october, 'p1', 2400000)]);
      expect(s.paidPaise, 2400000);
      expect(s.outstandingPaise, 0);
      expect(s.status, RentDueStatus.paid);
    });

    test('multiple partial payments add up, then settle exactly', () {
      final p1 = paymentFor(october, 'p1', 1300000);
      final p2 = paymentFor(october, 'p2', 600000);
      var s = summary([p1, p2], asOf: CalendarDate(2024, 10, 7));
      expect(s.paidPaise, 1900000);
      expect(s.outstandingPaise, 500000);
      expect(s.status, RentDueStatus.partiallyPaid);

      final p3 = paymentFor(october, 'p3', 500000);
      s = summary([p1, p2, p3]);
      expect(s.outstandingPaise, 0);
      expect(s.status, RentDueStatus.paid);
    });

    test('voided payments are excluded, and totals recalculate', () {
      final p1 = paymentFor(october, 'p1', 2400000);
      expect(summary([p1]).status, RentDueStatus.paid);
      final voided = p1.voided(
        on: CalendarDate(2024, 10, 9),
        reason: 'Bounced',
      );
      final s = summary([voided]);
      expect(s.paidPaise, 0);
      expect(s.outstandingPaise, 2400000);
      expect(s.status, RentDueStatus.overdue);
    });

    test('the same payment listed twice is counted once', () {
      final p1 = paymentFor(october, 'p1', 1000000);
      expect(summary([p1, p1]).paidPaise, 1000000);
    });

    test('two different payments sharing an ID are rejected', () {
      expect(
        () => summary([
          paymentFor(october, 'p1', 1000000),
          paymentFor(october, 'p1', 500000),
        ]),
        throwsDomain('duplicate-payment-id'),
      );
    });

    test('payments for other dues are ignored', () {
      final september = RentDue.forTenancy(tenancy, RentPeriod(2024, 9));
      expect(summary([paymentFor(september, 'p1', 2400000)]).paidPaise, 0);
    });
  });

  group('grace period and dates (explicit business date)', () {
    // Due 05 Oct, 5 grace days: last grace day 10 Oct, overdue from 11 Oct.
    test('upcoming before the due date', () {
      expect(
        summary(const [], asOf: CalendarDate(2024, 10, 4)).status,
        RentDueStatus.upcoming,
      );
    });

    test('due on the due date and through the last grace day', () {
      expect(
        summary(const [], asOf: CalendarDate(2024, 10, 5)).status,
        RentDueStatus.due,
      );
      final lastGrace = summary(const [], asOf: CalendarDate(2024, 10, 10));
      expect(lastGrace.graceEndsOn, CalendarDate(2024, 10, 10));
      expect(lastGrace.status, RentDueStatus.due);
    });

    test('overdue from the first day after grace, even if part-paid', () {
      expect(
        summary(const [], asOf: CalendarDate(2024, 10, 11)).status,
        RentDueStatus.overdue,
      );
      expect(
        summary([
          paymentFor(october, 'p1', 100000),
        ], asOf: CalendarDate(2024, 10, 11)).status,
        RentDueStatus.overdue,
      );
    });

    test('zero grace days: overdue the day after the due date', () {
      expect(
        RentCalculator.summarize(
          october,
          const [],
          asOf: CalendarDate(2024, 10, 6),
          graceDays: 0,
        ).status,
        RentDueStatus.overdue,
      );
    });

    test('grace that crosses a year boundary', () {
      final dec = RentDue.forTenancy(
        tenancyA(dueDay: 28),
        RentPeriod(2024, 12),
      );
      final s = RentCalculator.summarize(
        dec,
        const [],
        asOf: CalendarDate(2025, 1, 2),
        graceDays: 5,
      );
      expect(s.graceEndsOn, CalendarDate(2025, 1, 2));
      expect(s.status, RentDueStatus.due);
    });
  });

  group('overpayment and payment relationships', () {
    test('accepts up to the outstanding amount, rejects more', () {
      final p1 = paymentFor(october, 'p1', 1300000);
      expect(RentCalculator.canRecord(october, const [], p1), isTrue);
      expect(
        RentCalculator.canRecord(october, [
          p1,
        ], paymentFor(october, 'p2', 1100000)),
        isTrue,
      );
      expect(
        () => RentCalculator.canRecord(october, [
          p1,
        ], paymentFor(october, 'p2', 1100001)),
        throwsDomain('overpayment'),
      );
    });

    test('a voided payment frees its amount for a new one', () {
      final p1 = paymentFor(
        october,
        'p1',
        2400000,
      ).voided(on: CalendarDate(2024, 10, 6), reason: 'Entered twice');
      expect(
        RentCalculator.canRecord(october, [
          p1,
        ], paymentFor(october, 'p2', 2400000)),
        isTrue,
      );
    });

    test('an identical retry is not counted twice', () {
      final p1 = paymentFor(october, 'p1', 1000000);
      expect(RentCalculator.canRecord(october, [p1], p1), isFalse);
    });

    test('a payment for another tenancy is rejected', () {
      final other = RentDue.forTenancy(
        tenancyA(id: 'T-B'),
        RentPeriod(2024, 10),
      );
      final foreign = paymentFor(other, 'p9', 100000);
      expect(
        () => RentCalculator.canRecord(october, const [], foreign),
        throwsDomain('payment-tenancy-mismatch'),
      );
      // Same due ID but the wrong tenancy in the payment is also refused.
      final tampered = Payment(
        id: 'p10',
        rentDueId: october.id,
        tenancyId: 'T-B',
        tenantId: october.tenantId,
        amountPaise: 100000,
        paidOn: CalendarDate(2024, 10, 5),
        mode: PaymentMode.cash,
      );
      expect(
        () => RentCalculator.summarize(
          october,
          [tampered],
          asOf: CalendarDate(2024, 10, 24),
          graceDays: grace,
        ),
        throwsDomain('payment-tenancy-mismatch'),
      );
    });
  });

  group('due-period generation', () {
    test('full months between start and end, with stable keys', () {
      final periods = RentCalculator.billablePeriods(
        tenancy,
        through: RentPeriod(2025, 3),
      );
      expect(periods.length, 12);
      expect(periods.first.key, '2024-01');
      expect(periods.last.key, '2024-12');
    });

    test('December to January boundary', () {
      final t = tenancyA(
        start: CalendarDate(2024, 11, 1),
        end: CalendarDate(2025, 2, 28),
      );
      expect(
        RentCalculator.billablePeriods(
          t,
          through: RentPeriod(2025, 6),
        ).map((p) => p.key),
        ['2024-11', '2024-12', '2025-01', '2025-02'],
      );
    });

    test('partial first and last months: billed only when the due date is '
        'inside the tenancy (no proration)', () {
      // Starts 10 Mar (after the 5th) and ends 03 Jun (before the 5th).
      final t = tenancyA(
        start: CalendarDate(2024, 3, 10),
        end: CalendarDate(2024, 6, 3),
      );
      expect(
        RentCalculator.billablePeriods(
          t,
          through: RentPeriod(2024, 12),
        ).map((p) => p.key),
        ['2024-04', '2024-05'],
      );
      // Start and end exactly on due dates are inclusive.
      final exact = tenancyA(
        start: CalendarDate(2024, 3, 5),
        end: CalendarDate(2024, 6, 5),
      );
      expect(
        RentCalculator.billablePeriods(
          exact,
          through: RentPeriod(2024, 12),
        ).map((p) => p.key),
        ['2024-03', '2024-04', '2024-05', '2024-06'],
      );
    });

    test('open-ended tenancy stops at the requested period', () {
      final open = tenancyA(start: CalendarDate(2024, 9, 1), openEnded: true);
      expect(open.endDate, isNull);
      expect(open.lastDay, isNull);
      expect(
        RentCalculator.billablePeriods(
          open,
          through: RentPeriod(2024, 11),
        ).length,
        3,
      );
    });

    test('generating twice never duplicates a period', () {
      final first = RentCalculator.newDues(
        tenancy,
        through: RentPeriod(2024, 6),
      );
      expect(first.length, 6);
      final again = RentCalculator.newDues(
        tenancy,
        through: RentPeriod(2024, 8),
        existing: first,
      );
      expect(again.map((d) => d.period.key), ['2024-07', '2024-08']);
      expect({...first, ...again}.map((d) => d.id).toSet().length, 8);
    });

    test('an ended tenancy bills nothing after it ends but keeps history', () {
      final ended = tenancy.end(CalendarDate(2024, 4, 20));
      final periods = RentCalculator.billablePeriods(
        ended,
        through: RentPeriod(2024, 12),
      );
      expect(periods.map((p) => p.key), [
        '2024-01',
        '2024-02',
        '2024-03',
        '2024-04',
      ]);

      // Historical balance across the tenancy is preserved after ending.
      final dues = [for (final p in periods) RentDue.forTenancy(ended, p)];
      final payments = [
        paymentFor(dues[0], 'h1', 2400000),
        paymentFor(dues[1], 'h2', 2400000),
        paymentFor(dues[2], 'h3', 1000000),
      ];
      final balance = RentCalculator.balance(dues, payments);
      expect(balance.totalDuePaise, 9600000);
      expect(balance.totalPaidPaise, 5800000);
      expect(balance.outstandingPaise, 3800000);
    });
  });
}
