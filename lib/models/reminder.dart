import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReminderType {
  workout,
  meal,
  hydration,
  sleep,
  custom,
}

enum ReminderFrequency {
  daily,
  weekly,
  monthly,
  custom,
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderFrequency frequency;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isRepeating;
  final int? customInterval; // in days for custom frequency
  final Map<String, dynamic>? metadata; // Additional data for specific reminder types
  final DateTime createdAt;
  final DateTime? lastTriggered;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.time,
    this.daysOfWeek = const [],
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.isRepeating = true,
    this.customInterval,
    this.metadata,
    required this.createdAt,
    this.lastTriggered,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timeData = data['time'] as Map<String, dynamic>;
    
    return Reminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ReminderType.values.firstWhere(
        (t) => t.toString() == 'ReminderType.${data['type']}',
        orElse: () => ReminderType.custom,
      ),
      frequency: ReminderFrequency.values.firstWhere(
        (f) => f.toString() == 'ReminderFrequency.${data['frequency']}',
        orElse: () => ReminderFrequency.daily,
      ),
      time: TimeOfDay(
        hour: timeData['hour'] ?? 9,
        minute: timeData['minute'] ?? 0,
      ),
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isRepeating: data['isRepeating'] ?? true,
      customInterval: data['customInterval'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastTriggered: data['lastTriggered'] != null
          ? (data['lastTriggered'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'daysOfWeek': daysOfWeek,
      'startDate': startDate != null
          ? Timestamp.fromDate(startDate!)
          : null,
      'endDate': endDate != null
          ? Timestamp.fromDate(endDate!)
          : null,
      'isActive': isActive,
      'isRepeating': isRepeating,
      'customInterval': customInterval,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggered': lastTriggered != null
          ? Timestamp.fromDate(lastTriggered!)
          : null,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    TimeOfDay? time,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isRepeating,
    int? customInterval,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isRepeating: isRepeating ?? this.isRepeating,
      customInterval: customInterval ?? this.customInterval,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  // Get formatted time
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get formatted days of week
  String get formattedDaysOfWeek {
    if (daysOfWeek.isEmpty) return 'Every day';
    
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = daysOfWeek
        .where((day) => day >= 1 && day <= 7)
        .map((day) => dayNames[day - 1])
        .toList();
    
    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.length == 5 && 
        daysOfWeek.contains(1) && daysOfWeek.contains(2) && 
        daysOfWeek.contains(3) && daysOfWeek.contains(4) && 
        daysOfWeek.contains(5)) return 'Weekdays';
    if (selectedDays.length == 2 && 
        daysOfWeek.contains(6) && daysOfWeek.contains(7)) return 'Weekends';
    
    return selectedDays.join(', ');
  }

  // Check if reminder should trigger today
  bool shouldTriggerToday() {
    if (!isActive) return false;
    
    final now = DateTime.now();
    
    // Check date range
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    
    // Check frequency
    switch (frequency) {
      case ReminderFrequency.daily:
        return true;
      case ReminderFrequency.weekly:
        return daysOfWeek.contains(now.weekday);
      case ReminderFrequency.monthly:
        return now.day == (startDate?.day ?? 1);
      case ReminderFrequency.custom:
        if (customInterval == null) return false;
        if (lastTriggered == null) return true;
        final daysSinceLastTrigger = now.difference(lastTriggered!).inDays;
        return daysSinceLastTrigger >= customInterval!;
    }
  }

  // Get next trigger time
  DateTime? getNextTriggerTime() {
    if (!isActive) return null;
    
    final now = DateTime.now();
    DateTime nextTrigger = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // If the time has passed today, start from tomorrow
    if (nextTrigger.isBefore(now)) {
      nextTrigger = nextTrigger.add(const Duration(days: 1));
    }
    
    // Check date range
    if (startDate != null && nextTrigger.isBefore(startDate!)) {
      nextTrigger = startDate!;
      nextTrigger = DateTime(
        nextTrigger.year,
        nextTrigger.month,
        nextTrigger.day,
        time.hour,
        time.minute,
      );
    }
    
    if (endDate != null && nextTrigger.isAfter(endDate!)) {
      return null;
    }
    
    // Find next valid day based on frequency
    switch (frequency) {
      case ReminderFrequency.daily:
        return nextTrigger;
      case ReminderFrequency.weekly:
        while (!daysOfWeek.contains(nextTrigger.weekday)) {
          nextTrigger = nextTrigger.add(const Duration(days: 1));
          if (endDate != null && nextTrigger.isAfter(endDate!)) return null;
        }
        return nextTrigger;
      case ReminderFrequency.monthly:
        final targetDay = startDate?.day ?? 1;
        while (nextTrigger.day != targetDay) {
          nextTrigger = nextTrigger.add(const Duration(days: 1));
          if (endDate != null && nextTrigger.isAfter(endDate!)) return null;
        }
        return nextTrigger;
      case ReminderFrequency.custom:
        if (customInterval == null) return null;
        if (lastTriggered == null) return nextTrigger;
        final nextCustomTrigger = lastTriggered!.add(Duration(days: customInterval!));
        return nextCustomTrigger.isAfter(now) ? nextCustomTrigger : null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, type: $type, time: $formattedTime)';
  }
}

class NotificationSettings {
  final bool workoutReminders;
  final bool mealReminders;
  final bool hydrationReminders;
  final bool sleepReminders;
  final bool customReminders;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool badgeEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final bool quietHoursEnabled;

  NotificationSettings({
    this.workoutReminders = true,
    this.mealReminders = true,
    this.hydrationReminders = true,
    this.sleepReminders = true,
    this.customReminders = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.badgeEnabled = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.quietHoursEnabled = false,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    final quietStartData = map['quietHoursStart'] as Map<String, dynamic>?;
    final quietEndData = map['quietHoursEnd'] as Map<String, dynamic>?;
    
    return NotificationSettings(
      workoutReminders: map['workoutReminders'] ?? true,
      mealReminders: map['mealReminders'] ?? true,
      hydrationReminders: map['hydrationReminders'] ?? true,
      sleepReminders: map['sleepReminders'] ?? true,
      customReminders: map['customReminders'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      badgeEnabled: map['badgeEnabled'] ?? true,
      quietHoursStart: quietStartData != null
          ? TimeOfDay(
              hour: quietStartData['hour'] ?? 22,
              minute: quietStartData['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: quietEndData != null
          ? TimeOfDay(
              hour: quietEndData['hour'] ?? 7,
              minute: quietEndData['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 7, minute: 0),
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutReminders': workoutReminders,
      'mealReminders': mealReminders,
      'hydrationReminders': hydrationReminders,
      'sleepReminders': sleepReminders,
      'customReminders': customReminders,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'badgeEnabled': badgeEnabled,
      'quietHoursStart': {
        'hour': quietHoursStart.hour,
        'minute': quietHoursStart.minute,
      },
      'quietHoursEnd': {
        'hour': quietHoursEnd.hour,
        'minute': quietHoursEnd.minute,
      },
      'quietHoursEnabled': quietHoursEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? workoutReminders,
    bool? mealReminders,
    bool? hydrationReminders,
    bool? sleepReminders,
    bool? customReminders,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? quietHoursEnabled,
  }) {
    return NotificationSettings(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      mealReminders: mealReminders ?? this.mealReminders,
      hydrationReminders: hydrationReminders ?? this.hydrationReminders,
      sleepReminders: sleepReminders ?? this.sleepReminders,
      customReminders: customReminders ?? this.customReminders,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    );
  }
}
