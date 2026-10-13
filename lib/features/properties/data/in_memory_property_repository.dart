import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/features/properties/data/property_mock_data.dart'
    as mock;
import 'package:resido/features/properties/domain/property.dart';
import 'package:resido/features/properties/domain/property_repository.dart';

/// In-memory properties and units. Each instance has its own state;
/// results keep insertion order.
class InMemoryPropertyRepository implements PropertyRepository {
  InMemoryPropertyRepository({
    Iterable<Property> properties = const [],
    Iterable<Unit> units = const [],
  }) {
    for (final p in properties) {
      _properties[p.id] = p;
    }
    for (final u in units) {
      _units[u.id] = u;
    }
  }

  /// Seeded from [mock.PropertyMockData]: 4 properties, 12 units.
  factory InMemoryPropertyRepository.seeded() => InMemoryPropertyRepository(
    properties: seedProperties(),
    units: seedUnits(),
  );

  /// Stable unit ID: `<propertyId>-<unit number>`, e.g. `palm-grove-101`.
  static String unitIdFor(String propertyId, String unitNumber) =>
      '$propertyId-${unitNumber.toLowerCase()}';

  static List<Property> seedProperties() => [
    for (final p in mock.PropertyMockData.properties)
      Property(
        id: p.id,
        name: p.name,
        type: switch (p.category) {
          mock.PropertyCategory.apartments => PropertyType.apartmentBuilding,
          mock.PropertyCategory.villas => PropertyType.independentHouse,
          mock.PropertyCategory.commercial => PropertyType.commercial,
        },
        address: PropertyAddress(
          street: p.street,
          locality: p.locality,
          city: p.city,
          district: p.district,
          // Every seeded property is in Kerala.
          state: 'Kerala',
          pinCode: p.pinCode,
        ),
        description: p.description,
        amenities: [for (final (_, label) in p.amenities) label],
      ),
  ];

  static List<Unit> seedUnits() => [
    for (final p in mock.PropertyMockData.properties)
      for (final u in p.units)
        Unit(
          id: unitIdFor(p.id, u.number),
          propertyId: p.id,
          label: u.number,
          defaultRentPaise: Money.fromRupees(u.rent),
          floor: u.floor,
          layout: u.layout,
          areaSqFt: u.areaSqFt,
          readiness: u.condition == mock.UnitCondition.refreshing
              ? UnitReadiness.refreshing
              : UnitReadiness.ready,
          notes: u.notes,
        ),
  ];

  final _properties = <String, Property>{};
  final _units = <String, Unit>{};

  @override
  Future<List<Property>> getProperties() async =>
      List.unmodifiable(_properties.values);

  @override
  Future<Property?> getProperty(String id) async => _properties[id];

  @override
  Future<List<Unit>> getUnits({String? propertyId}) async => List.unmodifiable(
    _units.values.where(
      (u) => propertyId == null || u.propertyId == propertyId,
    ),
  );

  @override
  Future<Unit?> getUnit(String id) async => _units[id];

  @override
  Future<void> saveProperty(Property property) async =>
      _properties[property.id] = property;

  @override
  Future<void> saveUnit(Unit unit) async {
    if (!_properties.containsKey(unit.propertyId)) {
      throw RecordNotFoundException('Property', unit.propertyId);
    }
    final existing = _units[unit.id];
    if (existing != null && existing.propertyId != unit.propertyId) {
      throw const DomainException(
        'unit-property-immutable',
        'A unit cannot be moved to another property',
      );
    }
    _units[unit.id] = unit;
  }
}
