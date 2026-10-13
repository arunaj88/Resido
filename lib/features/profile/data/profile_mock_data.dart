import 'package:flutter/material.dart';
import 'package:resido/features/dashboard/data/dashboard_mock_data.dart';

/// A notification preference shown on Settings. The switch state is
/// temporary UI state only.
class NotificationPreference {
  const NotificationPreference({
    required this.title,
    required this.description,
    required this.icon,
    required this.enabledByDefault,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool enabledByDefault;
}

/// Static landlord profile shared by Profile, Edit Profile and Settings.
abstract final class ProfileMockData {
  static const name = DashboardMockData.landlordFullName;
  static const initials = 'HM';
  static const email = 'harikrishnan.menon@keralaestates.in';

  /// Ten digits without +91.
  static const phone = '9847012890';
  static const displayPhone = '+91 98470 12890';
  static const city = 'Kochi, Kerala';
  static const district = 'Kochi, Ernakulam District, Kerala';
  static const accountId = 'KL-9240';
  static const portfolio = '4 Estates · 12 Units';
  static const portfolioDetail =
      '4 Managed Properties • Kochi, Aluva & Kozhikode';
  static const rentCycle = '1st of Month';
  static const passwordNote = 'Last changed 45 days ago';

  /// Matches `version: 1.0.0+1` in pubspec.yaml.
  static const appVersion = 'Version 1.0.0 (Build 1)';

  static const notificationPreferences = [
    NotificationPreference(
      title: 'WhatsApp Rent Receipts',
      description: 'Offer a WhatsApp receipt option after recording rent',
      icon: Icons.chat_outlined,
      enabledByDefault: true,
    ),
    NotificationPreference(
      title: 'Rent Due Reminders',
      description: 'Reminders 3 days before the due date and on the due date',
      icon: Icons.event_repeat,
      enabledByDefault: true,
    ),
    NotificationPreference(
      title: 'Maintenance Ticket Updates',
      description: 'Alerts when a tenant reports an issue or adds a comment',
      icon: Icons.build_circle_outlined,
      enabledByDefault: true,
    ),
    NotificationPreference(
      title: 'Monthly Financial Digest',
      description: 'Summary of monthly collections on the 1st of every month',
      icon: Icons.query_stats,
      enabledByDefault: false,
    ),
  ];
}
