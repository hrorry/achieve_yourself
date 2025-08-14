import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/goal_setting_viewmodel.dart';
import '../models/goal.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  final Goal? goal;

  const GoalFormScreen({super.key, this.goal});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();

  GoalType _selectedType = GoalType.custom;
  DateTime? _targetDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.goal != null;
    if (_isEditing) {
      final goal = widget.goal!;
      _titleController.text = goal.title;
      _descriptionController.text = goal.description;
      _rewardController.text = goal.reward;
      _selectedType = goal.type;
      _targetDate = goal.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '目標を編集' : '新しい目標'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [if (_isEditing) IconButton(icon: const Icon(Icons.delete), onPressed: _showDeleteDialog)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTypeSelection(),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildRewardField(),
            const SizedBox(height: 16),
            _buildTargetDateField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('目標の種類', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
          itemCount: GoalType.values.length,
          itemBuilder: (context, index) {
            final type = GoalType.values[index];
            final isSelected = _selectedType == type;

            return InkWell(
              onTap: () => setState(() => _selectedType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(type.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.displayName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).colorScheme.primary : null),
                            ),
                            Text(
                              type.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: '目標のタイトル', hintText: '例：夏までに10kg痩せる', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'タイトルを入力してください';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(labelText: '詳細な説明（任意）', hintText: '目標について詳しく説明してください', border: OutlineInputBorder()),
      maxLines: 3,
    );
  }

  Widget _buildRewardField() {
    return TextFormField(
      controller: _rewardController,
      decoration: const InputDecoration(labelText: 'ご褒美（任意）', hintText: '例：🥇 ダイエットバッジ', border: OutlineInputBorder()),
    );
  }

  Widget _buildTargetDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('目標達成予定日（任意）', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  _targetDate != null ? '${_targetDate!.year}年${_targetDate!.month}月${_targetDate!.day}日' : '日付を選択',
                  style: TextStyle(
                    color: _targetDate != null ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (_targetDate != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _targetDate = null), iconSize: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveGoal,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(_isEditing ? '更新する' : '目標を作成', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  void _selectDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (selectedDate != null) {
      setState(() => _targetDate = selectedDate);
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(goalSettingProvider.notifier);
    final goal = Goal(
      id: _isEditing ? widget.goal!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      reward: _rewardController.text.trim(),
      createdAt: _isEditing ? widget.goal!.createdAt : DateTime.now(),
      targetDate: _targetDate,
    );

    if (_isEditing) {
      viewModel.updateGoal(goal);
    } else {
      viewModel.addGoal(goal);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_isEditing ? '目標を更新しました！' : '新しい目標を作成しました！'), backgroundColor: Theme.of(context).colorScheme.primary));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を削除'),
        content: Text('「${widget.goal!.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              ref.read(goalSettingProvider.notifier).deleteGoal(widget.goal!.id);
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // フォーム画面を閉じる
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
