import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/training_notification.dart';

final localNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

class NotificationsNotifier extends AsyncNotifier<List<TrainingNotification>> {
  @override
  Future<List<TrainingNotification>> build() => _load();

  Future<List<TrainingNotification>> _load() async {
    final plugin = ref.read(localNotificationsPluginProvider);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await plugin.initialize(initSettings);
    plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final pending = await plugin.pendingNotificationRequests();
    return pending
        .map(TrainingNotification.fromNotificationRequest)
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> cancelNotification(int id) async {
    await ref.read(localNotificationsPluginProvider).cancel(id);
    await refresh();
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<TrainingNotification>>(
  NotificationsNotifier.new,
);
