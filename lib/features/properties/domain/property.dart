import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/record_status.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

/// The three property types offered by the Add Property form.
enum PropertyType { apartmentBuilding, independentHouse, commercial }

/// A postal address in India. The Kerala PIN rule applies only when
/// [state] is Kerala.
class PropertyAddress {
  PropertyAddress({
    required this.street,
    required this.locality,
    required this.city,
    required this.district,
    required this.state,
    required this.pinCode,
  }) {
    for (final (value, field) in [
      (street, 'Street'),
      (city, 'City'),
      (state, 'State'),
    ]) {
      final error = Validators.requiredText(value, field);
      if (error != null) throw ArgumentError.value(value, field, error);
    }
    final pinError = Validators.pinCode(pinCode, kerala: isKerala);
    if (pinError != null) {
      throw ArgumentError.value(pinCode, 'pinCode', pinError);
    }
  }

  final String street;
  final String locality;
  final String city;
  final String district;
  final String state;
  final String pinCode;

  bool get isKerala => Validators.isKeralaState(state);

  Map<String, Object?> toMap() => {
    'street': street,
    'locality': locality,
    'city': city,
    'district': district,
    'state': state,
    'pinCode': pinCode,
  };

  factory PropertyAddress.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'PropertyAddress');
    return PropertyAddress(
      street: r.string('street'),
      locality: r.string('locality'),
      city: r.string('city'),
      district: r.string('district'),
      state: r.string('state'),
      pinCode: r.string('pinCode'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PropertyAddress &&
      other.street == street &&
      other.locality == locality &&
      other.city == city &&
      other.district == district &&
      other.state == state &&
      other.pinCode == pinCode;

  @override
  int get hashCode =>
      Object.hash(street, locality, city, district, state, pinCode);
}

class Property {
  Property({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.description = '',
    List<String> amenities = const [],
    this.status = RecordStatus.active,
  }) : amenities = List.unmodifiable(amenities) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    final nameError = Validators.requiredText(
      name,
      'Property name',
      max: Validators.nameMax,
    );
    if (nameError != null) throw ArgumentError.value(name, 'name', nameError);
  }

  final String id;
  final String name;
  final PropertyType type;
  final PropertyAddress address;
  final String description;
  final List<String> amenities;
  final RecordStatus status;

  Property copyWith({
    String? name,
    PropertyType? type,
    PropertyAddress? address,
    String? description,
    List<String>? amenities,
    RecordStatus? status,
  }) => Property(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    address: address ?? this.address,
    description: description ?? this.description,
    amenities: amenities ?? this.amenities,
    status: status ?? this.status,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'type': type.name,
    'address': address.toMap(),
    'description': description,
    'amenities': amenities,
    'status': status.name,
  };

  factory Property.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'Property');
    return Property(
      id: r.string('id'),
      name: r.string('name'),
      type: r.enumValue('type', PropertyType.values),
      address: PropertyAddress.fromMap(r.child('address')),
      description: r.string('description'),
      amenities: r.strings('amenities'),
      status: r.enumValue('status', RecordStatus.values),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Property &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.address == address &&
      other.description == description &&
      listEquals(other.amenities, amenities) &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    address,
    description,
    Object.hashAll(amenities),
    status,
  );
}

/// Readiness of a vacant unit (Batch 03: ready to move / touch-ups).
/// Occupancy itself is derived from tenancies, not stored on the unit.
enum UnitReadiness { ready, refreshing }

class Unit {
  Unit({
    required this.id,
    required this.propertyId,
    required this.label,
    required this.defaultRentPaise,
    this.floor = '',
    this.layout = '',
    this.areaSqFt,
    this.readiness = UnitReadiness.ready,
    this.notes = '',
    this.status = RecordStatus.active,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    final idError = Validators.requiredId(propertyId, 'Property');
    if (idError != null) {
      throw ArgumentError.value(propertyId, 'propertyId', idError);
    }
    final labelError = Validators.requiredText(label, 'Unit label', max: 30);
    if (labelError != null) {
      throw ArgumentError.value(label, 'label', labelError);
    }
    Money.checkAmount(defaultRentPaise, name: 'defaultRentPaise');
    if (areaSqFt != null && areaSqFt! <= 0) {
      throw ArgumentError.value(areaSqFt, 'areaSqFt', 'must be positive');
    }
  }

  final String id;
  final String propertyId;

  /// "101", "Main", "1A".
  final String label;
  final int defaultRentPaise;
  final String floor;
  final String layout;
  final int? areaSqFt;
  final UnitReadiness readiness;
  final String notes;
  final RecordStatus status;

  Unit copyWith({
    String? label,
    int? defaultRentPaise,
    String? floor,
    String? layout,
    int? areaSqFt,
    UnitReadiness? readiness,
    String? notes,
    RecordStatus? status,
  }) => Unit(
    id: id,
    propertyId: propertyId,
    label: label ?? this.label,
    defaultRentPaise: defaultRentPaise ?? this.defaultRentPaise,
    floor: floor ?? this.floor,
    layout: layout ?? this.layout,
    areaSqFt: areaSqFt ?? this.areaSqFt,
    readiness: readiness ?? this.readiness,
    notes: notes ?? this.notes,
    status: status ?? this.status,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'propertyId': propertyId,
    'label': label,
    'defaultRentPaise': defaultRentPaise,
    'floor': floor,
    'layout': layout,
    'areaSqFt': areaSqFt,
    'readiness': readiness.name,
    'notes': notes,
    'status': status.name,
  };

  factory Unit.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'Unit');
    return Unit(
      id: r.string('id'),
      propertyId: r.string('propertyId'),
      label: r.string('label'),
      defaultRentPaise: r.integer('defaultRentPaise'),
      floor: r.string('floor'),
      layout: r.string('layout'),
      areaSqFt: r.optInteger('areaSqFt'),
      readiness: r.enumValue('readiness', UnitReadiness.values),
      notes: r.string('notes'),
      status: r.enumValue('status', RecordStatus.values),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Unit &&
      other.id == id &&
      other.propertyId == propertyId &&
      other.label == label &&
      other.defaultRentPaise == defaultRentPaise &&
      other.floor == floor &&
      other.layout == layout &&
      other.areaSqFt == areaSqFt &&
      other.readiness == readiness &&
      other.notes == notes &&
      other.status == status;

  @override
  int get hashCode => Object.hash(
    id,
    propertyId,
    label,
    defaultRentPaise,
    floor,
    layout,
    areaSqFt,
    readiness,
    notes,
    status,
  );
}
