import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';

class GoalSettingViewModel extends StateNotifier<List<Goal>> {
  GoalSettingViewModel() : super([]) {
    _loadInitialGoals();
  }

  void _loadInitialGoals() {
    // 初期データをロード
    state = [
      Goal(
        id: '1',
        title: '夏までに10kg痩せる',
        description: '健康的なダイエットで理想の体型を目指す',
        type: GoalType.diet,
        progress: 0.6,
        reward: '🥇 ダイエットバッジ',
        actions: ['朝ごはんの写真を送ろう', '10分ストレッチしよう'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        targetDate: DateTime.now().add(const Duration(days: 90)),
      ),
      Goal(
        id: '2',
        title: 'TOEICで800点取る',
        description: '英語力を向上させてキャリアアップ',
        type: GoalType.study,
        progress: 0.3,
        reward: '🏅 英語バッジ',
        actions: ['単語帳を30分やろう', 'リスニング問題を解こう'],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        targetDate: DateTime.now().add(const Duration(days: 180)),
      ),
    ];
  }

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void updateGoal(Goal updatedGoal) {
    state = state.map((goal) => goal.id == updatedGoal.id ? updatedGoal : goal).toList();
  }

  void deleteGoal(String goalId) {
    state = state.where((goal) => goal.id != goalId).toList();
  }

  void toggleGoalActive(String goalId) {
    state = state.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(isActive: !goal.isActive);
      }
      return goal;
    }).toList();
  }

  void updateProgress(String goalId, double progress) {
    state = state.map((goal) {
      if (goal.id == goalId) {
        return goal.copyWith(progress: progress.clamp(0.0, 1.0));
      }
      return goal;
    }).toList();
  }

  List<Goal> get activeGoals => state.where((goal) => goal.isActive).toList();
  List<Goal> get completedGoals => state.where((goal) => goal.progress >= 1.0).toList();
  List<Goal> get inProgressGoals => state.where((goal) => goal.progress > 0.0 && goal.progress < 1.0).toList();
}

// Riverpod Provider
final goalSettingProvider = StateNotifierProvider<GoalSettingViewModel, List<Goal>>((ref) {
  return GoalSettingViewModel();
});
