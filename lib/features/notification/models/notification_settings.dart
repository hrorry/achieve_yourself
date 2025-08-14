class NotificationSettings {
  final String id;
  final String goalId;
  final bool isEnabled;
  final List<NotificationTime> reminderTimes;
  final NotificationType type;
  final String? customMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettings({
    required this.id,
    required this.goalId,
    this.isEnabled = true,
    this.reminderTimes = const [],
    this.type = NotificationType.daily,
    this.customMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationSettings copyWith({
    String? id,
    String? goalId,
    bool? isEnabled,
    List<NotificationTime>? reminderTimes,
    NotificationType? type,
    String? customMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      type: type ?? this.type,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'isEnabled': isEnabled,
      'reminderTimes': reminderTimes.map((time) => time.toJson()).toList(),
      'type': type.name,
      'customMessage': customMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'],
      goalId: json['goalId'],
      isEnabled: json['isEnabled'] ?? true,
      reminderTimes: (json['reminderTimes'] as List?)?.map((time) => NotificationTime.fromJson(time)).toList() ?? [],
      type: NotificationType.values.firstWhere((e) => e.name == json['type'], orElse: () => NotificationType.daily),
      customMessage: json['customMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class NotificationTime {
  final int hour;
  final int minute;
  final List<int> daysOfWeek; // 0=日曜日, 1=月曜日, ..., 6=土曜日

  NotificationTime({
    required this.hour,
    required this.minute,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7], // デフォルトは毎日
  });

  NotificationTime copyWith({int? hour, int? minute, List<int>? daysOfWeek}) {
    return NotificationTime(hour: hour ?? this.hour, minute: minute ?? this.minute, daysOfWeek: daysOfWeek ?? this.daysOfWeek);
  }

  Map<String, dynamic> toJson() {
    return {'hour': hour, 'minute': minute, 'daysOfWeek': daysOfWeek};
  }

  factory NotificationTime.fromJson(Map<String, dynamic> json) {
    return NotificationTime(hour: json['hour'], minute: json['minute'], daysOfWeek: List<int>.from(json['daysOfWeek'] ?? [1, 2, 3, 4, 5, 6, 7]));
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get daysOfWeekText {
    if (daysOfWeek.length == 7) return '毎日';
    if (daysOfWeek.length == 5 && [1, 2, 3, 4, 5].every((day) => daysOfWeek.contains(day))) return '平日';
    if (daysOfWeek.length == 2 && [6, 7].every((day) => daysOfWeek.contains(day))) return '週末';

    final dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    return daysOfWeek.map((day) => dayNames[day - 1]).join(', ');
  }
}

enum NotificationType {
  daily('毎日', '毎日同じ時間にリマインダー'),
  weekly('週次', '週に1回の進捗確認'),
  milestone('マイルストーン', '目標達成の節目で通知'),
  custom('カスタム', 'カスタムメッセージで通知');

  const NotificationType(this.displayName, this.description);
  final String displayName;
  final String description;
}
