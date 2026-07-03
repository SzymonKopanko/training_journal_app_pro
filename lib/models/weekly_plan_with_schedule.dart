import '../models/training.dart';
import '../models/weekly_plan.dart';

class WeeklyPlanWithSchedule {
  final WeeklyPlan plan;
  final Map<int, Training?> trainingByDay;

  const WeeklyPlanWithSchedule({
    required this.plan,
    required this.trainingByDay,
  });
}
