import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/validators.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';
import 'package:resido/features/profile/domain/user_profile.dart';
import 'package:resido/features/profile/domain/user_profile_repository.dart';

/// In-memory profile store. Each instance has its own state.
class InMemoryUserProfileRepository implements UserProfileRepository {
  InMemoryUserProfileRepository([this._profile]);

  /// Seeded from [ProfileMockData] (the landlord shown on Profile).
  factory InMemoryUserProfileRepository.seeded() =>
      InMemoryUserProfileRepository(seedProfile());

  /// The domain form of the Profile screen's mock landlord.
  static UserProfile seedProfile() {
    final defaults = ProfileMockData.notificationPreferences;
    return UserProfile(
      id: 'landlord-${ProfileMockData.accountId.toLowerCase()}',
      displayName: ProfileMockData.name,
      email: ProfileMockData.email,
      phone: Validators.normalizeIndianMobile(ProfileMockData.phone),
      district: ProfileMockData.district,
      accountCode: ProfileMockData.accountId,
      preferences: NotificationPreferences(
        whatsAppRentReceipts: defaults[0].enabledByDefault,
        rentDueReminders: defaults[1].enabledByDefault,
        maintenanceUpdates: defaults[2].enabledByDefault,
        monthlyDigest: defaults[3].enabledByDefault,
      ),
    );
  }

  UserProfile? _profile;

  @override
  Future<UserProfile?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async => _profile = profile;

  @override
  Future<UserProfile> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    final current = _profile;
    if (current == null) throw RecordNotFoundException('UserProfile', 'me');
    return _profile = current.copyWith(preferences: preferences);
  }
}
