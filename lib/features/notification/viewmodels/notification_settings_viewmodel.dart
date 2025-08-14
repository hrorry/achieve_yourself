import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../../goal_setting/models/goal.dart';

class NotificationSettingsViewModel extends StateNotifier<AsyncValue<List<NotificationSettings>>> {
  NotificationSettingsViewModel() : super(const AsyncValue.loading()) {
    _loadNotificationSettings();
  }

  List<NotificationSettings> get settings => state.value ?? [];
  bool get isLoading => state.isLoading;
  String? get error => state.error?.toString();

  Future<void> _loadNotificationSettings() async {
    try {
      state = const AsyncValue.loading();

      // TODO: 実際のデータベースから読み込み
      // 仮のデータを作成
      await Future.delayed(const Duration(milliseconds: 500));
      final settings = [
        NotificationSettings(
          id: '1',
          goalId: '1',
          isEnabled: true,
          reminderTimes: [NotificationTime(hour: 8, minute: 0), NotificationTime(hour: 20, minute: 0)],
          type: NotificationType.daily,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now(),
        ),
        NotificationSettings(
          id: '2',
          goalId: '2',
          isEnabled: true,
          reminderTimes: [NotificationTime(hour: 19, minute: 30)],
          type: NotificationType.daily,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          updatedAt: DateTime.now(),
        ),
      ];

      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final currentSettings = state.value ?? [];
      final index = currentSettings.indexWhere((s) => s.id == settings.id);

      if (index != -1) {
        final updatedSettings = List<NotificationSettings>.from(currentSettings);
        updatedSettings[index] = settings.copyWith(updatedAt: DateTime.now());
        state = AsyncValue.data(updatedSettings);
      }

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleNotification(String settingsId, bool isEnabled) async {
    try {
      final currentSettings = state.value ?? [];
      final index = currentSettings.indexWhere((s) => s.id == settingsId);

      if (index != -1) {
        final updatedSettings = List<NotificationSettings>.from(currentSettings);
        updatedSettings[index] = updatedSettings[index].copyWith(isEnabled: isEnabled, updatedAt: DateTime.now());
        state = AsyncValue.data(updatedSettings);
      }

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addReminderTime(String settingsId, NotificationTime time) async {
    try {
      final currentSettings = state.value ?? [];
      final index = currentSettings.indexWhere((s) => s.id == settingsId);

      if (index != -1) {
        final currentSetting = currentSettings[index];
        final updatedReminderTimes = List<NotificationTime>.from(currentSetting.reminderTimes)..add(time);

        final updatedSettings = List<NotificationSettings>.from(currentSettings);
        updatedSettings[index] = currentSetting.copyWith(reminderTimes: updatedReminderTimes, updatedAt: DateTime.now());
        state = AsyncValue.data(updatedSettings);
      }

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> removeReminderTime(String settingsId, int timeIndex) async {
    try {
      final currentSettings = state.value ?? [];
      final index = currentSettings.indexWhere((s) => s.id == settingsId);

      if (index != -1) {
        final currentSetting = currentSettings[index];
        final updatedReminderTimes = List<NotificationTime>.from(currentSetting.reminderTimes);
        if (timeIndex < updatedReminderTimes.length) {
          updatedReminderTimes.removeAt(timeIndex);
        }

        final updatedSettings = List<NotificationSettings>.from(currentSettings);
        updatedSettings[index] = currentSetting.copyWith(reminderTimes: updatedReminderTimes, updatedAt: DateTime.now());
        state = AsyncValue.data(updatedSettings);
      }

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateNotificationType(String settingsId, NotificationType type) async {
    try {
      final currentSettings = state.value ?? [];
      final index = currentSettings.indexWhere((s) => s.id == settingsId);

      if (index != -1) {
        final updatedSettings = List<NotificationSettings>.from(currentSettings);
        updatedSettings[index] = updatedSettings[index].copyWith(type: type, updatedAt: DateTime.now());
        state = AsyncValue.data(updatedSettings);
      }

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createNotificationSettings(String goalId) async {
    try {
      final currentSettings = state.value ?? [];

      // 既に存在するかチェック
      final existingIndex = currentSettings.indexWhere((s) => s.goalId == goalId);
      if (existingIndex != -1) return; // 既に存在する場合は何もしない

      final newSettings = NotificationSettings(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: goalId,
        isEnabled: true,
        reminderTimes: [],
        type: NotificationType.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedSettings = List<NotificationSettings>.from(currentSettings)..add(newSettings);
      state = AsyncValue.data(updatedSettings);

      // TODO: 実際のデータベースに保存
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await _loadNotificationSettings();
  }
}

final notificationSettingsViewModelProvider = StateNotifierProvider<NotificationSettingsViewModel, AsyncValue<List<NotificationSettings>>>(
  (ref) => NotificationSettingsViewModel(),
);
