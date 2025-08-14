class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final AIService selectedAIService;
  final String? apiKey;
  final AICharacter selectedAICharacter;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.selectedAIService = AIService.openai,
    this.apiKey,
    this.selectedAICharacter = AICharacter.tsundere,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    AIService? selectedAIService,
    String? apiKey,
    AICharacter? selectedAICharacter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      selectedAIService: selectedAIService ?? this.selectedAIService,
      apiKey: apiKey ?? this.apiKey,
      selectedAICharacter: selectedAICharacter ?? this.selectedAICharacter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'selectedAIService': selectedAIService.name,
      'apiKey': apiKey,
      'selectedAICharacter': selectedAICharacter.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      selectedAIService: AIService.values.firstWhere(
        (e) => e.name == json['selectedAIService'],
        orElse: () => AIService.openai,
      ),
      apiKey: json['apiKey'],
      selectedAICharacter: AICharacter.values.firstWhere(
        (e) => e.name == json['selectedAICharacter'],
        orElse: () => AICharacter.tsundere,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum AIService {
  openai('OpenAI (ChatGPT)', 'ChatGPT APIを使用します'),
  gemini('Google Gemini', 'Google Gemini APIを使用します');

  const AIService(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum AICharacter {
  tsundere('ツンデレAI', 'べ、別にあんたのために言ってるわけじゃないんだからね！', '😤'),
  healing('癒し系AI', '大丈夫、一緒に頑張ろうね。あなたならできるよ！', '🌸'),
  strict('鬼コーチAI', '甘い！もっと本気で取り組まないと目標は達成できないぞ！', '💪'),
  friendly('フレンドリーAI', 'よっ！今日も一緒に頑張ろう！', '😊');

  const AICharacter(this.displayName, this.description, this.emoji);
  final String displayName;
  final String description;
  final String emoji;
} 