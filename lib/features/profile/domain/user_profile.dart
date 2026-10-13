import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

/// The landlord's notification choices (the four Settings switches).
class NotificationPreferences {
  const NotificationPreferences({
    required this.whatsAppRentReceipts,
    required this.rentDueReminders,
    required this.maintenanceUpdates,
    required this.monthlyDigest,
  });

  /// Defaults matching the Settings screen.
  static const defaults = NotificationPreferences(
    whatsAppRentReceipts: true,
    rentDueReminders: true,
    maintenanceUpdates: true,
    monthlyDigest: false,
  );

  final bool whatsAppRentReceipts;
  final bool rentDueReminders;
  final bool maintenanceUpdates;
  final bool monthlyDigest;

  NotificationPreferences copyWith({
    bool? whatsAppRentReceipts,
    bool? rentDueReminders,
    bool? maintenanceUpdates,
    bool? monthlyDigest,
  }) => NotificationPreferences(
    whatsAppRentReceipts: whatsAppRentReceipts ?? this.whatsAppRentReceipts,
    rentDueReminders: rentDueReminders ?? this.rentDueReminders,
    maintenanceUpdates: maintenanceUpdates ?? this.maintenanceUpdates,
    monthlyDigest: monthlyDigest ?? this.monthlyDigest,
  );

  Map<String, Object?> toMap() => {
    'whatsAppRentReceipts': whatsAppRentReceipts,
    'rentDueReminders': rentDueReminders,
    'maintenanceUpdates': maintenanceUpdates,
    'monthlyDigest': monthlyDigest,
  };

  factory NotificationPreferences.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'NotificationPreferences');
    return NotificationPreferences(
      whatsAppRentReceipts: r.boolean('whatsAppRentReceipts'),
      rentDueReminders: r.boolean('rentDueReminders'),
      maintenanceUpdates: r.boolean('maintenanceUpdates'),
      monthlyDigest: r.boolean('monthlyDigest'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationPreferences &&
      other.whatsAppRentReceipts == whatsAppRentReceipts &&
      other.rentDueReminders == rentDueReminders &&
      other.maintenanceUpdates == maintenanceUpdates &&
      other.monthlyDigest == monthlyDigest;

  @override
  int get hashCode => Object.hash(
    whatsAppRentReceipts,
    rentDueReminders,
    maintenanceUpdates,
    monthlyDigest,
  );
}

/// The signed-in landlord. [id] will be the auth user ID once
/// authentication exists; [phone] is canonical `+91XXXXXXXXXX` when set.
class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone,
    this.district = '',
    this.accountCode = '',
    this.preferences = NotificationPreferences.defaults,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    final nameError = Validators.requiredText(
      displayName,
      'Name',
      max: Validators.nameMax,
    );
    if (nameError != null) {
      throw ArgumentError.value(displayName, 'displayName', nameError);
    }
    if (!email.contains('@')) {
      throw ArgumentError.value(email, 'email', 'is not an email address');
    }
    if (phone != null && !Validators.isCanonicalIndianMobile(phone!)) {
      throw ArgumentError.value(phone, 'phone', 'must be +91XXXXXXXXXX');
    }
  }

  final String id;
  final String displayName;
  final String email;
  final String? phone;
  final String district;
  final String accountCode;
  final NotificationPreferences preferences;

  UserProfile copyWith({
    String? displayName,
    String? phone,
    String? district,
    NotificationPreferences? preferences,
  }) => UserProfile(
    id: id,
    displayName: displayName ?? this.displayName,
    email: email,
    phone: phone ?? this.phone,
    district: district ?? this.district,
    accountCode: accountCode,
    preferences: preferences ?? this.preferences,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'district': district,
    'accountCode': accountCode,
    'preferences': preferences.toMap(),
  };

  factory UserProfile.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'UserProfile');
    return UserProfile(
      id: r.string('id'),
      displayName: r.string('displayName'),
      email: r.string('email'),
      phone: r.optString('phone'),
      district: r.string('district'),
      accountCode: r.string('accountCode'),
      preferences: NotificationPreferences.fromMap(r.child('preferences')),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.displayName == displayName &&
      other.email == email &&
      other.phone == phone &&
      other.district == district &&
      other.accountCode == accountCode &&
      other.preferences == preferences;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    email,
    phone,
    district,
    accountCode,
    preferences,
  );
}
