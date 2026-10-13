import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

enum MaintenanceStatus { open, inProgress, completed }

enum MaintenancePriority { low, medium, high }

/// The seven categories offered by Create Request.
enum MaintenanceCategory {
  plumbing,
  electrical,
  structural,
  waterMotor,
  appliance,
  painting,
  other,
}

/// One entry in a request's activity log (a status change or creation).
class MaintenanceEvent {
  MaintenanceEvent({
    required this.id,
    required this.at,
    required this.toStatus,
    this.fromStatus,
    this.note = '',
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    if (!at.isUtc) throw ArgumentError.value(at, 'at', 'must be UTC');
  }

  final String id;

  /// When it happened, as a UTC instant.
  final DateTime at;

  /// Null for the creation event.
  final MaintenanceStatus? fromStatus;
  final MaintenanceStatus toStatus;
  final String note;

  Map<String, Object?> toMap() => {
    'id': id,
    'at': at.toIso8601String(),
    'fromStatus': fromStatus?.name,
    'toStatus': toStatus.name,
    'note': note,
  };

  factory MaintenanceEvent.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'MaintenanceEvent');
    return MaintenanceEvent(
      id: r.string('id'),
      at: r.instant('at'),
      fromStatus: r.optString('fromStatus') == null
          ? null
          : r.enumValue('fromStatus', MaintenanceStatus.values),
      toStatus: r.enumValue('toStatus', MaintenanceStatus.values),
      note: r.string('note'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MaintenanceEvent &&
      other.id == id &&
      other.at == at &&
      other.fromStatus == fromStatus &&
      other.toStatus == toStatus &&
      other.note == note;

  @override
  int get hashCode => Object.hash(id, at, fromStatus, toStatus, note);
}

/// A maintenance request for a property, optionally one unit of it.
///
/// Rules: a request for the entire property has no unit; a completed
/// request has a completion date (not before it was reported) and
/// resolution notes, and only completed requests carry completion date,
/// resolution or cost; the activity log is consistent and ends at
/// [status]. Every status change goes through [transitionTo], which
/// appends to [events].
class MaintenanceRequest {
  MaintenanceRequest({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.category,
    required this.priority,
    required this.reportedOn,
    this.status = MaintenanceStatus.open,
    this.unitId,
    this.entireProperty = false,
    this.tenantId,
    this.description = '',
    this.assigneeName = '',
    this.assigneePhone,
    this.completedOn,
    this.resolution = '',
    this.costPaise,
    List<MaintenanceEvent> events = const [],
  }) : events = List.unmodifiable(events) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    final propertyError = Validators.requiredId(propertyId, 'Property');
    if (propertyError != null) {
      throw ArgumentError.value(propertyId, 'propertyId', propertyError);
    }
    final titleError = Validators.requiredText(
      title,
      'Request title',
      max: Validators.titleMax,
    );
    if (titleError != null) {
      throw ArgumentError.value(title, 'title', titleError);
    }
    if (entireProperty && unitId != null) {
      throw ArgumentError.value(
        unitId,
        'unitId',
        'must be empty for an entire-property request',
      );
    }
    if (assigneePhone != null &&
        !Validators.isCanonicalIndianMobile(assigneePhone!)) {
      throw ArgumentError.value(assigneePhone, 'assigneePhone', 'must be +91');
    }
    if (costPaise != null) Money.checkAmount(costPaise!, name: 'costPaise');
    if (status == MaintenanceStatus.completed) {
      if (completedOn == null || resolution.trim().isEmpty) {
        throw ArgumentError(
          'A completed request needs completedOn and a '
          'resolution',
        );
      }
      if (completedOn!.isBefore(reportedOn)) {
        throw ArgumentError.value(completedOn, 'completedOn', 'before report');
      }
    } else if (completedOn != null ||
        resolution.isNotEmpty ||
        costPaise != null) {
      throw ArgumentError(
        'Only completed requests have completion date, resolution or cost',
      );
    }
    _checkEvents(this.events, status);
  }

  /// The log must read as one consistent history: unique IDs, a creation
  /// event first (no "from"), each change starting where the previous one
  /// ended and actually changing status, times never going backwards, and
  /// the last event matching [status]. An empty log is allowed.
  static void _checkEvents(
    List<MaintenanceEvent> events,
    MaintenanceStatus status,
  ) {
    if (events.isEmpty) return;
    final ids = <String>{};
    for (final (i, e) in events.indexed) {
      if (!ids.add(e.id)) {
        throw ArgumentError.value(e.id, 'events', 'duplicate event ID');
      }
      if (i == 0) {
        if (e.fromStatus != null) {
          throw ArgumentError.value(e.id, 'events', 'first event has a "from"');
        }
        continue;
      }
      final previous = events[i - 1];
      if (e.fromStatus != previous.toStatus || e.fromStatus == e.toStatus) {
        throw ArgumentError.value(
          e.id,
          'events',
          'does not follow ${previous.id}',
        );
      }
      if (e.at.isBefore(previous.at)) {
        throw ArgumentError.value(
          e.id,
          'events',
          'is earlier than ${previous.id}',
        );
      }
    }
    if (events.last.toStatus != status) {
      throw ArgumentError.value(
        status,
        'status',
        'does not match the last event (${events.last.toStatus.name})',
      );
    }
  }

  final String id;
  final String propertyId;
  final String? unitId;
  final bool entireProperty;
  final String? tenantId;
  final String title;
  final MaintenanceCategory category;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final String description;
  final CalendarDate reportedOn;
  final String assigneeName;
  final String? assigneePhone;
  final CalendarDate? completedOn;
  final String resolution;
  final int? costPaise;

  /// Oldest first.
  final List<MaintenanceEvent> events;

  bool get isActive => status != MaintenanceStatus.completed;

  /// Moves to [to] and logs it. Any change to a different status is
  /// allowed (completed requests can be reopened). Completing needs
  /// [completedOn] and [resolution]; reopening clears completion details.
  MaintenanceRequest transitionTo(
    MaintenanceStatus to, {
    required String eventId,
    required DateTime at,
    String note = '',
    CalendarDate? completedOn,
    String? resolution,
    int? costPaise,
  }) {
    if (to == status) {
      throw DomainException(
        'no-status-change',
        'Request $id is already ${status.name}',
      );
    }
    if (events.isNotEmpty && at.toUtc().isBefore(events.last.at)) {
      throw const DomainException(
        'event-order',
        'A status change cannot be dated before the previous one',
      );
    }
    if (events.any((e) => e.id == eventId)) {
      throw DomainException('event-id', 'Event ID $eventId is already used');
    }
    final completing = to == MaintenanceStatus.completed;
    if (completing &&
        (completedOn == null || (resolution ?? '').trim().isEmpty)) {
      throw const DomainException(
        'completion-details',
        'Completion date and resolution notes are required',
      );
    }
    if (completing && completedOn!.isBefore(reportedOn)) {
      throw const DomainException(
        'completion-date',
        'Completion date cannot be before the request was reported',
      );
    }
    return MaintenanceRequest(
      id: id,
      propertyId: propertyId,
      unitId: unitId,
      entireProperty: entireProperty,
      tenantId: tenantId,
      title: title,
      category: category,
      priority: priority,
      status: to,
      description: description,
      reportedOn: reportedOn,
      assigneeName: assigneeName,
      assigneePhone: assigneePhone,
      completedOn: completing ? completedOn : null,
      resolution: completing ? resolution!.trim() : '',
      costPaise: completing ? (costPaise ?? this.costPaise) : null,
      events: [
        ...events,
        MaintenanceEvent(
          id: eventId,
          at: at.toUtc(),
          fromStatus: status,
          toStatus: to,
          note: note,
        ),
      ],
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'propertyId': propertyId,
    'unitId': unitId,
    'entireProperty': entireProperty,
    'tenantId': tenantId,
    'title': title,
    'category': category.name,
    'priority': priority.name,
    'status': status.name,
    'description': description,
    'reportedOn': reportedOn.toIso(),
    'assigneeName': assigneeName,
    'assigneePhone': assigneePhone,
    'completedOn': completedOn?.toIso(),
    'resolution': resolution,
    'costPaise': costPaise,
    'events': [for (final e in events) e.toMap()],
  };

  factory MaintenanceRequest.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'MaintenanceRequest');
    return MaintenanceRequest(
      id: r.string('id'),
      propertyId: r.string('propertyId'),
      unitId: r.optString('unitId'),
      entireProperty: r.boolean('entireProperty'),
      tenantId: r.optString('tenantId'),
      title: r.string('title'),
      category: r.enumValue('category', MaintenanceCategory.values),
      priority: r.enumValue('priority', MaintenancePriority.values),
      status: r.enumValue('status', MaintenanceStatus.values),
      description: r.string('description'),
      reportedOn: r.date('reportedOn'),
      assigneeName: r.string('assigneeName'),
      assigneePhone: r.optString('assigneePhone'),
      completedOn: r.optDate('completedOn'),
      resolution: r.string('resolution'),
      costPaise: r.optInteger('costPaise'),
      events: [
        for (final e in r.children('events')) MaintenanceEvent.fromMap(e),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MaintenanceRequest &&
      other.id == id &&
      other.propertyId == propertyId &&
      other.unitId == unitId &&
      other.entireProperty == entireProperty &&
      other.tenantId == tenantId &&
      other.title == title &&
      other.category == category &&
      other.priority == priority &&
      other.status == status &&
      other.description == description &&
      other.reportedOn == reportedOn &&
      other.assigneeName == assigneeName &&
      other.assigneePhone == assigneePhone &&
      other.completedOn == completedOn &&
      other.resolution == resolution &&
      other.costPaise == costPaise &&
      listEquals(other.events, events);

  @override
  int get hashCode => Object.hashAll([
    id,
    propertyId,
    unitId,
    entireProperty,
    tenantId,
    title,
    category,
    priority,
    status,
    description,
    reportedOn,
    assigneeName,
    assigneePhone,
    completedOn,
    resolution,
    costPaise,
    Object.hashAll(events),
  ]);
}
