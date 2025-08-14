import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_profile.dart';

class AIServiceSection extends ConsumerStatefulWidget {
  final UserProfile profile;

  const AIServiceSection({super.key, required this.profile});

  @override
  ConsumerState<AIServiceSection> createState() => _AIServiceSectionState();
}

class _AIServiceSectionState extends ConsumerState<AIServiceSection> {
  late TextEditingController _apiKeyController;
  bool _isApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.profile.apiKey ?? '');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.api, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('AIサービス設定', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '使用したいAIサービスを選択してAPIキーを設定してください',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // AIサービス選択
            Text('AIサービス', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            ...AIService.values.map((service) => _buildServiceCard(context, ref, service, widget.profile.selectedAIService == service)),

            const SizedBox(height: 20),

            // APIキー入力
            _buildApiKeySection(context, ref),

            const SizedBox(height: 16),

            // ヘルプ情報
            _buildHelpSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, WidgetRef ref, AIService service, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          ref.read(profileViewModelProvider.notifier).updateAIService(service);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 選択状態のインジケーター
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[400]!, width: 2),
                ),
                child: isSelected ? Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary) : null,
              ),
              const SizedBox(width: 16),

              // サービスアイコン
              Icon(service == AIService.openai ? Icons.chat : Icons.psychology, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),

              // サービス情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(service.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('APIキー', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          obscureText: !_isApiKeyVisible,
          onChanged: (value) {
            ref.read(profileViewModelProvider.notifier).updateAPIKey(value);
          },
          decoration: InputDecoration(
            hintText: 'sk-... または AIza...',
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(_isApiKeyVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isApiKeyVisible = !_isApiKeyVisible;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('APIキーの取得方法', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• OpenAI: https://platform.openai.com/api-keys\n'
            '• Google Gemini: https://makersuite.google.com/app/apikey',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '※ APIキーは安全に保存され、外部に送信されることはありません',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
