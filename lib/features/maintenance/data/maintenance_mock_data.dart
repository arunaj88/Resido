import 'package:flutter/material.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';

// Static maintenance requests for the UI (October 2024, matching the rent
// screens). Nothing here is created, updated or saved.

enum MaintenanceStatus {
  open('Open', 'Awaiting inspection or technician assignment'),
  inProgress('In Progress', 'Repair or replacement work currently underway'),
  completed('Completed', 'Work inspected and issue resolved');

  const MaintenanceStatus(this.label, this.description);

  final String label;
  final String description;
}

enum MaintenancePriority {
  low('Low', 'Routine wear', Icons.low_priority),
  medium('Medium', 'This week', Icons.update),
  high('High', 'Active leak', Icons.warning_amber_rounded);

  const MaintenancePriority(this.label, this.detail, this.icon);

  final String label;
  final String detail;
  final IconData icon;
}

enum MaintenanceCategory {
  plumbing('Plumbing', Icons.plumbing),
  electrical('Electrical', Icons.bolt),
  structural('Structural / Wood', Icons.handyman_outlined),
  waterMotor('Water & Motor Pump', Icons.water_damage_outlined),
  appliance('Appliance / AC', Icons.kitchen_outlined),
  painting('Painting & Monsoon', Icons.format_paint_outlined),
  other('Other Maintenance Issue', Icons.more_horiz);

  const MaintenanceCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class MaintenanceLogEntry {
  const MaintenanceLogEntry({
    required this.title,
    required this.time,
    required this.note,
    required this.by,
    this.current = false,
  });

  final String title;
  final String time;
  final String note;
  final String by;

  /// Highlighted as the latest entry.
  final bool current;
}

class MaintenanceRequest {
  const MaintenanceRequest({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryLabel,
    required this.priority,
    required this.status,
    required this.property,
    required this.locationLabel,
    required this.reported,
    required this.reportedLong,
    required this.summary,
    required this.summaryIcon,
    required this.footer,
    required this.footerIcon,
    required this.description,
    this.unitDetail = '',
    this.tenantName,
    this.tenantPhone,
    this.assignee,
    this.assigneeRole,
    this.assigneePhone,
    this.assignedSince,
    this.attachments = const [],
    this.log = const [],
    this.completedOn,
    this.cost,
    this.resolution,
    this.entireProperty = false,
  });

  /// "#MNT-2024-PG-04".
  final String id;
  final String title;
  final MaintenanceCategory category;

  /// Card label ("Plumbing & Motor").
  final String categoryLabel;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final MockProperty property;

  /// "Unit 102 (Ananya Nair)", "Entire Property (Borewell Pump)".
  final String locationLabel;

  /// "Unit 102 (Ground Floor · 3 BHK)" for the details screen.
  final String unitDetail;
  final String reported;
  final String reportedLong;

  /// One-line card note and its icon.
  final String summary;
  final IconData summaryIcon;
  final String footer;
  final IconData footerIcon;
  final String description;
  final String? tenantName;
  final String? tenantPhone;
  final String? assignee;
  final String? assigneeRole;
  final String? assigneePhone;
  final String? assignedSince;
  final List<String> attachments;
  final List<MaintenanceLogEntry> log;
  final String? completedOn;
  final String? cost;
  final String? resolution;
  final bool entireProperty;

  String get location => '${property.name} · $locationLabel';
}

abstract final class MaintenanceMockData {
  static const today = '24 Oct 2024';
  static const activeSummary = '4 Active Requests · 2 High Priority';

  static const motor = MaintenanceRequest(
    id: '#MNT-2024-PG-03',
    title: 'Overhead Water Tank Motor Tripping',
    category: MaintenanceCategory.waterMotor,
    categoryLabel: 'Plumbing & Motor',
    priority: MaintenancePriority.high,
    status: MaintenanceStatus.inProgress,
    property: PropertyMockData.palmGrove,
    locationLabel: 'Entire Property (Borewell Pump)',
    unitDetail: 'Entire property · Borewell pump room',
    entireProperty: true,
    reported: 'Reported 24 Oct 2024',
    reportedLong: 'Reported 24 Oct, 08:10 AM',
    summary:
        'Submersible pump circuit breaker trips after 10 mins. Local '
        'electrician Varghese called for testing.',
    summaryIcon: Icons.handyman_outlined,
    footer: 'Varghese (+91 94471 28990)',
    footerIcon: Icons.phone_in_talk_outlined,
    description:
        'Submersible pump circuit breaker trips after about 10 minutes of '
        'running. Overhead tank not filling fully in the mornings.',
    assignee: 'Varghese',
    assigneeRole: 'Electrician',
    assigneePhone: '+91 94471 28990',
    assignedSince: 'Since 24 Oct',
    log: [
      MaintenanceLogEntry(
        title: 'Moved to In Progress',
        time: '24 Oct · 10:15 AM',
        note: 'Electrician Varghese testing the pump starter and breaker.',
        by: 'Logged by Landlord',
        current: true,
      ),
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '24 Oct · 08:10 AM',
        note: 'Tank not filling; breaker found tripped in the pump room.',
        by: 'Logged by Landlord',
      ),
    ],
  );

