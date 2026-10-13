/// Static sample properties and units for the Property Management UI
/// (Stitch screens 10–15). Values are fixed mock data; nothing is
/// calculated or persisted. Totals match the designed portfolio:
/// 4 properties, 12 units, 10 occupied, 2 vacant.
library;

import 'package:flutter/material.dart';

enum PropertyCategory { apartments, villas, commercial }

enum UnitStatus { occupied, vacant }

/// Rent / readiness sub-state shown on unit cards.
enum UnitCondition {
  /// Occupied, current month settled.
  settled,

  /// Occupied, payment overdue.
  overdue,

  /// Vacant and ready for a tenant.
  ready,

  /// Vacant, under painting / touch-ups.
  refreshing,
}

class MockUnit {
  const MockUnit({
    required this.number,
    required this.floor,
    required this.shortFloor,
    required this.layout,
    required this.areaSqFt,
    required this.rent,
    required this.status,
    required this.condition,
    this.tenant,
    this.nextDue,
    this.overdueDays,
    this.pendingAmount,
    this.inspectedOn,
    this.maintenanceProgress,
    this.notes = '',
  });

  /// Display identifier, e.g. "101" or "G1".
  final String number;
  final String floor;
  final String shortFloor;
  final String layout;
  final int areaSqFt;
  final int rent;
  final UnitStatus status;
  final UnitCondition condition;
  final String? tenant;
  final String? nextDue;
  final int? overdueDays;
  final int? pendingAmount;
  final String? inspectedOn;
  final int? maintenanceProgress;
  final String notes;

  String get name => 'Unit $number';

