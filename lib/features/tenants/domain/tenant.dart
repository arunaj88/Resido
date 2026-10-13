import 'package:resido/core/domain/record_status.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

/// A tenant contact. Whether they are currently housed is derived from
/// their tenancies, not stored here.
class Tenant {
  Tenant({
    required this.id,
    required this.name,
    this.phone,
    this.email = '',
    this.notes = '',
    this.status = RecordStatus.active,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    final nameError = Validators.requiredText(
      name,
      'Full name',
      max: Validators.nameMax,
    );
    if (nameError != null) throw ArgumentError.value(name, 'name', nameError);
    if (phone != null && !Validators.isCanonicalIndianMobile(phone!)) {
      throw ArgumentError.value(phone, 'phone', 'must be +91XXXXXXXXXX');
    }
    final notesError = Validators.optionalText(notes, 'Notes');
    if (notesError != null) {
      throw ArgumentError.value(notes, 'notes', notesError);
    }
  }

  final String id;
  final String name;

  /// Canonical `+91XXXXXXXXXX`, optional.
  final String? phone;
  final String email;
  final String notes;
  final RecordStatus status;

  Tenant copyWith({
    String? name,
    String? phone,
    String? email,
    String? notes,
    RecordStatus? status,
  }) => Tenant(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    notes: notes ?? this.notes,
    status: status ?? this.status,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'notes': notes,
    'status': status.name,
  };

  factory Tenant.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'Tenant');
    return Tenant(
      id: r.string('id'),
      name: r.string('name'),
      phone: r.optString('phone'),
      email: r.string('email'),
      notes: r.string('notes'),
      status: r.enumValue('status', RecordStatus.values),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Tenant &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.email == email &&
      other.notes == notes &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, name, phone, email, notes, status);
}
