import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/app_scope.dart';
import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/features/maintenance/domain/maintenance_request.dart';
import 'package:resido/features/profile/domain/user_profile.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_calculator.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';
import 'package:resido/features/tenants/domain/tenant.dart';

Matcher throwsDomain(String code) =>
    throwsA(isA<DomainException>().having((e) => e.code, 'code', code));

void main() {
  late AppDependencies deps;
  setUp(() => deps = AppDependencies.inMemorySeeded());

  group('seeded data keeps the mock relationships', () {
    test('properties and units', () async {
      final properties = await deps.properties.getProperties();
      expect(properties.map((p) => p.id), [
        'palm-grove',
        'aluva-villa',
        'kakkanad-residency',
        'malabar-heights',
      ]);
      expect((await deps.properties.getUnits()).length, 12);
      final palm = await deps.properties.getUnits(propertyId: 'palm-grove');
      expect(palm.map((u) => u.label), ['101', '102', '201', '202']);
      final u101 = await deps.properties.getUnit('palm-grove-101');
      expect(u101!.defaultRentPaise, 2400000);
      expect(properties.first.address.isKerala, isTrue);
    });

    test('tenants and tenancies link to real tenants and units', () async {
      expect((await deps.tenants.getTenants()).length, 6);
      final tenancies = await deps.tenancies.getTenancies();
      expect(tenancies.map((t) => t.id), [
        'TNC-EKM-2023-01',
        'TNC-EKM-2024-02',
        'TNC-EKM-2023-07',
      ]);
      for (final t in tenancies) {
        expect(await deps.tenants.getTenant(t.tenantId), isNotNull);
        final unit = await deps.properties.getUnit(t.unitId);
        expect(unit, isNotNull);
        expect(unit!.propertyId, t.propertyId);
      }
      final ananya = await deps.tenancies.getTenancy('TNC-EKM-2024-02');
      expect(ananya!.unitId, 'palm-grove-102');
      expect(ananya.startDate, CalendarDate(2024, 2, 1));
      expect(ananya.dueDay, 1);
      final suresh = await deps.tenants.getTenant('suresh-kumar');
      expect(suresh!.phone, '+919847023411');
    });

    test('October 2024 rent: only tenancies that bill October', () async {
      final dues = await deps.rent.getDues();
      // Suresh's agreement ended 31 Aug 2024, so it has no October due.
      expect(dues.map((d) => d.id), [
        'TNC-EKM-2023-07_2024-10',
        'TNC-EKM-2024-02_2024-10',
      ]);
      final ananyaDue = await deps.rent.getDue('TNC-EKM-2024-02_2024-10');
      final summary = RentCalculator.summarize(
        ananyaDue!,
        await deps.rent.getPayments(rentDueId: ananyaDue.id),
        asOf: CalendarDate(2024, 10, 24),
        graceDays: 5,
      );
      // Matches the Rent screens: ₹13,000 paid, ₹11,000 overdue.
      expect(summary.paidPaise, 1300000);
      expect(summary.outstandingPaise, 1100000);
      expect(summary.status, RentDueStatus.overdue);
    });

    test('maintenance requests and profile', () async {
      final requests = await deps.maintenance.getRequests();
      expect(requests.length, 6);
      final seepage = await deps.maintenance.getRequest('MNT-2024-PG-04');
      expect(seepage!.unitId, 'palm-grove-102');
      expect(seepage.tenantId, 'ananya-nair');
      expect(seepage.status, MaintenanceStatus.inProgress);
      expect(seepage.events.map((e) => e.toStatus), [
        MaintenanceStatus.open,
        MaintenanceStatus.inProgress,
      ]);
      final motor = await deps.maintenance.getRequest('MNT-2024-PG-03');
      expect(motor!.entireProperty, isTrue);
      expect(motor.unitId, isNull);
      final latch = await deps.maintenance.getRequest('MNT-2024-KKD-01');
      expect(latch!.costPaise, 145000);
      expect(latch.completedOn, CalendarDate(2024, 10, 18));

      final profile = await deps.profile.getProfile();
      expect(profile!.accountCode, 'KL-9240');
      expect(profile.phone, '+919847012890');
      expect(profile.preferences.monthlyDigest, isFalse);
    });
  });

  group('lookups and missing records', () {
    test('unknown IDs return null', () async {
      expect(await deps.properties.getProperty('nope'), isNull);
      expect(await deps.properties.getUnit('nope'), isNull);
      expect(await deps.tenants.getTenant('nope'), isNull);
      expect(await deps.tenancies.getTenancy('nope'), isNull);
      expect(await deps.rent.getDue('nope'), isNull);
      expect(await deps.rent.getPayment('nope'), isNull);
      expect(await deps.maintenance.getRequest('nope'), isNull);
    });

    test('updates of missing records throw', () async {
      expect(
        () => deps.tenancies.endTenancy('nope', CalendarDate(2024, 10, 1)),
        throwsA(isA<RecordNotFoundException>()),
      );
      expect(
        () => deps.rent.voidPayment(
          'nope',
          on: CalendarDate(2024, 10, 1),
          reason: 'x',
        ),
        throwsA(isA<RecordNotFoundException>()),
      );
    });
  });

  group('in-memory updates', () {
    test('instances are isolated from each other', () async {
      final other = AppDependencies.inMemorySeeded();
      await deps.tenants.saveTenant(Tenant(id: 'new', name: 'Kavitha Pillai'));
      expect(await deps.tenants.getTenant('new'), isNotNull);
      expect(await other.tenants.getTenant('new'), isNull);
    });

    test('one active tenancy per unit; ending frees the unit', () async {
      await deps.tenants.saveTenant(Tenant(id: 'rahul', name: 'Rahul'));
      Tenancy newTenancy(String unitId) => Tenancy(
        id: 'TNC-NEW',
        tenantId: 'rahul',
        unitId: unitId,
        propertyId: 'palm-grove',
        startDate: CalendarDate(2024, 11, 1),
        rentPaise: 2000000,
        depositPaise: 0,
        dueDay: 1,
      );
      // Unit 102 is held by Ananya's active tenancy.
      expect(
        () => deps.tenancies.saveTenancy(newTenancy('palm-grove-102')),
        throwsDomain('unit-occupied'),
      );
      await deps.tenancies.saveTenancy(newTenancy('palm-grove-201'));
      expect(
        (await deps.tenancies.activeTenancyForUnit('palm-grove-201'))!.id,
        'TNC-NEW',
      );

      await deps.tenancies.endTenancy('TNC-NEW', CalendarDate(2025, 3, 31));
      expect(
        await deps.tenancies.activeTenancyForUnit('palm-grove-201'),
        isNull,
      );
      expect(
        (await deps.tenancies.getTenancy('TNC-NEW'))!.endedOn,
        CalendarDate(2025, 3, 31),
      );
    });

    test('tenancy links are validated', () async {
      Tenancy t({String tenant = 'rahul-varma', String property = 'aluva'}) =>
          Tenancy(
            id: 'X',
            tenantId: tenant,
            unitId: 'palm-grove-201',
            propertyId: property,
            startDate: CalendarDate(2024, 11, 1),
            rentPaise: 100,
            depositPaise: 0,
            dueDay: 1,
          );
      expect(
        () => deps.tenancies.saveTenancy(t(tenant: 'ghost')),
        throwsA(isA<RecordNotFoundException>()),
      );
      expect(
        () => deps.tenancies.saveTenancy(t()),
        throwsDomain('tenancy-property-mismatch'),
      );
    });

    test('payments: idempotent retry, overpayment, void and redo', () async {
      const dueId = 'TNC-EKM-2024-02_2024-10';
      Payment pay(String id, int paise) => Payment(
        id: id,
        rentDueId: dueId,
        tenancyId: 'TNC-EKM-2024-02',
        tenantId: 'ananya-nair',
        amountPaise: paise,
        paidOn: CalendarDate(2024, 10, 24),
        mode: PaymentMode.cash,
      );

      expect(
        () => deps.rent.recordPayment(pay('p-over', 1100001)),
        throwsDomain('overpayment'),
      );
      final p = pay('p-1', 1100000);
      await deps.rent.recordPayment(p);
      await deps.rent.recordPayment(p); // double tap / retry
      expect((await deps.rent.getPayments(rentDueId: dueId)).length, 2);

      final due = (await deps.rent.getDue(dueId))!;
      expect(
        RentCalculator.paidPaise(
          due,
          await deps.rent.getPayments(rentDueId: dueId),
        ),
        2400000,
      );
      expect(
        () => deps.rent.recordPayment(pay('p-1', 500)),
        throwsDomain('duplicate-payment-id'),
      );

      await deps.rent.voidPayment(
        'p-1',
        on: CalendarDate(2024, 10, 25),
        reason: 'Entered by mistake',
      );
      final after = await deps.rent.getPayments(rentDueId: dueId);
      expect(RentCalculator.paidPaise(due, after), 1300000);
      expect(
        () => deps.rent.voidPayment(
          'p-1',
          on: CalendarDate(2024, 10, 25),
          reason: 'again',
        ),
        throwsDomain('payment-voided'),
      );
      // The voided amount can be recorded again under a new ID.
      await deps.rent.recordPayment(pay('p-2', 1100000));
    });

    test('a payment against an unknown due is rejected', () async {
      expect(
        () => deps.rent.recordPayment(
          Payment(
            id: 'p',
            rentDueId: 'TNC-EKM-2023-01_2024-10',
            tenancyId: 'TNC-EKM-2023-01',
            tenantId: 'suresh-kumar',
            amountPaise: 100,
            paidOn: CalendarDate(2024, 10, 1),
            mode: PaymentMode.upi,
          ),
        ),
        throwsA(isA<RecordNotFoundException>()),
      );
    });

    test('ensureDues is idempotent and respects tenancy bounds', () async {
      final suresh = (await deps.tenancies.getTenancy('TNC-EKM-2023-01'))!;
      final first = await deps.rent.ensureDues(
        suresh,
        through: RentPeriod(2024, 12),
      );
      // 01 Oct 2023 – 31 Aug 2024: 11 dues, none after the end date.
      expect(first.length, 11);
      expect(first.last.period, RentPeriod(2024, 8));
      expect(
        await deps.rent.ensureDues(suresh, through: RentPeriod(2024, 12)),
        isEmpty,
      );
      expect(
        (await deps.rent.getDues(tenancyId: suresh.id)).first.id,
        RentDue.idFor(suresh.id, RentPeriod(2023, 10)),
      );
    });

    test('maintenance links and profile preferences', () async {
      final seepage = (await deps.maintenance.getRequest('MNT-2024-PG-04'))!;
      final done = seepage.transitionTo(
        MaintenanceStatus.completed,
        eventId: 'e3',
        at: DateTime.utc(2024, 10, 25, 6),
        completedOn: CalendarDate(2024, 10, 25),
        resolution: 'Seal replaced',
      );
      await deps.maintenance.saveRequest(done);
      expect(
        (await deps.maintenance.getRequest('MNT-2024-PG-04'))!.status,
        MaintenanceStatus.completed,
      );
      expect(
        () => deps.maintenance.saveRequest(
          MaintenanceRequest(
            id: 'bad',
            propertyId: 'aluva-villa',
            unitId: 'palm-grove-101',
            title: 'Wrong unit',
            category: MaintenanceCategory.other,
            priority: MaintenancePriority.low,
            reportedOn: CalendarDate(2024, 10, 24),
          ),
        ),
        throwsDomain('unit-property-mismatch'),
      );

      final updated = await deps.profile.updatePreferences(
        NotificationPreferences.defaults.copyWith(monthlyDigest: true),
      );
      expect(updated.preferences.monthlyDigest, isTrue);
      expect(
        (await deps.profile.getProfile())!.preferences.monthlyDigest,
        isTrue,
      );
    });
  });
}