  String get tenantInitials {
    final parts = (tenant ?? '').split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

/// A label/value pair in a property card's metric strip.
class CardMetric {
  const CardMetric(this.label, this.value, {this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;
}

enum CardNoteTone { attention, positive, neutral }

class MockProperty {
  const MockProperty({
    required this.id,
    required this.registryId,
    required this.name,
    required this.typeLabel,
    required this.formType,
    required this.category,
    required this.regionLabel,
    required this.street,
    required this.locality,
    required this.shortLocality,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.pinCode,
    required this.cardMetrics,
    required this.cardNote,
    required this.cardNoteIcon,
    required this.cardNoteTone,
    required this.monthlyYield,
    required this.received,
    required this.pending,
    required this.description,
    required this.amenities,
    required this.units,
    this.cardImage,
    this.heroImage,
    this.icon = Icons.apartment,
    this.verifiedTitle = true,
    this.cardImageHeight = 144,
  });

  final String id;
  final String registryId;
  final String name;

  /// Label used on cards and details ("Apartment Complex").
  final String typeLabel;

  /// Value preselected in the property type dropdowns.
  final String formType;
  final PropertyCategory category;
  final String regionLabel;
  final String street;
  final String locality;
  final String shortLocality;

  /// One-line address as shown on cards and details.
  final String addressLine;
  final String city;
  final String district;
  final String pinCode;
  final List<CardMetric> cardMetrics;
  final String cardNote;
  final IconData cardNoteIcon;
  final CardNoteTone cardNoteTone;
  final int monthlyYield;
  final int received;
  final int pending;
  final String description;
  final List<(IconData, String)> amenities;
  final List<MockUnit> units;
  final String? cardImage;
  final String? heroImage;
  final IconData icon;
  final bool verifiedTitle;

  /// Photo height on the list card (the featured card is taller).
  final double cardImageHeight;

  int get occupiedCount =>
      units.where((u) => u.status == UnitStatus.occupied).length;

  int get vacantCount => units.length - occupiedCount;

  bool get hasVacancies => vacantCount > 0;
}

abstract final class PropertyMockData {
  static const palmGrove = MockProperty(
    id: 'palm-grove',
    registryId: 'KL-EKM-2024-04',
    name: 'Palm Grove Enclave',
    typeLabel: 'Apartment Complex',
    formType: 'Apartment Building',
    category: PropertyCategory.apartments,
    regionLabel: 'Ernakulam District',
    street: 'Plot 18, 5th Cross Road',
    locality: 'Panampilly Nagar Main Park',
    shortLocality: 'Panampilly Nagar',
    addressLine: 'Panampilly Nagar, Ernakulam, Kochi - 682036',
    city: 'Kochi',
    district: 'Ernakulam',
    pinCode: '682036',
    cardImage: 'assets/images/property_palm_grove_card.jpg',
    heroImage: 'assets/images/property_palm_grove_hero.jpg',
    cardImageHeight: 176,
    cardMetrics: [
      CardMetric('Capacity', '4 Units Total'),
      CardMetric('Tenancy', '2 Occupied'),
      CardMetric('Yield/Mo', '₹88,000', emphasis: true),
    ],
    cardNote: 'Needs tenant outreach',
    cardNoteIcon: Icons.priority_high,
    cardNoteTone: CardNoteTone.attention,
    monthlyYield: 88000,
    received: 48000,
    pending: 40000,
    description:
        'Modern residential complex located in Panampilly Nagar. 4 spacious '
        '3BHK units with separate KSEB sub-meters, dedicated rainwater '
        'harvesting, and lush private boundary landscaping.',
    amenities: [
      (Icons.water_drop_outlined, 'KWA + Borewell'),
      (Icons.directions_car_outlined, '3 Covered Parks'),
      (Icons.solar_power_outlined, 'Solar Inverter'),
      (Icons.security, 'CCTV Monitored'),
    ],
    units: [
      MockUnit(
        number: '101',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: '3 BHK',
        areaSqFt: 1480,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Suresh Kumar',
        nextDue: '1st Nov',
      ),
      MockUnit(
        number: '102',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: '3 BHK',
        areaSqFt: 1480,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.overdue,
        tenant: 'Ananya Nair',
        overdueDays: 4,
        pendingAmount: 11000,
      ),
      MockUnit(
        number: '201',
        floor: '1st Floor',
        shortFloor: '1st Floor',
        layout: '3 BHK',
        areaSqFt: 1410,
        rent: 20000,
        status: UnitStatus.vacant,
        condition: UnitCondition.ready,
        inspectedOn: '15 Oct',
        notes:
            'East facing balcony facing coconut grove, semi-furnished '
            'modular kitchen, KSEB consumer #4829103, includes covered '
            'parking bay #12.',
      ),
      MockUnit(
        number: '202',
        floor: '1st Floor',
        shortFloor: '1st Floor',
        layout: '3 BHK',
        areaSqFt: 1410,
        rent: 20000,
        status: UnitStatus.vacant,
        condition: UnitCondition.refreshing,
        maintenanceProgress: 80,
      ),
    ],
  );

  static const aluvaVilla = MockProperty(
    id: 'aluva-villa',
    registryId: 'KL-EKM-2023-11',
    name: 'Aluva Riverview Villa',
    typeLabel: 'Independent Villa',
    formType: 'Independent House / Villa',
    category: PropertyCategory.villas,
    regionLabel: 'Periyar Waterfront',
    street: 'Riverview House, Bank Road',
    locality: 'Near Bank Junction',
    shortLocality: 'Bank Junction, Aluva',
    addressLine: 'Bank Junction, Aluva, Ernakulam - 683101',
    city: 'Aluva',
    district: 'Ernakulam',
    pinCode: '683101',
    cardImage: 'assets/images/property_aluva_villa.jpg',
    heroImage: 'assets/images/property_aluva_villa.jpg',
    cardMetrics: [
      CardMetric('Structure', 'Main + Annex'),
      CardMetric('Tenants', '2 Occupied'),
      CardMetric('Yield/Mo', '₹42,000', emphasis: true),
    ],
    cardNote: 'Lease active until Dec 2025',
    cardNoteIcon: Icons.verified_outlined,
    cardNoteTone: CardNoteTone.positive,
    monthlyYield: 42000,
    received: 42000,
    pending: 0,
    description:
        'Kerala-style riverfront villa on the Periyar with a separate '
        'garden annex. Tiled roof, laterite walls, private jetty and '
        'mature coconut grove.',
    amenities: [
      (Icons.water_drop_outlined, 'Private Well'),
      (Icons.directions_car_outlined, '2 Car Porch'),
      (Icons.yard_outlined, 'Riverside Garden'),
    ],
    units: [
      MockUnit(
        number: 'Main',
        floor: 'Ground + 1st Floor',
        shortFloor: 'G + 1',
        layout: '4 BHK Villa',
        areaSqFt: 2600,
        rent: 30000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Dr. Thomas K.',
        nextDue: '5th Nov',
      ),
      MockUnit(
        number: 'Annex',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: '1 BHK Annex',
        areaSqFt: 650,
        rent: 12000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Meera Pillai',
        nextDue: '1st Nov',
      ),
    ],
  );

  static const kakkanadResidency = MockProperty(
    id: 'kakkanad-residency',
    registryId: 'KL-EKM-2022-07',
    name: 'Kakkanad Tech Residency',
    typeLabel: 'Multi-Unit Flats',
    formType: 'Apartment Building',
    category: PropertyCategory.apartments,
    regionLabel: 'Infopark Corridor',
    street: 'Tech Residency, Infopark Road',
    locality: 'Near Infopark Phase 1',
    shortLocality: 'Infopark Road, Kakkanad',
    addressLine: 'Infopark Road, Kakkanad, Kochi - 682030',
    city: 'Kochi',
    district: 'Ernakulam',
    pinCode: '682030',
    icon: Icons.apartment,
    cardMetrics: [
      CardMetric('Units', '4 Units'),
      CardMetric('IT Tenants', '4 Active'),
      CardMetric('Yield/Mo', '₹96,000', emphasis: true),
    ],
    cardNote: 'All 4 rentals paid for month',
    cardNoteIcon: Icons.check_circle_outline,
    cardNoteTone: CardNoteTone.positive,
    monthlyYield: 96000,
    received: 96000,
    pending: 0,
    description:
        'Four 2BHK flats close to Infopark, let to IT professionals. Lift, '
        'power backup and covered two-wheeler parking.',
    amenities: [
      (Icons.elevator_outlined, 'Lift'),
      (Icons.bolt_outlined, 'Power Backup'),
      (Icons.two_wheeler_outlined, 'Bike Parking'),
    ],
    units: [
      MockUnit(
        number: '1A',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: '2 BHK',
        areaSqFt: 1050,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Arjun Menon',
        nextDue: '1st Nov',
      ),
      MockUnit(
        number: '1B',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: '2 BHK',
        areaSqFt: 1050,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Priya Raghavan',
        nextDue: '1st Nov',
      ),
      MockUnit(
        number: '2A',
        floor: '1st Floor',
        shortFloor: '1st Floor',
        layout: '2 BHK',
        areaSqFt: 1050,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Vishnu Das',
        nextDue: '1st Nov',
      ),
      MockUnit(
        number: '2B',
        floor: '1st Floor',
        shortFloor: '1st Floor',
        layout: '2 BHK',
        areaSqFt: 1050,
        rent: 24000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Sneha Joseph',
        nextDue: '1st Nov',
      ),
    ],
  );

  static const malabarHeights = MockProperty(
    id: 'malabar-heights',
    registryId: 'KL-KKD-2021-02',
    name: 'Malabar Heights Commercial',
    typeLabel: 'Commercial Building',
    formType: 'Commercial Property',
    category: PropertyCategory.commercial,
    regionLabel: 'Kozhikode City',
    street: 'Malabar Heights, Mavoor Road',
    locality: 'Opposite KSRTC Bus Stand',
    shortLocality: 'Mavoor Road',
    addressLine: 'Mavoor Road, Kozhikode - 673004',
    city: 'Kozhikode',
    district: 'Kozhikode',
    pinCode: '673004',
    icon: Icons.storefront_outlined,
    cardMetrics: [
      CardMetric('Floors', 'G + 1 Commercial'),
      CardMetric('Tenants', '2 Businesses'),
      CardMetric('Yield/Mo', '₹65,000', emphasis: true),
    ],
    cardNote: 'GST Invoiced & Active',
    cardNoteIcon: Icons.receipt_long_outlined,
    cardNoteTone: CardNoteTone.neutral,
    monthlyYield: 65000,
    received: 65000,
    pending: 0,
    description:
        'Two-storey commercial block on Mavoor Road with a ground-floor '
        'showroom and first-floor office space.',
    amenities: [
      (Icons.local_parking_outlined, 'Front Parking'),
      (Icons.security, 'CCTV Monitored'),
    ],
    units: [
      MockUnit(
        number: 'G1',
        floor: 'Ground Floor',
        shortFloor: 'Ground Flr',
        layout: 'Showroom',
        areaSqFt: 900,
        rent: 35000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Calicut Textiles',
        nextDue: '1st Nov',
      ),
      MockUnit(
        number: '101',
        floor: '1st Floor',
        shortFloor: '1st Floor',
        layout: 'Office',
        areaSqFt: 850,
        rent: 30000,
        status: UnitStatus.occupied,
        condition: UnitCondition.settled,
        tenant: 'Malabar Tech Solutions',
        nextDue: '1st Nov',
      ),
    ],
  );

  static const properties = [
    palmGrove,
    aluvaVilla,
    kakkanadResidency,
    malabarHeights,
  ];

  // Portfolio Health strip (Stitch "10. Property List").
  static const occupancyPercent = 83;
}
