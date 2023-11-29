import '../models/weekly_plan.dart';
import '../services/journal_database.dart';

class WeeklyPlanService{
  final JournalDatabase instance;

  WeeklyPlanService(this.instance);

  //CREATE
  Future<WeeklyPlan> createWeeklyPlan(WeeklyPlan weeklyPlan) async {
    final db = await instance.database;

    final id = await db.insert(weekly_plans, weeklyPlan.toJson());
    return weeklyPlan.copy(id: id);
  }

  //READ
  Future<List<WeeklyPlan>?> readAllWeeklyPlans() async {
    final db = await instance.database;
    final result = await db.query(
      weekly_plans,
    );
    if(result.isNotEmpty){
      return result.map((json) => WeeklyPlan.fromJson(json)).toList();
    }
    else{
      return null;
    }
  }

  //UPDATE
  Future<int> updateWeeklyPlanName(int weeklyPlanId, String newName) async {
    final db = await instance.database;
    return await db.update(
      weekly_plans,
      {'name': newName},
      where: '${WeeklyPlanFields.id} = ?',
      whereArgs: [weeklyPlanId],
    );
  }

  //DELETE
  Future<int> deleteWeeklyPlan(int weeklyPlanId) async {
    final db = await instance.database;
    return await db.delete(
      weekly_plans,
      where: '${WeeklyPlanFields.id} = ?',
      whereArgs: [weeklyPlanId],
    );
  }
}