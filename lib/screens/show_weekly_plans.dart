import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/weekly_plan_with_schedule.dart';
import '../providers/weekly_plans_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_bar_add_action.dart';
import '../widgets/app_list_card.dart';
import 'weekly_plan_form_screen.dart';

class ShowWeeklyPlansScreen extends ConsumerWidget {
  const ShowWeeklyPlansScreen({super.key});

  String _dayName(AppLocalizations l10n, int day) {
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

  String _scheduleSummary(
    AppLocalizations l10n,
    WeeklyPlanWithSchedule item,
  ) {
    final parts = <String>[];
    for (var day = 1; day <= 7; day++) {
      final training = item.trainingByDay[day];
      if (training != null) {
        parts.add('${_dayName(l10n, day)}: ${training.name}');
      }
    }
    if (parts.isEmpty) return l10n.weeklyPlanNoTrainings;
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plansAsync = ref.watch(weeklyPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weeklyPlansTitle),
        actions: [
          AppBarAddAction(
            tooltip: l10n.weeklyPlansAdd,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyPlanFormScreen(),
                ),
              ).then((_) =>
                  ref.read(weeklyPlansProvider.notifier).refresh());
            },
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.weeklyPlansLoadError)),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(child: Text(l10n.weeklyPlansEmpty));
          }
          return ListView.builder(
            padding: AppSpacing.screen,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final item = plans[index];
              return AppListCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.plan.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      _scheduleSummary(l10n, item),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppSpacing.gapSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: l10n.commonEdit,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeeklyPlanFormScreen(
                                  existingPlan: item,
                                ),
                              ),
                            ).then((_) => ref
                                .read(weeklyPlansProvider.notifier)
                                .refresh());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: l10n.commonDelete,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.weeklyPlanDeleteTitle),
                                content: Text(l10n.weeklyPlanDeleteBody),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.commonCancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              weeklyPlansProvider.notifier)
                                          .deleteWeeklyPlan(item.plan.id!);
                                      Navigator.pop(context);
                                    },
                                    child: Text(l10n.commonDelete),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
