/// Static sample tenants and tenancies for the Tenant & Tenancy UI
/// (Stitch screens 16–21). Tenancies point at the Batch 03 mock
/// properties and units, so property and unit facts are not duplicated.
/// Nothing here is calculated or persisted.
library;

import 'package:resido/features/properties/data/property_mock_data.dart';

enum TenantStatus { active, unassigned, past }

class MockTenancy {
  const MockTenancy({
    required this.reference,
    required this.property,
    required this.unit,
    required this.rent,
    required this.deposit,
    required this.dueDay,
    required this.startDate,
    required this.endDate,
    required this.termLabel,
    required this.activeSince,
    required this.elapsedMonths,
    required this.totalMonths,
    this.noticePeriod = '30 Days Written',
    this.agreementLabel = '11-Month Tenancy Deed',
    this.maintenanceNote,
    this.utilities = const [],
  });

  final String reference;
  final MockProperty property;
  final MockUnit unit;
  final int rent;
  final int deposit;

  /// e.g. "1st of month".
  final String dueDay;
  final String startDate;

  /// Empty for an open-ended tenancy.
  final String endDate;
  final String termLabel;
  final String activeSince;

  /// Mock lease progress (shown as-is, not calculated from dates).
  final int elapsedMonths;
  final int totalMonths;
  final String noticePeriod;
  final String agreementLabel;
  final String? maintenanceNote;
  final List<TenancyUtility> utilities;

  int get remainingMonths => totalMonths - elapsedMonths;

  /// "Unit 101 (Ground Floor)".
  String get unitLabel => '${unit.name} (${unit.floor})';
}

class TenancyUtility {
  const TenancyUtility({
    required this.kind,
    required this.title,
    required this.detail,
    required this.tag,
    this.highlightTag = false,
  });

  final UtilityKind kind;
  final String title;
  final String detail;
  final String tag;
  final bool highlightTag;
}

enum UtilityKind { electricity, parking, water }

class MockTenant {
  const MockTenant({
    required this.id,
    required this.name,
    required this.occupation,
    required this.phone,
    required this.status,
    required this.residentId,
    this.email = '',
    this.notes = '',
    this.tenancy,
    this.overdueDays,
    this.paymentNote,
    this.unassignedNote = 'Tenant profile ready · No unit linked',
    this.pastSummary,
    this.pastUnit,
  });

  final String id;
  final String name;
  final String occupation;

  /// Ten-digit mobile number without the +91 prefix.
  final String phone;
  final TenantStatus status;
  final String residentId;
  final String email;
  final String notes;
  final MockTenancy? tenancy;

  /// Set when the current month's rent is overdue.
  final int? overdueDays;

  /// Note next to the rent on the list card ("Due 1st", "Paid for Nov").
  final String? paymentNote;
  final String unassignedNote;
  final String? pastSummary;
  final String? pastUnit;

  String get initials {
    final parts = name
        .replaceAll('Dr. ', '')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// "+91 98470 23411".
  String get displayPhone =>
      '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';

  bool get hasTenancy => tenancy != null;
}

abstract final class TenantMockData {
  static const _palmGrove = PropertyMockData.palmGrove;
  static const _aluva = PropertyMockData.aluvaVilla;

  static final suresh = MockTenant(
    id: 'suresh-kumar',
    name: 'Suresh Kumar',
    occupation: 'Software Professional · Kakkanad',
    phone: '9847023411',
    email: 'suresh.kumar@email.in',
    status: TenantStatus.active,
    residentId: 'KRL-EKM-2023-841',
    notes:
        'Software professional based in Kakkanad. Permanent residence in '
        'Thrissur. Prefers UPI payment on 1st of every month.',
    paymentNote: 'Due 1st',
    tenancy: MockTenancy(
      reference: '#TNC-EKM-2023-01',
      property: _palmGrove,
      unit: _palmGrove.units[0],
      rent: 24000,
      deposit: 72000,
      dueDay: '1st of month',
      startDate: '01 Oct 2023',
      endDate: '31 Aug 2024',
      termLabel: '11 Months Standard',
      activeSince: 'Oct 2023',
      elapsedMonths: 7,
      totalMonths: 11,
      maintenanceNote: 'Included in monthly rent',
      utilities: const [
        TenancyUtility(
          kind: UtilityKind.electricity,
          title: 'KSEB Electricity',
          detail: 'Consumer #4829103 (LT-1D)',
          tag: 'Meter #55201',
        ),
        TenancyUtility(
          kind: UtilityKind.parking,
          title: 'Reserved Car Parking',
          detail: 'Basement Slot #G-01',
          tag: 'Included',
          highlightTag: true,
        ),
        TenancyUtility(
          kind: UtilityKind.water,
          title: 'KWA & Borewell',
          detail: 'Dual Connection Sub-metered',
          tag: 'Meter #0912',
        ),
      ],
    ),
  );

