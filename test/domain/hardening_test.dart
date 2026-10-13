// Regression tests for the M1 audit fixes.
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';
import 'package:resido/features/maintenance/domain/maintenance_request.dart';
import 'package:resido/features/properties/domain/property.dart';
import 'package:resido/features/rent/data/in_memory_rent_repository.dart';
import 'package:resido/features/rent/domain/rent_calculator.dart';
import 'package:resido/features/rent/domain/rent_due.dart';

import 'fixtures.dart';

Matcher throwsDomain(String code) =>
    throwsA(isA<DomainException>().having((e) => e.code, 'code', code));

void main() {
  group('1. dues after an early tenancy end', () {
    // ₹24,000 due on the 5th, Jan–Dec 2024.
    final tenancy = tenancyA();

    test('generated ahead, ended early: unearned dues are cancelled, '
        'earned history and payments kept', () async {
      final repo = InMemoryRentRepository();
      await repo.ensureDues(tenancy, through: RentPeriod(2024, 6));
      final dues = await repo.getDues(tenancyId: tenancy.id);
      await repo.recordPayment(paymentFor(dues[0], 'jan', 2400000));
      await repo.recordPayment(paymentFor(dues[1], 'feb', 2400000));
      await repo.recordPayment(paymentFor(dues[2], 'mar', 1000000));

      // Ends 20 Mar (inclusive): March's due (5 Mar) is earned.
      final ended = tenancy.end(CalendarDate(2024, 3, 20));
      final before = RentCalculator.balance(
        await repo.getDues(),
        await repo.getPayments(),
      );
      expect(before.totalDuePaise, 6 * 2400000); // the audit's problem

      final cancelled = await repo.cancelUnearnedDues(
        ended,
        on: CalendarDate(2024, 3, 20),
      );
      expect(cancelled.map((d) => d.period.key), [
        '2024-04',
        '2024-05',
        '2024-06',
      ]);

      final after = RentCalculator.balance(
        await repo.getDues(),
        await repo.getPayments(),
      );
      expect(after.totalDuePaise, 3 * 2400000);
      expect(after.totalPaidPaise, 5800000);
      expect(after.outstandingPaise, 1400000);

      // Nothing is deleted: all six dues and three payments remain.
      final all = await repo.getDues(tenancyId: tenancy.id);
      expect(all.length, 6);
      expect(all.where((d) => d.isCancelled).length, 3);
      expect((await repo.getPayments()).length, 3);
      expect(
        RentCalculator.summarize(
          all[4],
          const [],
          asOf: CalendarDate(2024, 5, 20),
          graceDays: 5,
        ).status,
        RentDueStatus.cancelled,
      );

      // Regenerating does not bring cancelled periods back.
      expect(
        await repo.ensureDues(ended, through: RentPeriod(2024, 12)),
        isEmpty,
      );
      // Cancelling again finds nothing new.
      expect(
        await repo.cancelUnearnedDues(ended, on: CalendarDate(2024, 3, 21)),
        isEmpty,
      );
      // A cancelled due takes no payments.
      expect(
        () => repo.recordPayment(paymentFor(all[3], 'apr', 100)),
        throwsDomain('due-cancelled'),
      );
    });

    test('ending exactly on a due date keeps that month (inclusive end)', () {
      final dues = RentCalculator.newDues(
        tenancy,
        through: RentPeriod(2024, 6),
      );
      final ended = tenancy.end(CalendarDate(2024, 4, 5));
      expect(
        RentCalculator.unearnedDues(ended, dues).map((d) => d.period.key),
        ['2024-05', '2024-06'],
      );
      final dayBefore = tenancy.end(CalendarDate(2024, 4, 4));
      expect(
        RentCalculator.unearnedDues(dayBefore, dues).first.period.key,
        '2024-04',
      );
    });

    test(
      'an unearned due with payments blocks cancellation unchanged',
      () async {
        final repo = InMemoryRentRepository();
        await repo.ensureDues(tenancy, through: RentPeriod(2024, 5));
        final dues = await repo.getDues();
        // May's rent paid in advance on 30 Apr.
        await repo.recordPayment(
          paymentFor(
            dues[4],
            'advance',
            2400000,
            paidOn: CalendarDate(2024, 4, 30),
          ),
        );
        expect(
          () => repo.cancelUnearnedDues(
            tenancy.end(CalendarDate(2024, 3, 20)),
            on: CalendarDate(2024, 3, 20),
          ),
          throwsDomain('due-has-payments'),
        );
        expect((await repo.getDues()).where((d) => d.isCancelled), isEmpty);
      },
    );

    test('cancelled dues serialize; older maps without state still load', () {
      final due = RentDue.forTenancy(tenancy, RentPeriod(2024, 4));
      final c = due.cancelled(on: CalendarDate(2024, 3, 20), reason: 'Ended');
      expect(RentDue.fromMap(c.toMap()), c);
      final legacy = due.toMap()
        ..remove('state')
        ..remove('cancelledOn')
        ..remove('cancelReason');
      expect(RentDue.fromMap(legacy), due);
      expect(
        () => RentDue(
          tenancyId: 't',
          tenantId: 'x',
          unitId: 'u',
          propertyId: 'p',
          period: RentPeriod(2024, 4),
          dueDate: CalendarDate(2024, 4, 5),
          amountPaise: 1,
          state: RentDueState.cancelled,
        ),
        throwsArgumentError,
      );
      expect(
        () => c.cancelled(on: CalendarDate(2024, 3, 21), reason: 'x'),
        throwsStateError,
      );
    });
  });

  group('2. payment and void dates', () {
    final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 10));

    test('a void cannot predate the payment; same day is fine', () async {
      final p = paymentFor(due, 'p', 100, paidOn: CalendarDate(2024, 10, 10));
      expect(
        () => p.voided(on: CalendarDate(2024, 10, 9), reason: 'Bounced'),
        throwsArgumentError,
      );
      expect(
        p.voided(on: CalendarDate(2024, 10, 10), reason: 'Bounced').voidedOn,
        CalendarDate(2024, 10, 10),
      );

      final repo = InMemoryRentRepository(dues: [due]);
      await repo.recordPayment(p);
      expect(
        () => repo.voidPayment(
          'p',
          on: CalendarDate(2024, 10, 9),
          reason: 'Bounced',
        ),
        throwsDomain('void-date'),
      );
    });

    test('payments may be one month early and any amount of time late', () {
      expect(RentCalculator.earliestPaymentDate(due), CalendarDate(2024, 9, 1));
      bool ok(CalendarDate on) => RentCalculator.canRecord(
        due,
        const [],
        paymentFor(due, 'p', 1, paidOn: on),
      );
      expect(ok(CalendarDate(2024, 9, 1)), isTrue);
      expect(() => ok(CalendarDate(2024, 8, 31)), throwsDomain('payment-date'));
      expect(ok(CalendarDate(2027, 6, 30)), isTrue); // very late: accepted
      final january = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 1));
      expect(
        RentCalculator.earliestPaymentDate(january),
        CalendarDate(2023, 12, 1),
      );
    });
  });

  group('3. duplicate dues in balance', () {
    final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 10));

    test('identical copies count once', () {
      expect(
        RentCalculator.balance([due, due], const []).totalDuePaise,
        2400000,
      );
    });

    test('conflicting records with one ID are rejected', () {
      final other = RentDue.forTenancy(
        tenancyA(rentPaise: 2500000),
        RentPeriod(2024, 10),
      );
      expect(other.id, due.id);
      expect(
        () => RentCalculator.balance([due, other], const []),
        throwsDomain('duplicate-due-id'),
      );
    });
  });

  group('4. Indian mobile normalization', () {
    test('rejects separators in the country code, trailing or doubled', () {
      for (final input in [
        '+9-1 9847023411',
        '+9 1 9847023411',
        '9847023411-',
        '98470 23411-',
        '-9847023411',
        '98470--23411',
        '98470  23411',
        '+91--9847023411',
      ]) {
        expect(Validators.normalizeIndianMobile(input), isNull, reason: input);
      }
    });

    test('still accepts every supported format', () {
      for (final input in [
        '9847023411',
        '98470 23411',
        '98470-23411',
        '09847023411',
        '0 98470 23411',
        '919847023411',
        '91 98470 23411',
        '+919847023411',
        '+91 98470 23411',
        '+91-98470-23411',
        '9198470234', // a 10-digit national number starting with 91
      ]) {
        expect(
          Validators.normalizeIndianMobile(input),
          input == '9198470234' ? '+919198470234' : '+919847023411',
          reason: input,
        );
      }
    });
  });

  group('5 & 6. year bounds', () {
    test('RentPeriod.through ending at 9999-12', () {
      expect(
        RentPeriod(9999, 12).through(RentPeriod(9999, 12)).map((p) => p.key),
        ['9999-12'],
      );
      expect(RentPeriod(9999, 11).through(RentPeriod(9999, 12)).length, 2);
      expect(RentPeriod(9999, 12).through(RentPeriod(9999, 11)), isEmpty);
      expect(RentPeriod(1, 1).through(RentPeriod(1, 2)).length, 2);
    });

    test('CalendarDate accepts years 1-9999 and round-trips its text', () {
      expect(() => CalendarDate(0, 1, 1), throwsArgumentError);
      expect(() => CalendarDate(10000, 1, 1), throwsArgumentError);
      expect(() => CalendarDate(-1, 1, 1), throwsArgumentError);
      for (final d in [CalendarDate(1, 1, 1), CalendarDate(9999, 12, 31)]) {
        expect(CalendarDate.parse(d.toIso()), d);
        expect(d.period.firstDay.year, d.year);
      }
      expect(() => CalendarDate.parse('0000-01-01'), throwsFormatException);
      expect(() => CalendarDate(9999, 12, 31).addDays(1), throwsArgumentError);
    });
  });

  group('7. duplicate payment state', () {
    final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 10));
    final p = paymentFor(due, 'p', 1000000);

    test('identical copies count once', () {
      expect(RentCalculator.paidPaise(due, [p, p]), 1000000);
    });

    test('recorded and voided copies of one ID are rejected, either order', () {
      final v = p.voided(on: CalendarDate(2024, 10, 9), reason: 'Bounced');
      expect(
        () => RentCalculator.paidPaise(due, [p, v]),
        throwsDomain('duplicate-payment-id'),
      );
      expect(
        () => RentCalculator.paidPaise(due, [v, p]),
        throwsDomain('duplicate-payment-id'),
      );
      // Current state only: the voided version alone counts nothing.
      expect(RentCalculator.paidPaise(due, [v]), 0);
    });
  });

  group('8. string lists in maps', () {
    test('valid lists load; malformed ones name the field and index', () {
      const reader = MapReader({
        'ok': ['a', 'b'],
        'bad': ['a', 2],
        'notList': 'a',
      }, 'Thing');
      expect(reader.strings('ok'), ['a', 'b']);
      expect(
        () => reader.strings('bad'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Thing.bad[1]'),
          ),
        ),
      );
      expect(() => reader.strings('notList'), throwsFormatException);

      final map = Property(
        id: 'p',
        name: 'P',
        type: PropertyType.commercial,
        address: PropertyAddress(
          street: 'Mavoor Road',
          locality: '',
          city: 'Kozhikode',
          district: 'Kozhikode',
          state: 'Kerala',
          pinCode: '673004',
        ),
      ).toMap()..['amenities'] = ['Lift', null];
      expect(() => Property.fromMap(map), throwsFormatException);
    });
  });

  group('maintenance invariants', () {
    MaintenanceEvent event(
      String id,
      int hour,
      MaintenanceStatus to, [
      MaintenanceStatus? from,
    ]) => MaintenanceEvent(
      id: id,
      at: DateTime.utc(2024, 10, 23, hour),
      fromStatus: from,
      toStatus: to,
    );

    MaintenanceRequest request({
      MaintenanceStatus status = MaintenanceStatus.open,
      List<MaintenanceEvent>? events,
      String resolution = '',
      int? costPaise,
    }) => MaintenanceRequest(
      id: 'm',
      propertyId: 'p',
      title: 'Leak',
      category: MaintenanceCategory.plumbing,
      priority: MaintenancePriority.high,
      reportedOn: CalendarDate(2024, 10, 23),
      status: status,
      resolution: resolution,
      costPaise: costPaise,
      events: events ?? [event('e1', 9, MaintenanceStatus.open)],
    );

    test('resolution and cost only on completed requests', () {
      expect(() => request(resolution: 'Fixed'), throwsArgumentError);
      expect(
        () => request(
          status: MaintenanceStatus.inProgress,
          costPaise: 100,
          events: [
            event('e1', 9, MaintenanceStatus.open),
            event(
              'e2',
              10,
              MaintenanceStatus.inProgress,
              MaintenanceStatus.open,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('the log must be consistent with itself and the status', () {
      // Last event does not match the status.
      expect(
        () => request(status: MaintenanceStatus.inProgress),
        throwsArgumentError,
      );
      // First event with a "from".
      expect(
        () => request(
          events: [
            event(
              'e1',
              9,
              MaintenanceStatus.open,
              MaintenanceStatus.inProgress,
            ),
          ],
        ),
        throwsArgumentError,
      );
      // A change that does not start where the previous one ended.
      expect(
        () => request(
          status: MaintenanceStatus.inProgress,
          events: [
            event('e1', 9, MaintenanceStatus.open),
            event(
              'e2',
              10,
              MaintenanceStatus.inProgress,
              MaintenanceStatus.completed,
            ),
          ],
        ),
        throwsArgumentError,
      );
      // Times going backwards.
      expect(
        () => request(
          status: MaintenanceStatus.inProgress,
          events: [
            event('e1', 9, MaintenanceStatus.open),
            event(
              'e2',
              8,
              MaintenanceStatus.inProgress,
              MaintenanceStatus.open,
            ),
          ],
        ),
        throwsArgumentError,
      );
      // Duplicate event IDs.
      expect(
        () => request(
          status: MaintenanceStatus.inProgress,
          events: [
            event('e1', 9, MaintenanceStatus.open),
            event(
              'e1',
              10,
              MaintenanceStatus.inProgress,
              MaintenanceStatus.open,
            ),
          ],
        ),
        throwsArgumentError,
      );
      // An empty log is still allowed.
      expect(request(events: const []).events, isEmpty);
    });

    test('transitions keep the log ordered and IDs unique', () {
      final r = request();
      expect(
        () => r.transitionTo(
          MaintenanceStatus.inProgress,
          eventId: 'e2',
          at: DateTime.utc(2024, 10, 23, 8),
        ),
        throwsDomain('event-order'),
      );
      expect(
        () => r.transitionTo(
          MaintenanceStatus.inProgress,
          eventId: 'e1',
          at: DateTime.utc(2024, 10, 23, 10),
        ),
        throwsDomain('event-id'),
      );
      final moved = r.transitionTo(
        MaintenanceStatus.inProgress,
        eventId: 'e2',
        at: DateTime.utc(2024, 10, 23, 10),
      );
      expect(MaintenanceRequest.fromMap(moved.toMap()), moved);
    });
  });
}
