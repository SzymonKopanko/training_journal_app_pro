import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/training_notification.dart';
import '../providers/notifications_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bar_add_action.dart';
import 'add_notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  void _openAddNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNotificationScreen()),
    ).then((_) => ref.read(notificationsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          AppBarAddAction(
            tooltip: l10n.notificationsAdd,
            onPressed: _openAddNotification,
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.notificationsLoadError)),
        data: (notifications) => _buildNotificationsList(notifications),
      ),
    );
  }

  Widget _buildNotificationsList(List<TrainingNotification> notifications) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screen,
      children: List.generate(7, (index) {
        final dayNotifications =
            notifications.where((n) => n.day == index + 1).toList();
        final dayName = _getDayName(l10n, index + 1);

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(dayName, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (dayNotifications.isNotEmpty)
                Column(
                  children: dayNotifications.map((notification) {
                    return ListTile(
                      title: Text(
                          l10n.notificationTraining(notification.trainingName)),
                      subtitle: Text(l10n.notificationTime(
                          notification.time.format(context))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: l10n.commonDelete,
                        onPressed: () => ref
                            .read(notificationsProvider.notifier)
                            .cancelNotification(notification.id),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _getDayName(AppLocalizations l10n, int day) {
    switch (day) {
      case 1:
        return l10n.dayMonday;
      case 2:
        return l10n.dayTuesday;
      case 3:
        return l10n.dayWednesday;
      case 4:
        return l10n.dayThursday;
      case 5:
        return l10n.dayFriday;
      case 6:
        return l10n.daySaturday;
      case 7:
        return l10n.daySunday;
      default:
        return '';
    }
  }
}
