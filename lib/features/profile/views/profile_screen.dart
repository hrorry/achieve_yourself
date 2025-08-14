import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/user_profile.dart';
import 'widgets/user_info_section.dart';
import 'widgets/ai_character_section.dart';
import 'widgets/ai_service_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(profileViewModelProvider.notifier).refresh())],
      ),
      body: profileState.when(
        data: (profile) => profile == null ? const Center(child: Text('プロフィールが見つかりません')) : _buildProfileContent(context, ref, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラーが発生しました: $error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.read(profileViewModelProvider.notifier).refresh(), child: const Text('再試行')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダーセクション
          _buildHeaderSection(context, profile),
          const SizedBox(height: 24),

          // ユーザー情報セクション
          UserInfoSection(profile: profile),
          const SizedBox(height: 24),

          // AIキャラクター設定セクション
          AICharacterSection(profile: profile),
          const SizedBox(height: 24),

          // AIサービス設定セクション
          AIServiceSection(profile: profile),
          const SizedBox(height: 24),

          // 保存ボタン
          _buildSaveButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: profile.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        profile.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  : Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (profile.email != null) ...[
                    const SizedBox(height: 4),
                    Text(profile.email!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                  if (profile.bio != null) ...[const SizedBox(height: 8), Text(profile.bio!, style: Theme.of(context).textTheme.bodyMedium)],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 保存処理は各セクション内で行われるため、ここでは成功メッセージを表示
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('設定を保存しました！'), backgroundColor: Colors.green));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('設定を保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
