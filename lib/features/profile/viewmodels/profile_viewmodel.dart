import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

class ProfileViewModel extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileViewModel() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  UserProfile? get profile => state.value;
  bool get isLoading => state.isLoading;
  String? get error => state.error?.toString();

  Future<void> _loadProfile() async {
    try {
      state = const AsyncValue.loading();

      // TODO: 実際のデータベースから読み込み
      // 仮のデータを作成
      await Future.delayed(const Duration(milliseconds: 500));
      final profile = UserProfile(
        id: '1',
        name: 'ホリウチ',
        email: 'horiuchi@example.com',
        bio: '目標達成を目指して頑張ります！',
        selectedAIService: AIService.openai,
        selectedAICharacter: AICharacter.tsundere,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(profile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProfile({String? name, String? email, String? bio, AIService? selectedAIService, String? apiKey, AICharacter? selectedAICharacter}) async {
    try {
      final currentProfile = state.value;
      if (currentProfile == null) return;

      final updatedProfile = currentProfile.copyWith(
        name: name,
        email: email,
        bio: bio,
        selectedAIService: selectedAIService,
        apiKey: apiKey,
        selectedAICharacter: selectedAICharacter,
        updatedAt: DateTime.now(),
      );

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));

      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateAIService(AIService service) async {
    await updateProfile(selectedAIService: service);
  }

  Future<void> updateAICharacter(AICharacter character) async {
    await updateProfile(selectedAICharacter: character);
  }

  Future<void> updateAPIKey(String apiKey) async {
    await updateProfile(apiKey: apiKey);
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, AsyncValue<UserProfile?>>((ref) => ProfileViewModel());
