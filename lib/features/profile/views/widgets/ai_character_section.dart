import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_profile.dart';

class AICharacterSection extends ConsumerWidget {
  final UserProfile profile;

  const AICharacterSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('AIキャラクター設定', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('あなたの好みに合わせてAIの性格を選んでね！', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),

            // AIキャラクター選択
            ...AICharacter.values.map((character) => _buildCharacterCard(context, ref, character, profile.selectedAICharacter == character)),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, WidgetRef ref, AICharacter character, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          ref.read(profileViewModelProvider.notifier).updateAICharacter(character);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 選択状態のインジケーター
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[400]!, width: 2),
                ),
                child: isSelected ? Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.onPrimary) : null,
              ),
              const SizedBox(width: 16),

              // キャラクター絵文字
              Text(character.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),

              // キャラクター情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(character.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),

              // 選択状態の矢印
              if (isSelected) Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
