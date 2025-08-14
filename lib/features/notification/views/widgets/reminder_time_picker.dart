import 'package:flutter/material.dart';
import '../../models/notification_settings.dart';

class ReminderTimePicker extends StatefulWidget {
  final Function(NotificationTime) onTimeSelected;

  const ReminderTimePicker({super.key, required this.onTimeSelected});

  @override
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // デフォルトは毎日

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('リマインダー時間を設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 時間選択
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('時間'),
            subtitle: Text(_selectedTime.format(context)),
            onTap: () => _showTimePicker(context),
          ),

          const SizedBox(height: 16),

          // 曜日選択
          const Text('曜日', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDaySelector(),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
        ElevatedButton(
          onPressed: () {
            final notificationTime = NotificationTime(hour: _selectedTime.hour, minute: _selectedTime.minute, daysOfWeek: _selectedDays);
            widget.onTimeSelected(notificationTime);
            Navigator.of(context).pop();
          },
          child: const Text('追加'),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    const dayNames = ['日', '月', '火', '水', '木', '金', '土'];
    const dayValues = [7, 1, 2, 3, 4, 5, 6]; // 日曜日から土曜日

    return Wrap(
      spacing: 8,
      children: dayValues.asMap().entries.map((entry) {
        final index = entry.key;
        final dayValue = entry.value;
        final isSelected = _selectedDays.contains(dayValue);

        return FilterChip(
          label: Text(dayNames[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayValue);
              } else {
                _selectedDays.remove(dayValue);
              }
              // 少なくとも1つの曜日は選択されているようにする
              if (_selectedDays.isEmpty) {
                _selectedDays.add(dayValue);
              }
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: Theme.of(context).colorScheme.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}
