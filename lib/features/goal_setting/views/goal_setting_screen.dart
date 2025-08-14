import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../viewmodels/goal_setting_viewmodel.dart';
import '../models/goal.dart';
import 'goal_form_screen.dart';

class GoalSettingScreen extends ConsumerWidget {
  final String? selectedGoalId;

  const GoalSettingScreen({super.key, this.selectedGoalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalSettingProvider);
    final viewModel = ref.read(goalSettingProvider.notifier);

    // 選択された目標がある場合は、直接その目標の編集画面に遷移
    if (selectedGoalId != null) {
      final selectedGoal = goals.firstWhere(
        (goal) => goal.id == selectedGoalId,
        orElse: () => Goal(
          id: selectedGoalId!,
          title: '不明な目標',
          description: '',
          type: GoalType.custom,
          progress: 0.0,
          reward: '',
          actions: [],
          createdAt: DateTime.now(),
          targetDate: DateTime.now(),
        ),
      );

      // 少し遅延を入れてから遷移（画面の構築を待つ）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GoalFormScreen(goal: selectedGoal)));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('目標設定', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: goals.isEmpty ? _buildEmptyState(context) : _buildGoalList(context, goals, viewModel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToGoalForm(context),
        icon: const Icon(Icons.add),
        label: const Text('新しい目標'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('まだ目標がありません', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            '新しい目標を作成して、\nあなたの夢を実現しましょう！',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToGoalForm(context),
            icon: const Icon(Icons.add),
            label: const Text('最初の目標を作成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, List<Goal> goals, GoalSettingViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildGoalCard(context, goal, viewModel));
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal, GoalSettingViewModel viewModel) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _navigateToGoalForm(context, goal: goal),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '編集',
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context, goal, viewModel),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '削除',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _navigateToGoalForm(context, goal: goal),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Text(goal.type.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            goal.type.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: goal.isActive, onChanged: (_) => viewModel.toggleGoalActive(goal.id)),
                  ],
                ),
                if (goal.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('進捗', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: goal.progress,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(goal.progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: goal.progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (goal.reward.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        goal.reward,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGoalForm(BuildContext context, {Goal? goal}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GoalFormScreen(goal: goal)));
  }

  void _showDeleteDialog(BuildContext context, Goal goal, GoalSettingViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を削除'),
        content: Text('「${goal.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              viewModel.deleteGoal(goal.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
