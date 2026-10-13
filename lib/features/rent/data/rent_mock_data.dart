import 'package:flutter/material.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';

// Static rent data for the UI. Values are written out as shown on screen;
// nothing here is calculated, saved or sent anywhere.
//
// Cycle: October 2024, as of Thu 24 Oct 2024 (the Dashboard date). Records
// stay inside the Batch 03/04 tenancies, so Unit 101 is not scheduled — its
// mock agreement ended 31 Aug 2024.

enum RentStatus {
  paid('Paid'),
  partiallyPaid('Partially Paid'),
  overdue('Overdue'),
  upcoming('Upcoming');

  const RentStatus(this.label);

  final String label;
}

enum PaymentMethod {
  upi('UPI', 'GPay / PhonePe / Paytm', Icons.qr_code_scanner),
  bankTransfer('Bank Transfer', 'NEFT / RTGS / IMPS', Icons.account_balance),
  cash('Cash', 'In-person receipt', Icons.payments_outlined),
  cheque('Cheque / Other', 'Demand draft or DD', Icons.edit_note);

  const PaymentMethod(this.label, this.detail, this.icon);

  final String label;
  final String detail;
  final IconData icon;
}

class RentPayment {
  const RentPayment({
    required this.recordId,
    required this.receiptNo,
    required this.amount,
    required this.date,
    required this.longDate,
    required this.time,
    required this.method,
    required this.channel,
    required this.reference,
    this.partial = false,
    this.balanceAfter = '₹0.00',
  });

  final String recordId;
  final String receiptNo;

  /// Display amount, e.g. "₹13,000.00".
  final String amount;
  final String date;
  final String longDate;
  final String time;
  final PaymentMethod method;

  /// Channel as written on the receipt ("Google Pay UPI").
  final String channel;
  final String reference;
  final bool partial;

  /// Balance left for the period after this payment.
  final String balanceAfter;

  RentRecord get record => RentMockData.recordById(recordId);
}

class RentRecord {
  const RentRecord({
    required this.id,
    required this.tenantName,
    required this.initials,
    required this.property,
    required this.unitLabel,
    required this.period,
    required this.status,
    required this.rent,
    required this.paid,
    required this.remaining,
    required this.dueDate,
    required this.dueBadge,
    this.paidPercent = '',
    this.paidFraction = 0,
    this.dueNote = '',
    this.tenant,
    this.payments = const [],
  });

  final String id;
  final String tenantName;
  final String initials;
  final MockProperty property;

  /// "Unit 102", "Annex".
  final String unitLabel;
  final String period;
  final RentStatus status;

  // Display amounts, e.g. "₹24,000".
  final String rent;
  final String paid;
  final String remaining;
  final String paidPercent;

  /// Width of the paid part of progress bars (0–1), fixed per record.
  final double paidFraction;
  final String dueDate;
  final String dueBadge;
  final String dueNote;

  /// Linked Batch 04 tenant, when one exists (opens Tenancy Details).
  final MockTenant? tenant;
  final List<RentPayment> payments;

  String get location => '${property.name} · $unitLabel';
}

abstract final class RentMockData {
  static const cycle = 'October 2024';
  static const cycleShort = 'Oct 2024';
  static const asOfDate = '24 Oct 2024';
  static const landlordName = 'Harikrishnan Menon';

  // Overview totals for the October cycle (9 scheduled units).
  static const expected = '₹2,27,000';
  static const expectedNote = '9 units scheduled';
  static const collected = '₹2,08,000';
  static const collectedNote = '9 payments received';
  static const collectedPercent = '91.6%';
  static const collectedFraction = 0.916;
  static const outstanding = '₹19,000';
  static const outstandingNote = '2 pending tenancies';
  static const collectionAchieved = '92% Achieved';
  static const unitsCleared = '7 of 9 units cleared';

  static final ananya = RentRecord(
    id: 'pg-102-oct',
    tenantName: 'Ananya Nair',
    initials: 'AN',
    property: PropertyMockData.palmGrove,
    unitLabel: 'Unit 102',
    period: cycle,
    status: RentStatus.overdue,
    rent: '₹24,000',
    paid: '₹13,000',
    remaining: '₹11,000',
    paidPercent: '54.2%',
    paidFraction: 0.542,
    dueDate: '01 Oct 2024',
    dueBadge: '4 Days Overdue',
    dueNote: 'Grace period ended 20 Oct 2024.',
    tenant: TenantMockData.ananya,
    payments: const [
      RentPayment(
        recordId: 'pg-102-oct',
        receiptNo: '#REC-2024-102-01',
        amount: '₹13,000.00',
        date: '18 Oct 2024',
        longDate: '18 October 2024',
        time: '04:15 PM IST',
        method: PaymentMethod.upi,
        channel: 'Google Pay UPI',
        reference: 'UPI-9840129381',
        partial: true,
        balanceAfter: '₹11,000.00',
      ),
    ],
  );

