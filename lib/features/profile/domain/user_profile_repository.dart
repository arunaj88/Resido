import 'package:resido/features/profile/domain/user_profile.dart';

/// The signed-in landlord's profile and preferences.
abstract interface class UserProfileRepository {
  /// The current profile, or null when none exists yet.
  Future<UserProfile?> getProfile();

  Future<void> saveProfile(UserProfile profile);

  /// Replaces only the notification preferences. Throws
  /// RecordNotFoundException when there is no profile.
  Future<UserProfile> updatePreferences(NotificationPreferences preferences);
}
