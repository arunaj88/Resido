import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';

/// Small, deterministic domain fixtures for unit tests (independent of the
/// app's seeded mock data).

/// ₹24,000/month, due on the 5th with 5 grace days, 01 Jan 2024 – 31 Dec
/// 2024.
Tenancy tenancyA({
  String id = 'T-A',
  CalendarDate? start,
  CalendarDate? end,
  bool openEnded = false,
  int dueDay = 5,
  int graceDays = 5,
  int rentPaise = 2400000,
}) => Tenancy(
  id: id,
  tenantId: 'tenant-$id',
  unitId: 'unit-$id',
  propertyId: 'property-1',
  startDate: start ?? CalendarDate(2024, 1, 1),
  endDate: openEnded ? null : (end ?? CalendarDate(2024, 12, 31)),
  rentPaise: rentPaise,
  depositPaise: 7200000,
  dueDay: dueDay,
  graceDays: graceDays,
);

Payment paymentFor(
  RentDue due,
  String id,
  int amountPaise, {
  CalendarDate? paidOn,
}) => Payment(
  id: id,
  rentDueId: due.id,
  tenancyId: due.tenancyId,
  tenantId: due.tenantId,
  amountPaise: amountPaise,
  paidOn: paidOn ?? due.dueDate,
  mode: PaymentMode.upi,
);