  static const meera = RentRecord(
    id: 'alv-annex-oct',
    tenantName: 'Meera Pillai',
    initials: 'MP',
    property: PropertyMockData.aluvaVilla,
    unitLabel: 'Annex',
    period: cycle,
    status: RentStatus.partiallyPaid,
    rent: '₹12,000',
    paid: '₹4,000',
    remaining: '₹8,000',
    paidPercent: '33.3%',
    paidFraction: 0.333,
    dueDate: '28 Oct 2024',
    dueBadge: 'Grace Period Active',
    dueNote: 'Balance due before 28 Oct 2024.',
    payments: [
      RentPayment(
        recordId: 'alv-annex-oct',
        receiptNo: '#REC-2024-ALV-03',
        amount: '₹4,000.00',
        date: '10 Oct 2024',
        longDate: '10 October 2024',
        time: '11:20 AM IST',
        method: PaymentMethod.cash,
        channel: 'Cash (Handover)',
        reference: 'Cash · No reference',
        partial: true,
        balanceAfter: '₹8,000.00',
      ),
    ],
  );

  static const sneha = RentRecord(
    id: 'kk-2b-nov',
    tenantName: 'Sneha Joseph',
    initials: 'SJ',
    property: PropertyMockData.kakkanadResidency,
    unitLabel: 'Unit 2B',
    period: 'November 2024',
    status: RentStatus.upcoming,
    rent: '₹24,000',
    paid: '₹0',
    remaining: '₹24,000',
    paidPercent: '0%',
    dueDate: '01 Nov 2024',
    dueBadge: 'In 8 Days',
    dueNote: 'Next cycle rent.',
  );

  static const thomas = RentRecord(
    id: 'alv-main-oct',
    tenantName: 'Dr. Thomas K.',
    initials: 'TK',
    property: PropertyMockData.aluvaVilla,
    unitLabel: 'Main Villa',
    period: cycle,
    status: RentStatus.paid,
    rent: '₹30,000',
    paid: '₹30,000',
    remaining: '₹0',
    paidPercent: '100%',
    paidFraction: 1,
    dueDate: '05 Oct 2024',
    dueBadge: 'Settled',
    payments: [
      RentPayment(
        recordId: 'alv-main-oct',
        receiptNo: '#REC-2024-ALV-02',
        amount: '₹30,000.00',
        date: '04 Oct 2024',
        longDate: '04 October 2024',
        time: '10:05 AM IST',
        method: PaymentMethod.bankTransfer,
        channel: 'NEFT / Direct Bank Transfer',
        reference: 'ICIC-NEFT-552019837',
      ),
    ],
  );

  static RentRecord _paidKakkanad(
    String unit,
    String name,
    String initials,
    String date,
    String longDate,
    PaymentMethod method,
    String channel,
    String reference,
  ) => RentRecord(
    id: 'kk-${unit.toLowerCase()}-oct',
    tenantName: name,
    initials: initials,
    property: PropertyMockData.kakkanadResidency,
    unitLabel: 'Unit $unit',
    period: cycle,
    status: RentStatus.paid,
    rent: '₹24,000',
    paid: '₹24,000',
    remaining: '₹0',
    paidPercent: '100%',
    paidFraction: 1,
    dueDate: '01 Oct 2024',
    dueBadge: 'Settled',
    payments: [
      RentPayment(
        recordId: 'kk-${unit.toLowerCase()}-oct',
        receiptNo: '#REC-2024-KKD-$unit',
        amount: '₹24,000.00',
        date: date,
        longDate: longDate,
        time: '09:30 AM IST',
        method: method,
        channel: channel,
        reference: reference,
      ),
    ],
  );

