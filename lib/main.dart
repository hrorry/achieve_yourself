import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/goal_setting/views/goal_setting_screen.dart';
import 'features/goal_setting/models/goal.dart';
import 'features/profile/views/profile_screen.dart';
import 'features/notification/views/notification_settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achieve Yourself',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = 'ホリウチ';
  final List<Goal> goals = [
    Goal(
      id: '1',
      title: '夏までに10kg痩せる',
      description: '健康的なダイエットで理想の体型を目指す',
      type: GoalType.diet,
      progress: 0.6,
      reward: '🥇 ダイエットバッジ',
      actions: ['朝ごはんの写真を送ろう', '10分ストレッチしよう', 'AIからのアドバイス: 今日は水分多めにとろう！'],
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
      actions: ['単語帳を30分やろう', 'リスニング問題を解こう', 'AIからのアドバイス: 毎日少しずつ続けよう！'],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      targetDate: DateTime.now().add(const Duration(days: 180)),
    ),
  ];

  int _currentGoal = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Goal currentGoal = goals[_currentGoal];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achieve Yourself'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => _navigateToProfile(context)),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _navigateToGoalSetting(context)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('こんにちは、$userNameさん！🎉', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: goals.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentGoal = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(goal.type.emoji, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(width: 8),
                                      const Text('現在の目標', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      goal.title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🏅 ご褒美', style: TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      goal.reward,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  goals.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _currentGoal == index ? Theme.of(context).colorScheme.primary : Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('進捗', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: currentGoal.progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(currentGoal.progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(currentGoal.progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentGoal.progress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('今日のアクション', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentGoal.actions.length,
                  itemBuilder: (context, index) {
                    final action = currentGoal.actions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
                        title: Text(action),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat),
                      label: const Text('AIチャット'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToGoalSetting(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('目標編集'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToNotificationSettings(context),
                      icon: const Icon(Icons.notifications),
                      label: const Text('通知設定'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGoalSetting(BuildContext context) {
    // 現在選択されている目標のIDを渡す
    final currentGoalId = goals[_currentGoal].id;
    Navigator.push(context, MaterialPageRoute(builder: (context) => GoalSettingScreen(selectedGoalId: currentGoalId)));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _navigateToNotificationSettings(BuildContext context) {
    // 現在選択されている目標のIDを渡す
    final currentGoalId = goals[_currentGoal].id;
    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsScreen(selectedGoalId: currentGoalId)));
  }
}
