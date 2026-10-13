import 'package:flutter_test/flutter_test.dart';
import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/record_status.dart';
import 'package:resido/features/maintenance/domain/maintenance_request.dart';
import 'package:resido/features/profile/domain/user_profile.dart';
import 'package:resido/features/properties/domain/property.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';
import 'package:resido/features/tenants/domain/tenant.dart';

import 'fixtures.dart';

PropertyAddress kochiAddress() => PropertyAddress(
  street: 'Plot 18, 5th Cross Road',
  locality: 'Panampilly Nagar',
  city: 'Kochi',
  district: 'Ernakulam',
  state: 'Kerala',
  pinCode: '682036',
);

MaintenanceRequest leak() => MaintenanceRequest(
  id: 'MNT-1',
  propertyId: 'palm-grove',
  unitId: 'palm-grove-102',
  title: 'Master Bath Pipe Leak',
  category: MaintenanceCategory.plumbing,
  priority: MaintenancePriority.high,
  reportedOn: CalendarDate(2024, 10, 23),
  events: [
    MaintenanceEvent(
      id: 'e1',
      at: DateTime.utc(2024, 10, 23, 12),
      toStatus: MaintenanceStatus.open,
    ),
  ],
);

void main() {
  group('serialization round trips', () {
    test('every model survives toMap/fromMap unchanged', () {
      final property = Property(
        id: 'palm-grove',
        name: 'Palm Grove Enclave',
        type: PropertyType.apartmentBuilding,
        address: kochiAddress(),
        amenities: const ['Solar Inverter'],
      );
      final unit = Unit(
        id: 'palm-grove-101',
        propertyId: 'palm-grove',
        label: '101',
        defaultRentPaise: 2400000,
        areaSqFt: 1410,
        readiness: UnitReadiness.refreshing,
      );
      final tenant = Tenant(
        id: 'suresh-kumar',
        name: 'Suresh Kumar',
        phone: '+919847023411',
      );
      final tenancy = tenancyA().end(CalendarDate(2024, 8, 31));
      final due = RentDue.forTenancy(tenancy, RentPeriod(2024, 8));
      final payment = paymentFor(
        due,
        'p1',
        2400000,
      ).voided(on: CalendarDate(2024, 8, 9), reason: 'Bounced');
      final profile = UserProfile(
        id: 'u1',
        displayName: 'Harikrishnan Menon',
        email: 'harikrishnan.menon@keralaestates.in',
        phone: '+919847012890',
        preferences: NotificationPreferences.defaults.copyWith(
          monthlyDigest: true,
        ),
      );
      final request = leak().transitionTo(
        MaintenanceStatus.completed,
        eventId: 'e2',
        at: DateTime.utc(2024, 10, 24, 6),
        completedOn: CalendarDate(2024, 10, 24),
        resolution: 'Trap seal replaced',
        costPaise: 145000,
      );

      expect(Property.fromMap(property.toMap()), property);
      expect(Unit.fromMap(unit.toMap()), unit);
      expect(Tenant.fromMap(tenant.toMap()), tenant);
      expect(Tenancy.fromMap(tenancy.toMap()), tenancy);
      expect(RentDue.fromMap(due.toMap()), due);
      expect(Payment.fromMap(payment.toMap()), payment);
      expect(UserProfile.fromMap(profile.toMap()), profile);
      expect(MaintenanceRequest.fromMap(request.toMap()), request);
    });

    test('enums serialize by name; maps hold only plain values', () {
      final map = tenancyA().toMap();
      expect(map['status'], 'active');
      expect(map['startDate'], '2024-01-01');
      expect(map['rentPaise'], isA<int>());
      expect(
        map.values.every(
          (v) => v == null || v is String || v is int || v is bool,
        ),
        isTrue,
      );
    });

    test('malformed maps fail loudly at the boundary', () {
      final map = tenancyA().toMap()..['status'] = 'paused';
      expect(() => Tenancy.fromMap(map), throwsFormatException);
      final noRent = tenancyA().toMap()..remove('rentPaise');
      expect(() => Tenancy.fromMap(noRent), throwsFormatException);
      final badDate = tenancyA().toMap()..['startDate'] = '01 Jan 2024';
      expect(() => Tenancy.fromMap(badDate), throwsFormatException);
      final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 2)).toMap()
        ..['id'] = 'T-A_2024-03';
      expect(() => RentDue.fromMap(due), throwsFormatException);
    });
  });

  group('model invariants', () {
    test('stable IDs and required relationships', () {
      final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 2));
      expect(due.id, 'T-A_2024-02');
      expect(due.dueDate, CalendarDate(2024, 2, 5));
      expect(
        () => Tenancy(
          id: 't',
          tenantId: '',
          unitId: 'u',
          propertyId: 'p',
          startDate: CalendarDate(2024, 1, 1),
          rentPaise: 100,
          depositPaise: 0,
          dueDay: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => Unit(id: 'u', propertyId: ' ', label: '1', defaultRentPaise: 0),
        throwsArgumentError,
      );
    });

    test('money, due day and date range rules', () {
      expect(() => tenancyA(rentPaise: 0), throwsArgumentError);
      expect(() => tenancyA(rentPaise: -100), throwsArgumentError);
      expect(() => tenancyA(dueDay: 29), throwsArgumentError);
      expect(
        () => tenancyA(
          start: CalendarDate(2024, 5, 1),
          end: CalendarDate(2024, 4, 30),
        ),
        throwsArgumentError,
      );
      expect(
        () => paymentFor(
          RentDue.forTenancy(tenancyA(), RentPeriod(2024, 1)),
          'p',
          0,
        ),
        throwsArgumentError,
      );
    });

    test('tenancy end dates are inclusive', () {
      final t = tenancyA(end: CalendarDate(2024, 6, 30));
      expect(t.covers(CalendarDate(2024, 6, 30)), isTrue);
      expect(t.covers(CalendarDate(2024, 7, 1)), isFalse);
      expect(t.covers(CalendarDate(2023, 12, 31)), isFalse);
      final ended = t.end(CalendarDate(2024, 3, 15));
      expect(ended.lastDay, CalendarDate(2024, 3, 15));
      expect(ended.status, TenancyStatus.ended);
      expect(() => ended.end(CalendarDate(2024, 3, 20)), throwsStateError);
    });

    test('addresses: Kerala PIN only for Kerala', () {
      expect(kochiAddress().isKerala, isTrue);
      expect(
        () => PropertyAddress(
          street: 'MG Road',
          locality: '',
          city: 'Kochi',
          district: 'Ernakulam',
          state: 'Kerala',
          pinCode: '560001',
        ),
        throwsArgumentError,
      );
      final bengaluru = PropertyAddress(
        street: 'MG Road',
        locality: '',
        city: 'Bengaluru',
        district: 'Bengaluru Urban',
        state: 'Karnataka',
        pinCode: '560001',
      );
      expect(bengaluru.isKerala, isFalse);
    });

    test('phones must be canonical +91', () {
      expect(
        () => Tenant(id: 't', name: 'A', phone: '9847023411'),
        throwsArgumentError,
      );
    });

    test('voided payments carry a date and reason', () {
      final due = RentDue.forTenancy(tenancyA(), RentPeriod(2024, 1));
      final p = paymentFor(due, 'p', 100);
      expect(
        () => p.voided(on: CalendarDate(2024, 1, 9), reason: ' '),
        throwsArgumentError,
      );
      final v = p.voided(on: CalendarDate(2024, 1, 9), reason: 'Bounced');
      expect(v.isVoided, isTrue);
      expect(
        () => v.voided(on: CalendarDate(2024, 1, 9), reason: 'x'),
        throwsStateError,
      );
      expect(p.status, PaymentStatus.recorded);
    });

    test('lists are immutable', () {
      final property = Property(
        id: 'p',
        name: 'P',
        type: PropertyType.commercial,
        address: kochiAddress(),
        amenities: ['A'],
      );
      expect(() => property.amenities.add('B'), throwsUnsupportedError);
      expect(() => leak().events.clear(), throwsUnsupportedError);
      expect(property.status, RecordStatus.active);
    });
  });

  group('maintenance status transitions', () {
    test('open → in progress → completed, logged in order', () {
      final started = leak().transitionTo(
        MaintenanceStatus.inProgress,
        eventId: 'e2',
        at: DateTime.utc(2024, 10, 24, 5),
        note: 'Plumber assigned',
      );
      final done = started.transitionTo(
        MaintenanceStatus.completed,
        eventId: 'e3',
        at: DateTime.utc(2024, 10, 25, 5),
        completedOn: CalendarDate(2024, 10, 25),
        resolution: 'Seal replaced',
      );
      expect(done.events.map((e) => e.toStatus), [
        MaintenanceStatus.open,
        MaintenanceStatus.inProgress,
        MaintenanceStatus.completed,
      ]);
      expect(done.events.last.fromStatus, MaintenanceStatus.inProgress);
      expect(done.isActive, isFalse);
    });

    test('completion needs a date and resolution; reopening clears them', () {
      expect(
        () => leak().transitionTo(
          MaintenanceStatus.completed,
          eventId: 'e2',
          at: DateTime.utc(2024, 10, 24),
          completedOn: CalendarDate(2024, 10, 24),
        ),
        throwsA(isA<DomainException>()),
      );
      expect(
        () => leak().transitionTo(
          MaintenanceStatus.completed,
          eventId: 'e2',
          at: DateTime.utc(2024, 10, 24),
          completedOn: CalendarDate(2024, 10, 1),
          resolution: 'x',
        ),
        throwsA(isA<DomainException>()),
      );
      final done = leak().transitionTo(
        MaintenanceStatus.completed,
        eventId: 'e2',
        at: DateTime.utc(2024, 10, 24),
        completedOn: CalendarDate(2024, 10, 24),
        resolution: 'Fixed',
        costPaise: 145000,
      );
      final reopened = done.transitionTo(
        MaintenanceStatus.open,
        eventId: 'e3',
        at: DateTime.utc(2024, 10, 26),
      );
      expect(reopened.completedOn, isNull);
      expect(reopened.resolution, isEmpty);
      expect(reopened.costPaise, isNull);
    });

    test('a no-op transition is rejected', () {
      expect(
        () => leak().transitionTo(
          MaintenanceStatus.open,
          eventId: 'e2',
          at: DateTime.utc(2024, 10, 24),
        ),
        throwsA(
          isA<DomainException>().having(
            (e) => e.code,
            'code',
            'no-status-change',
          ),
        ),
      );
    });

    test('entire-property requests have no unit', () {
      expect(
        () => MaintenanceRequest(
          id: 'm',
          propertyId: 'p',
          unitId: 'u',
          entireProperty: true,
          title: 'Motor',
          category: MaintenanceCategory.waterMotor,
          priority: MaintenancePriority.high,
          reportedOn: CalendarDate(2024, 10, 24),
        ),
        throwsArgumentError,
      );
    });
  });
}
