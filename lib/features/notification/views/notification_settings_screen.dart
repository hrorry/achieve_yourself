import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/notification_settings_viewmodel.dart';
import '../models/notification_settings.dart';
import '../../goal_setting/models/goal.dart';
import 'widgets/goal_notification_card.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  final String? selectedGoalId;

  const NotificationSettingsScreen({super.key, this.selectedGoalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationSettingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(notificationSettingsViewModelProvider.notifier).refresh())],
      ),
      body: notificationState.when(
        data: (settings) => settings.isEmpty ? _buildEmptyState(context) : _buildNotificationSettings(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラーが発生しました: $error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.read(notificationSettingsViewModelProvider.notifier).refresh(), child: const Text('再試行')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('通知設定がありません', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            '目標を設定すると、通知設定ができるようになります',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref, List<NotificationSettings> settings) {
    // 仮の目標データ（実際は目標データから取得）
    final goals = [
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

    // 選択された目標の通知設定をフィルタリング
    final filteredSettings = selectedGoalId != null ? settings.where((setting) => setting.goalId == selectedGoalId).toList() : settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダーセクション
          _buildHeaderSection(context),
          const SizedBox(height: 24),

          // 選択された目標の通知設定（存在しない場合は作成）
          if (selectedGoalId != null) ...[_buildSelectedGoalNotificationSection(context, ref, selectedGoalId!, goals), const SizedBox(height: 24)],

          // 全体的な設定セクション
          _buildGlobalSettingsSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text('通知設定', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '各目標に対する通知のON/OFFやリマインダー時間を設定できます。\n目標達成をサポートするために、適切な通知設定を行いましょう！',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedGoalNotificationSection(BuildContext context, WidgetRef ref, String goalId, List<Goal> goals) {
    final goal = goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => Goal(
        id: goalId,
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

    // 既存の通知設定を取得
    final notificationState = ref.watch(notificationSettingsViewModelProvider);

    return notificationState.when(
      data: (settings) {
        final existingSettings = settings.firstWhere(
          (setting) => setting.goalId == goalId,
          orElse: () {
            // 通知設定が存在しない場合は自動的に作成
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(notificationSettingsViewModelProvider.notifier).createNotificationSettings(goalId);
            });

            return NotificationSettings(
              id: 'temp_$goalId',
              goalId: goalId,
              isEnabled: true,
              reminderTimes: [],
              type: NotificationType.daily,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          },
        );

        // 直接GoalNotificationCardを返す（ヘッダーカードは不要）
        return GoalNotificationCard(goal: goal, notificationSettings: existingSettings);
      },
      loading: () => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text('エラー: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalSettingsSection(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('全体的な設定', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // 全体的な通知ON/OFF
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('通知を有効にする', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('すべての通知を一括でON/OFFできます', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                Switch(
                  value: true, // TODO: 実際の設定から取得
                  onChanged: (value) {
                    // TODO: 全体的な通知設定を更新
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 通知音設定
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('通知音', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('通知音の種類を選択', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    // TODO: 通知音設定画面に遷移
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 通知履歴
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('通知履歴', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('過去の通知を確認', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    // TODO: 通知履歴画面に遷移
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
