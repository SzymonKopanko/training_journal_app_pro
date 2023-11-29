import '../models/training.dart';
import '../models/training_weekly_plan_relation.dart';
import '../services/journal_database.dart';

class TrainingService {
  final JournalDatabase _instance;

  TrainingService() : _instance = JournalDatabase.instance;

  //CREATE
  Future<Training> createTraining(Training training) async {
    final db = await _instance.database;
    final id = await db.insert(trainings, training.toJson());
    return training.copy(id: id);
  }

  //READ
  Future<List<Training>?> readAllTrainings() async {
    final db = await _instance.database;
    final result = await db.query(
      trainings,
    );
    if(result.isNotEmpty){
      return result.map((json) => Training.fromJson(json)).toList();
    }
    else{
      return null;
    }
  }

  Future<List<Training>?> readAllTrainingsByWeeklyPlanForACertainDay(
      int weeklyPlanId, int day) async {
    final db = await _instance.database;

    final result = await db.rawQuery('''
      SELECT t.*
      FROM $trainings t
      INNER JOIN $training_weekly_plan_relations r
      ON t.${TrainingFields.id} = r.${TrainingWeeklyPlanRelationFields.trainingId}
      WHERE r.${TrainingWeeklyPlanRelationFields.weeklyPlanId} = ?
      AND r.${TrainingWeeklyPlanRelationFields.day} = ?
    ''', [weeklyPlanId, day]);
    if(result.isNotEmpty){
      return result.map((json) => Training.fromJson(json)).toList();
    }
    else{
      return null;
    }
  }

  //Update
  Future<int> updateTrainingName(int trainingId, String newName) async {
    final db = await _instance.database;
    return await db.update(
      trainings,
      {TrainingFields.name: newName},
      where: '${TrainingFields.id} = ?',
      whereArgs: [trainingId],
    );
  }

  Future<int> deleteTraining(int trainingId) async {
    final db = await _instance.database;
    final rowsDeleted = await db.delete(
      trainings,
      where: '${TrainingFields.id} = ?',
      whereArgs: [trainingId],
    );
    return rowsDeleted;
  }

  Future<void> deleteTrainingFromWeeklyPlanOnACertainDay(
      int trainingId, int weeklyPlanId, int day) async {
    final db = await _instance.database;

    await db.delete(
      training_weekly_plan_relations,
      where:
          '${TrainingWeeklyPlanRelationFields.trainingId} = ? AND ${TrainingWeeklyPlanRelationFields.weeklyPlanId} = ? AND ${TrainingWeeklyPlanRelationFields.day} = ?',
      whereArgs: [trainingId, weeklyPlanId, day],
    );
  }
}
