import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/user_profile.dart';

class UserInfoSection extends ConsumerStatefulWidget {
  final UserProfile profile;

  const UserInfoSection({super.key, required this.profile});

  @override
  ConsumerState<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends ConsumerState<UserInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('ユーザー情報', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // 名前入力
            _buildTextField(
              controller: _nameController,
              label: '名前',
              hint: 'あなたの名前を入力してください',
              icon: Icons.person_outline,
              onChanged: (value) => _saveUserInfo(),
            ),
            const SizedBox(height: 16),

            // メールアドレス入力
            _buildTextField(
              controller: _emailController,
              label: 'メールアドレス',
              hint: 'example@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _saveUserInfo(),
            ),
            const SizedBox(height: 16),

            // 自己紹介入力
            _buildTextField(
              controller: _bioController,
              label: '自己紹介',
              hint: 'あなたについて教えてください',
              icon: Icons.description_outlined,
              maxLines: 3,
              onChanged: (value) => _saveUserInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  void _saveUserInfo() {
    ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        );
  }
}