  static const seepage = MaintenanceRequest(
    id: '#MNT-2024-PG-04',
    title: 'Master Bath Ceiling Seepage & Pipe Leak',
    category: MaintenanceCategory.plumbing,
    categoryLabel: 'Plumbing',
    priority: MaintenancePriority.high,
    status: MaintenanceStatus.inProgress,
    property: PropertyMockData.palmGrove,
    locationLabel: 'Unit 102 (Ananya Nair)',
    unitDetail: 'Unit 102 (Ground Floor · 3 BHK)',
    reported: 'Reported 23 Oct 2024',
    reportedLong: 'Reported 23 Oct, 05:30 PM',
    summary:
        'Monsoon dampness spreading from Unit 202 concealed pipe. Plumber '
        'Haridas has inspected the trap.',
    summaryIcon: Icons.water_damage_outlined,
    footer: 'Plumber: Haridas (+91 94471 88200)',
    footerIcon: Icons.person_outline,
    description:
        'Damp patch forming on bathroom ceiling directly under Unit 202 '
        'drainage line. Tenant noticed slow dripping since Tuesday evening. '
        'Water supply valve checked and isolated temporarily.',
    tenantName: 'Ananya Nair',
    tenantPhone: '+91 94471 88920',
    assignee: 'Haridas',
    assigneeRole: 'Senior Plumber',
    assigneePhone: '+91 94471 88200',
    assignedSince: 'Since 24 Oct',
    attachments: ['Ceiling_01.jpg'],
    log: [
      MaintenanceLogEntry(
        title: 'Moved to In Progress',
        time: '24 Oct · 11:00 AM',
        note:
            'Plumber Haridas inspected Unit 202 trap. Replacement seal '
            'ordered from Kadavanthra hardware store. Work scheduled for '
            'tomorrow 10:00 AM.',
        by: 'Logged by Landlord',
        current: true,
      ),
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '23 Oct · 05:30 PM',
        note:
            'Tenant reported the leak to the landlord. High priority set due '
            'to active drip onto ceiling plasterboard.',
        by: 'Logged by Landlord',
      ),
    ],
  );

  static const voltage = MaintenanceRequest(
    id: '#MNT-2024-ALV-01',
    title: 'KSEB Main DB Phase 2 Voltage Fluctuation',
    category: MaintenanceCategory.electrical,
    categoryLabel: 'Electrical',
    priority: MaintenancePriority.medium,
    status: MaintenanceStatus.open,
    property: PropertyMockData.aluvaVilla,
    locationLabel: 'Main Villa',
    unitDetail: 'Main Villa (Ground + 1st Floor · 4 BHK)',
    reported: 'Reported 21 Oct 2024',
    reportedLong: 'Reported 21 Oct, 07:45 PM',
    summary:
        'Living room AC trips during peak evening hours. KSEB Aluva section '
        'complaint docket #KL-4920 lodged.',
    summaryIcon: Icons.electric_meter_outlined,
    footer: 'KSEB Docket: KL-4920',
    footerIcon: Icons.confirmation_number_outlined,
    description:
        'Living room AC trips during peak evening hours. Phase 2 voltage '
        'drops at the main distribution board. Complaint docket #KL-4920 '
        'lodged with the KSEB Aluva section.',
    tenantName: 'Dr. Thomas K.',
    tenantPhone: '+91 97455 12098',
    log: [
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '21 Oct · 07:45 PM',
        note: 'Awaiting KSEB inspection for the reported docket.',
        by: 'Logged by Landlord',
        current: true,
      ),
    ],
  );

  static const exhaust = MaintenanceRequest(
    id: '#MNT-2024-KKD-02',
    title: 'Kitchen Exhaust Fan Not Working',
    category: MaintenanceCategory.appliance,
    categoryLabel: 'Appliance',
    priority: MaintenancePriority.low,
    status: MaintenanceStatus.open,
    property: PropertyMockData.kakkanadResidency,
    locationLabel: 'Unit 1B (Priya Raghavan)',
    unitDetail: 'Unit 1B (Ground Floor · 2 BHK)',
    reported: 'Reported 22 Oct 2024',
    reportedLong: 'Reported 22 Oct, 09:20 AM',
    summary: 'Exhaust fan hums but does not spin. Likely capacitor issue.',
    summaryIcon: Icons.kitchen_outlined,
    footer: 'Tenant: Priya Raghavan',
    footerIcon: Icons.person_outline,
    description:
        'Kitchen exhaust fan hums but the blades do not spin. Tenant has '
        'switched it off at the board.',
    tenantName: 'Priya Raghavan',
    log: [
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '22 Oct · 09:20 AM',
        note: 'Awaiting electrician visit.',
        by: 'Logged by Landlord',
        current: true,
      ),
    ],
  );

  static const latch = MaintenanceRequest(
    id: '#MNT-2024-KKD-01',
    title: 'Balcony Sliding Door Latch Replacement',
    category: MaintenanceCategory.structural,
    categoryLabel: 'Structural / Hardware',
    priority: MaintenancePriority.low,
    status: MaintenanceStatus.completed,
    property: PropertyMockData.kakkanadResidency,
    locationLabel: 'Unit 2A (Vishnu Das)',
    unitDetail: 'Unit 2A (1st Floor · 2 BHK)',
    reported: 'Reported 15 Oct · Resolved 18 Oct',
    reportedLong: 'Reported 15 Oct, 06:00 PM',
    summary:
        'Brass sliding channel latch replaced with stainless steel lock. '
        'Checked with tenant Vishnu Das.',
    summaryIcon: Icons.task_alt,
    footer: 'Cost recorded: ₹1,450',
    footerIcon: Icons.receipt_long_outlined,
    description:
        'Balcony sliding door latch was loose and would not lock. Tenant '
        'requested a replacement.',
    tenantName: 'Vishnu Das',
    assignee: 'Suresh Babu',
    assigneeRole: 'Carpenter',
    completedOn: '18 Oct 2024',
    cost: '₹1,450',
    resolution:
        'Brass sliding channel latch replaced with a stainless steel lock.',
    log: [
      MaintenanceLogEntry(
        title: 'Marked Completed',
        time: '18 Oct · 04:30 PM',
        note: 'Latch replaced and lock tested with the tenant.',
        by: 'Logged by Landlord',
        current: true,
      ),
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '15 Oct · 06:00 PM',
        note: 'Latch loose; door cannot be locked.',
        by: 'Logged by Landlord',
      ),
    ],
  );

  static const fan = MaintenanceRequest(
    id: '#MNT-2024-ALV-02',
    title: 'Ceiling Fan Regulator Replacement',
    category: MaintenanceCategory.electrical,
    categoryLabel: 'Electrical',
    priority: MaintenancePriority.low,
    status: MaintenanceStatus.completed,
    property: PropertyMockData.aluvaVilla,
    locationLabel: 'Annex (Meera Pillai)',
    unitDetail: 'Annex (Ground Floor · 1 BHK)',
    reported: 'Reported 08 Oct · Resolved 09 Oct',
    reportedLong: 'Reported 08 Oct, 11:00 AM',
    summary: 'Bedroom fan regulator replaced with a new step regulator.',
    summaryIcon: Icons.task_alt,
    footer: 'Cost recorded: ₹650',
    footerIcon: Icons.receipt_long_outlined,
    description: 'Bedroom ceiling fan stuck at full speed.',
    tenantName: 'Meera Pillai',
    assignee: 'Varghese',
    assigneeRole: 'Electrician',
    completedOn: '09 Oct 2024',
    cost: '₹650',
    resolution: 'Step regulator replaced and fan speeds checked.',
    log: [
      MaintenanceLogEntry(
        title: 'Marked Completed',
        time: '09 Oct · 03:15 PM',
        note: 'Regulator replaced.',
        by: 'Logged by Landlord',
        current: true,
      ),
      MaintenanceLogEntry(
        title: 'Request Logged as Open',
        time: '08 Oct · 11:00 AM',
        note: 'Fan stuck at full speed.',
        by: 'Logged by Landlord',
      ),
    ],
  );

  /// Newest first; active requests before completed ones.
  static const requests = [motor, seepage, voltage, exhaust, latch, fan];
}
