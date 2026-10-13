import 'package:resido/features/properties/domain/property.dart';

/// Properties and their units.
abstract interface class PropertyRepository {
  Future<List<Property>> getProperties();

  /// Null when no property has [id].
  Future<Property?> getProperty(String id);

  /// All units, or only those of [propertyId].
  Future<List<Unit>> getUnits({String? propertyId});

  /// Null when no unit has [id].
  Future<Unit?> getUnit(String id);

  /// Creates or replaces a property.
  Future<void> saveProperty(Property property);

  /// Creates or replaces a unit. Throws RecordNotFoundException when its
  /// property does not exist.
  Future<void> saveUnit(Unit unit);
}
