/// Static sample notifications (Stitch "08. Notifications").
library;

import 'package:resido/core/utils/inr_format.dart';


enum NotificationCategory { rent, maintenance, system }

enum NotificationTone { critical, success, info, upcoming, compliant }

enum NotificationAction { whatsAppReminder, viewReceipt }

enum NotificationSection { today, earlierThisWeek }

class MockNotification {
  const MockNotification({
    required this.id,
    required this.category,
    required this.section,
    required this.tone,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.statusLabel,
    this.unread = false,
    this.action,
  });

  final String id;
  final NotificationCategory category;
  final NotificationSection section;
  final NotificationTone tone;
  final String title;
  final String body;
  final String timeAgo;
  final String statusLabel;
  final bool unread;
  final NotificationAction? action;
}

abstract final class NotificationsMockData {
  static final items = [
    MockNotification(
      id: 'rent-overdue-gvv2',
      category: NotificationCategory.rent,
      section: NotificationSection.today,
      tone: NotificationTone.critical,
      title: 'Rent Overdue — Green Valley Villa 2',
      body: '${InrFormat.full(11000)} payment from Ananya Nair was due on 20 Oct '
          '(4 days overdue).',
      timeAgo: '10 mins ago',
      statusLabel: 'Critical',
      unread: true,
      action: NotificationAction.whatsAppReminder,
    ),
    MockNotification(
      id: 'rent-received-4a',
      category: NotificationCategory.rent,
      section: NotificationSection.today,
      tone: NotificationTone.success,
      title: 'Rent Received: ${InrFormat.full(24000)}',
      body: 'Suresh Kumar recorded payment for Flat 4A, Kakkanad via NEFT.',
      timeAgo: '2 hours ago',
      statusLabel: 'Verified',
      action: NotificationAction.viewReceipt,
    ),
    MockNotification(
      id: 'plumbing-104',
      category: NotificationCategory.maintenance,
      section: NotificationSection.today,
      tone: NotificationTone.info,
      title: 'Plumbing Request Updated',
      body: 'Technician assigned for Riverdale #104. Scheduled inspection '
          'today 3:00 PM.',
      timeAgo: '4 hours ago',
      statusLabel: 'In Progress',
      unread: true,
    ),
    MockNotification(
      id: 'rent-due-3b',
      category: NotificationCategory.rent,
      section: NotificationSection.earlierThisWeek,
      tone: NotificationTone.upcoming,
      title: 'Rent Due Soon — Palm Grove #3B',
      body: '${InrFormat.full(22000)} due from Rahul Varma in 4 days (28 Oct).',
      timeAgo: '2 days ago',
      statusLabel: 'Upcoming',
    ),
    MockNotification(
      id: 'police-verification',
      category: NotificationCategory.system,
      section: NotificationSection.earlierThisWeek,
      tone: NotificationTone.compliant,
      title: 'Tenant Police Verification Approved',
      body: 'Local station verification cleared for Dr. Thomas K. '
          '(Aluva Villa).',
      timeAgo: '4 days ago',
      statusLabel: 'Compliant',
    ),
  ];
}
