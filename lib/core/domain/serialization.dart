import 'package:resido/core/domain/calendar_date.dart';

/// Typed reads from serialized maps (`toMap` output). Missing or mistyped
/// fields throw a [FormatException] naming the field, so bad data fails
/// loudly at the boundary instead of deep inside business logic.
///
/// Maps hold only JSON-like values: String, int, bool, null, List, Map.
/// Dates are `YYYY-MM-DD` strings, periods `YYYY-MM`, enums their `name`,
/// and money integer paise. No Firebase types are used.
class MapReader {
  const MapReader(this.map, this.type);

  final Map<String, Object?> map;
  final String type;

  T _get<T>(String key) {
    final value = map[key];
    if (value is T) return value;
    throw FormatException('$type.$key: expected $T, got ${value.runtimeType}');
  }

  String string(String key) => _get<String>(key);
  String? optString(String key) => _get<String?>(key);
  int integer(String key) => _get<int>(key);
  int? optInteger(String key) => _get<int?>(key);
  bool boolean(String key) => _get<bool>(key);

  CalendarDate date(String key) => CalendarDate.parse(string(key));
  CalendarDate? optDate(String key) {
    final s = optString(key);
    return s == null ? null : CalendarDate.parse(s);
  }

  DateTime instant(String key) {
    final s = string(key);
    final parsed = DateTime.tryParse(s);
    if (parsed == null || !parsed.isUtc) {
      throw FormatException('$type.$key: expected a UTC ISO-8601 instant', s);
    }
    return parsed;
  }

  E enumValue<E extends Enum>(String key, List<E> values) {
    final name = string(key);
    for (final v in values) {
      if (v.name == name) return v;
    }
    throw FormatException('$type.$key: unknown value', name);
  }

  Map<String, Object?> child(String key) {
    final value = map[key];
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    throw FormatException('$type.$key: expected a map');
  }

  List<Map<String, Object?>> children(String key) {
    final value = map[key];
    if (value is! List) throw FormatException('$type.$key: expected a list');
    return [
      for (final item in value)
        if (item is Map)
          item.cast<String, Object?>()
        else
          throw FormatException('$type.$key: expected maps in the list'),
    ];
  }

  List<String> strings(String key) {
    final value = map[key];
    if (value is! List) throw FormatException('$type.$key: expected a list');
    final result = <String>[];
    for (final (i, item) in value.indexed) {
      if (item is! String) {
        throw FormatException(
          '$type.$key[$i]: expected String, got ${item.runtimeType}',
        );
      }
      result.add(item);
    }
    return List.unmodifiable(result);
  }
}

/// Element-wise list equality for value-equal models.
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
