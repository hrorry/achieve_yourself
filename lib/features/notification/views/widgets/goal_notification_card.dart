import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/notification_settings_viewmodel.dart';
import '../../models/notification_settings.dart';
import '../../../goal_setting/models/goal.dart';
import 'reminder_time_picker.dart';

class GoalNotificationCard extends ConsumerStatefulWidget {
  final Goal goal;
  final NotificationSettings notificationSettings;

  const GoalNotificationCard({super.key, required this.goal, required this.notificationSettings});

  @override
  ConsumerState<GoalNotificationCard> createState() => _GoalNotificationCardState();
}

class _GoalNotificationCardState extends ConsumerState<GoalNotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ヘッダー部分（常に表示）
          _buildHeader(context),

          // 展開可能な詳細部分
          if (_isExpanded) _buildExpandedContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 目標アイコン
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.goal.type.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),

            // 目標情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.goal.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 通知ON/OFFスイッチ
            Switch(
              value: widget.notificationSettings.isEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsViewModelProvider.notifier).toggleNotification(widget.notificationSettings.id, value);
              },
            ),

            // 展開アイコン
            Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),

          // 通知タイプ選択
          _buildNotificationTypeSection(context),
          const SizedBox(height: 20),

          // リマインダー時間設定
          _buildReminderTimeSection(context),
          const SizedBox(height: 20),

          // カスタムメッセージ設定
          _buildCustomMessageSection(context),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('通知タイプ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationType.values.map((type) {
            final isSelected = widget.notificationSettings.type == type;
            return FilterChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(notificationSettingsViewModelProvider.notifier).updateNotificationType(widget.notificationSettings.id, type);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),

        const SizedBox(height: 8),
        Text(
          widget.notificationSettings.type.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('リマインダー時間', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            TextButton.icon(onPressed: () => _showTimePickerDialog(context), icon: const Icon(Icons.add), label: const Text('追加')),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.notificationSettings.reminderTimes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 8),
                Text('リマインダー時間が設定されていません', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          )
        else
          ...widget.notificationSettings.reminderTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
                title: Text(time.formattedTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(time.daysOfWeekText),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(notificationSettingsViewModelProvider.notifier).removeReminderTime(widget.notificationSettings.id, index);
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCustomMessageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カスタムメッセージ', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('通知に表示するカスタムメッセージを設定できます', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '例: 今日も頑張ろう！目標達成まであと少し！',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          onChanged: (value) {
            // TODO: カスタムメッセージを更新
          },
        ),
      ],
    );
  }

  void _showTimePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReminderTimePicker(
        onTimeSelected: (time) {
          ref.read(notificationSettingsViewModelProvider.notifier).addReminderTime(widget.notificationSettings.id, time);
        },
      ),
    );
  }
}
