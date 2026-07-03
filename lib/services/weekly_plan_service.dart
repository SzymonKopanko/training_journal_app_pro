import '../models/training.dart';
import '../models/training_weekly_plan_relation.dart';
import '../models/weekly_plan.dart';
import '../models/weekly_plan_with_schedule.dart';
import 'journal_database.dart';
import 'training_service.dart';

class WeeklyPlanService {
  WeeklyPlanService(this._instance);

  final JournalDatabase _instance;

  Future<WeeklyPlan> createWeeklyPlan(WeeklyPlan plan) async {
    final db = await _instance.database;
    final id = await db.insert(weekly_plans, plan.toJson());
    return plan.copy(id: id);
  }

  Future<List<WeeklyPlan>> readAllWeeklyPlans() async {
    final db = await _instance.database;
    final result = await db.query(
      weekly_plans,
      orderBy: '${WeeklyPlanFields.name} ASC',
    );
    return result.map((json) => WeeklyPlan.fromJson(json)).toList();
  }

  Future<WeeklyPlanWithSchedule> readWeeklyPlanWithSchedule(int planId) async {
    final db = await _instance.database;
    final planRows = await db.query(
      weekly_plans,
      where: '${WeeklyPlanFields.id} = ?',
      whereArgs: [planId],
    );
    if (planRows.isEmpty) {
      throw Exception('Weekly plan $planId not found');
    }
    final plan = WeeklyPlan.fromJson(planRows.first);
    final relationRows = await db.query(
      training_weekly_plan_relations,
      where: '${TrainingWeeklyPlanRelationFields.weeklyPlanId} = ?',
      whereArgs: [planId],
    );

    final trainingService = TrainingService(_instance);
    final schedule = <int, Training?>{for (var d = 1; d <= 7; d++) d: null};

    for (final row in relationRows) {
      final relation = TrainingWeeklyPlanRelation.fromJson(row);
      schedule[relation.dayOfWeek] =
          await trainingService.readTrainingById(relation.trainingId);
    }

    return WeeklyPlanWithSchedule(plan: plan, trainingByDay: schedule);
  }

  Future<List<WeeklyPlanWithSchedule>> readAllWeeklyPlansWithSchedule() async {
    final plans = await readAllWeeklyPlans();
    final result = <WeeklyPlanWithSchedule>[];
    for (final plan in plans) {
      result.add(await readWeeklyPlanWithSchedule(plan.id!));
    }
    return result;
  }

  Future<void> saveSchedule({
    required int weeklyPlanId,
    required Map<int, int?> trainingIdByDay,
  }) async {
    final db = await _instance.database;
    await db.delete(
      training_weekly_plan_relations,
      where: '${TrainingWeeklyPlanRelationFields.weeklyPlanId} = ?',
      whereArgs: [weeklyPlanId],
    );

    for (final entry in trainingIdByDay.entries) {
      final trainingId = entry.value;
      if (trainingId == null) continue;
      await db.insert(
        training_weekly_plan_relations,
        TrainingWeeklyPlanRelation(
          weeklyPlanId: weeklyPlanId,
          trainingId: trainingId,
          dayOfWeek: entry.key,
        ).toJson(),
      );
    }
  }

  Future<int> updateWeeklyPlan(WeeklyPlan plan) async {
    final db = await _instance.database;
    return db.update(
      weekly_plans,
      plan.toJson(),
      where: '${WeeklyPlanFields.id} = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deleteWeeklyPlan(int planId) async {
    final db = await _instance.database;
    await db.delete(
      training_weekly_plan_relations,
      where: '${TrainingWeeklyPlanRelationFields.weeklyPlanId} = ?',
      whereArgs: [planId],
    );
    return db.delete(
      weekly_plans,
      where: '${WeeklyPlanFields.id} = ?',
      whereArgs: [planId],
    );
  }
}