  static final arjun = _paidKakkanad(
    '1A',
    'Arjun Menon',
    'AM',
    '02 Oct 2024',
    '02 October 2024',
    PaymentMethod.upi,
    'PhonePe UPI',
    'UPI-4410928375',
  );
  static final priya = _paidKakkanad(
    '1B',
    'Priya Raghavan',
    'PR',
    '03 Oct 2024',
    '03 October 2024',
    PaymentMethod.upi,
    'Google Pay UPI',
    'UPI-4411302846',
  );
  static final vishnu = _paidKakkanad(
    '2A',
    'Vishnu Das',
    'VD',
    '05 Oct 2024',
    '05 October 2024',
    PaymentMethod.bankTransfer,
    'IMPS / Direct Bank Transfer',
    'SBIN-IMPS-830214765',
  );
  static final snehaOct = _paidKakkanad(
    '2B',
    'Sneha Joseph',
    'SJ',
    '01 Oct 2024',
    '01 October 2024',
    PaymentMethod.upi,
    'Paytm UPI',
    'UPI-4409817263',
  );

  static const calicutTextiles = RentRecord(
    id: 'mh-g1-oct',
    tenantName: 'Calicut Textiles',
    initials: 'CT',
    property: PropertyMockData.malabarHeights,
    unitLabel: 'Unit G1',
    period: cycle,
    status: RentStatus.paid,
    rent: '₹35,000',
    paid: '₹35,000',
    remaining: '₹0',
    paidPercent: '100%',
    paidFraction: 1,
    dueDate: '01 Oct 2024',
    dueBadge: 'Settled',
    payments: [
      RentPayment(
        recordId: 'mh-g1-oct',
        receiptNo: '#REC-2024-MHC-G1',
        amount: '₹35,000.00',
        date: '05 Oct 2024',
        longDate: '05 October 2024',
        time: '02:40 PM IST',
        method: PaymentMethod.bankTransfer,
        channel: 'RTGS / Direct Bank Transfer',
        reference: 'FDRL-RTGS-771034952',
      ),
    ],
  );

  static const malabarTech = RentRecord(
    id: 'mh-101-oct',
    tenantName: 'Malabar Tech Solutions',
    initials: 'MT',
    property: PropertyMockData.malabarHeights,
    unitLabel: 'Unit 101',
    period: cycle,
    status: RentStatus.paid,
    rent: '₹30,000',
    paid: '₹30,000',
    remaining: '₹0',
    paidPercent: '100%',
    paidFraction: 1,
    dueDate: '01 Oct 2024',
    dueBadge: 'Settled',
    payments: [
      RentPayment(
        recordId: 'mh-101-oct',
        receiptNo: '#REC-2024-MHC-101',
        amount: '₹30,000.00',
        date: '03 Oct 2024',
        longDate: '03 October 2024',
        time: '12:10 PM IST',
        method: PaymentMethod.bankTransfer,
        channel: 'NEFT / Direct Bank Transfer',
        reference: 'SIBL-NEFT-604129387',
      ),
    ],
  );

  /// Rent Due list: open obligations, most urgent first.
  static final dues = [ananya, meera, sneha];

  static final records = [
    ananya,
    meera,
    sneha,
    thomas,
    arjun,
    priya,
    vishnu,
    snehaOct,
    calicutTextiles,
    malabarTech,
  ];

  /// Payment History for October 2024, newest first.
  static final payments = [
    ananya.payments.first,
    meera.payments.first,
    vishnu.payments.first,
    calicutTextiles.payments.first,
    thomas.payments.first,
    priya.payments.first,
    malabarTech.payments.first,
    arjun.payments.first,
    snehaOct.payments.first,
  ];

  static RentRecord recordById(String id) =>
      records.firstWhere((r) => r.id == id, orElse: () => ananya);

  /// Static example shown after "Save Payment" (nothing is saved).
  static const recordPreview = RentPayment(
    recordId: 'pg-102-oct',
    receiptNo: '#REC-PREVIEW',
    amount: '₹11,000.00',
    date: '24 Oct 2024',
    longDate: '24 October 2024',
    time: '—',
    method: PaymentMethod.upi,
    channel: 'Google Pay UPI',
    reference: 'Not provided',
  );

  /// Static example shown after "Save Partial Payment".
  static const partialPreview = RentPayment(
    recordId: 'alv-annex-oct',
    receiptNo: '#REC-PREVIEW',
    amount: '₹3,000.00',
    date: '24 Oct 2024',
    longDate: '24 October 2024',
    time: '—',
    method: PaymentMethod.upi,
    channel: 'UPI Instant',
    reference: 'Not provided',
    partial: true,
    balanceAfter: '₹5,000.00',
  );
}
