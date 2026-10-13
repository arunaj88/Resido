/// Static sample data for the Dashboard UI (Stitch "06. Dashboard").
/// Nothing here is calculated; values mirror the approved design.
library;

import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    this.valueSuffix,
    required this.caption,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final String caption;
}

enum PendingActionKind { overdueRent, dueSoonRent, maintenance }

class PendingAction {
  const PendingAction({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.footnote,
  });

  final PendingActionKind kind;
  final String title;
  final String subtitle;
  final String badge;
  final String footnote;
}

enum ActivityKind { rentReceived, leaseSigned }

class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.tag,
    required this.note,
  });

  final ActivityKind kind;
  final String title;
  final String time;
  final String subtitle;
  final String tag;
  final String note;
}

abstract final class DashboardMockData {
  static const landlordFirstName = 'Harikrishnan';
  static const landlordFullName = 'Harikrishnan Menon';
  static const dateLabel = 'Thursday, 24 October';
  static const locationLabel = 'Kochi • Aluva';
  static const portfolioLabel = 'Kochi & Aluva Portfolio Overview';

  static const estates = DashboardMetric(
    label: 'Estates',
    value: '4',
    caption: 'Kakkanad, Aluva, Panampilly',
  );
  static const capacity = DashboardMetric(
    label: 'Capacity',
    value: '12',
    valueSuffix: 'Units',
    caption: 'Across 4 locations',
  );
  static const occupancy = DashboardMetric(
    label: 'Occupancy',
    value: '10',
    valueSuffix: 'Active',
    caption: '83.3% Tenanted',
  );
  static const turnover = DashboardMetric(
    label: 'Turnover',
    value: '2',
    valueSuffix: 'Vacant',
    caption: 'Ready for viewing',
  );

  // Rent collection (amounts in rupees).
  static const rentMonth = 'October';
  static const rentCycleNote = 'Billing cycle closes in 7 days';
  static const rentReceived = 152000;
  static const rentTarget = 185000;
  static const rentPending = 33000;
  static const rentOutstandingUnits = 2;
  static const rentCollectedPercent = 82;

  static final pendingActions = [
    PendingAction(
      kind: PendingActionKind.overdueRent,
      title: '${InrFormat.full(11000)} Overdue',
      subtitle: 'Ananya Nair • Green Valley Villa 2',
      badge: '4 Days Overdue',
      footnote: 'Was due on 20 Oct',
    ),
    PendingAction(
      kind: PendingActionKind.dueSoonRent,
      title: '${InrFormat.full(22000)} Due Soon',
      subtitle: 'Rahul Varma • Palm Grove Apt #3B',
      badge: 'Due 28 Oct',
      footnote: 'Grace period: 3 days',
    ),
    PendingAction(
      kind: PendingActionKind.maintenance,
      // Short form of Maintenance request #MNT-2024-PG-04 (the full title
      // does not fit this one-line card).
      title: 'Master Bath Pipe Leak',
      subtitle:
          '${MaintenanceMockData.seepage.property.name} · Unit 102 '
          '• Tenant Reported',
      badge: 'High Priority',
      footnote: 'Raised yesterday, 5:30 PM',
    ),
  ];

  static const spotlightLocality = 'Panampilly Nagar';
  static const spotlightName = 'Palm Grove Enclave';
  static const spotlightUnit = 'Unit 3B • 3 BHK Premium Flat';
  static const spotlightStatus = 'Inspected 12 Oct • Good Condition';
  static const spotlightImage = 'assets/images/spotlight_palm_grove.jpg';

  static final recentActivity = [
    ActivityItem(
      kind: ActivityKind.rentReceived,
      title: 'Rent Received: ${InrFormat.full(24000)}',
      time: '9:30 AM',
      subtitle: 'Suresh Kumar • Kakkanad Flat 4A',
      tag: 'UPI Auto-Credit',
      note: 'Receipt #REC-8842',
    ),
    ActivityItem(
      kind: ActivityKind.leaseSigned,
      title: 'Lease Agreement Signed',
      time: 'Yesterday',
      subtitle: 'Dr. Thomas K. • Aluva Villa Estate',
      tag: '11-Month Kerala Tenancy',
      note: 'Deposit ${InrFormat.full(75000)} Locked',
    ),
  ];

  static const tipTitle = 'Post-Monsoon Maintenance Check';
  static const tipBody =
      'Review roof sealing in Kakkanad & Aluva before November.';
}
