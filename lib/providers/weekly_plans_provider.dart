import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weekly_plan_with_schedule.dart';
import 'database_providers.dart';

class WeeklyPlansNotifier extends AsyncNotifier<List<WeeklyPlanWithSchedule>> {
  @override
  Future<List<WeeklyPlanWithSchedule>> build() => _load();

  Future<List<WeeklyPlanWithSchedule>> _load() async {
    return ref.read(weeklyPlanServiceProvider).readAllWeeklyPlansWithSchedule();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> deleteWeeklyPlan(int id) async {
    await ref.read(weeklyPlanServiceProvider).deleteWeeklyPlan(id);
    await refresh();
  }
}

final weeklyPlansProvider =
    AsyncNotifierProvider<WeeklyPlansNotifier, List<WeeklyPlanWithSchedule>>(
  WeeklyPlansNotifier.new,
);