  static final ananya = MockTenant(
    id: 'ananya-nair',
    name: 'Ananya Nair',
    occupation: 'Architect · Regional Studio',
    phone: '9447188920',
    email: 'ananya.nair@email.in',
    status: TenantStatus.active,
    residentId: 'KRL-EKM-2024-112',
    notes: 'Works from home on weekdays. Prefers WhatsApp for reminders.',
    overdueDays: 4,
    paymentNote: 'Grace period',
    tenancy: MockTenancy(
      reference: '#TNC-EKM-2024-02',
      property: _palmGrove,
      unit: _palmGrove.units[1],
      rent: 24000,
      deposit: 72000,
      dueDay: '1st of month',
      startDate: '01 Feb 2024',
      endDate: '31 Dec 2024',
      termLabel: '11 Months Standard',
      activeSince: 'Feb 2024',
      elapsedMonths: 3,
      totalMonths: 11,
    ),
  );

  static final thomas = MockTenant(
    id: 'thomas-k',
    name: 'Dr. Thomas K.',
    occupation: 'Consultant Surgeon · Rajagiri',
    phone: '9745512098',
    email: 'thomas.k@email.in',
    status: TenantStatus.active,
    residentId: 'KRL-EKM-2023-517',
    notes:
        'Family of four. Uses the riverside garden; requested monthly '
        'garden upkeep.',
    paymentNote: 'Paid for Nov',
    tenancy: MockTenancy(
      reference: '#TNC-EKM-2023-07',
      property: _aluva,
      unit: _aluva.units[0],
      rent: 30000,
      deposit: 90000,
      dueDay: '5th of month',
      startDate: '05 Jan 2024',
      endDate: '04 Jan 2025',
      termLabel: '1 Full Year',
      activeSince: 'Jan 2024',
      elapsedMonths: 4,
      totalMonths: 12,
    ),
  );

  static const rahul = MockTenant(
    id: 'rahul-varma',
    name: 'Rahul Varma',
    occupation: 'Software Engineer · Tech Zone',
    phone: '9895044123',
    email: 'rahul.varma@email.in',
    status: TenantStatus.unassigned,
    residentId: 'KRL-EKM-2024-205',
    notes:
        'Relocating from Bengaluru with family. Looking for a 3 BHK '
        'near Panampilly Nagar.',
  );

  static const meera = MockTenant(
    id: 'meera-nambiar',
    name: 'Meera Nambiar',
    occupation: 'Prospective tenant · Kakkanad Flat',
    phone: '9446277810',
    status: TenantStatus.unassigned,
    residentId: 'KRL-EKM-2024-219',
    notes: 'Prospective tenant. Visited Palm Grove Enclave on 12 Oct.',
    unassignedNote: 'Lease agreement in preparation',
  );

  static const firoz = MockTenant(
    id: 'firoz-khan',
    name: 'Firoz Khan',
    occupation: 'Ended Oct 2024',
    phone: '9847111223',
    status: TenantStatus.past,
    residentId: 'KRL-EKM-2022-094',
    notes: 'Former tenant. Left the unit in good condition.',
    pastSummary: 'Former tenant at Fort Kochi Suite 2B',
    pastUnit: 'Fort Kochi Suite 2B',
  );

  static final tenants = [suresh, ananya, thomas, rahul, meera, firoz];

  static List<MockTenant> get unassigned =>
      tenants.where((t) => t.status == TenantStatus.unassigned).toList();
}
