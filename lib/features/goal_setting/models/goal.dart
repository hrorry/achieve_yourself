class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final double progress;
  final String reward;
  final List<String> actions;
  final DateTime createdAt;
  final DateTime? targetDate;
  final bool isActive;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.progress = 0.0,
    this.reward = '',
    this.actions = const [],
    required this.createdAt,
    this.targetDate,
    this.isActive = true,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    double? progress,
    String? reward,
    List<String>? actions,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      reward: reward ?? this.reward,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'progress': progress,
      'reward': reward,
      'actions': actions,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      progress: json['progress']?.toDouble() ?? 0.0,
      reward: json['reward'] ?? '',
      actions: List<String>.from(json['actions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      isActive: json['isActive'] ?? true,
    );
  }
}

enum GoalType {
  diet('ダイエット', '🍎', '健康的な体重管理を目指しましょう'),
  study('勉強', '📚', '知識を身につけて成長しましょう'),
  exercise('運動', '💪', '体を動かして健康になりましょう'),
  work('仕事', '💼', 'キャリアアップを目指しましょう'),
  hobby('趣味', '🎨', '楽しい時間を過ごしましょう'),
  custom('カスタム', '🎯', '自分だけの目標を作りましょう');

  const GoalType(this.displayName, this.emoji, this.description);

  final String displayName;
  final String emoji;
  final String description;
}
