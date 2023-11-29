import 'package:training_journal_app/models/exercise_training_relation.dart';
import 'package:training_journal_app/services/entry_service.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/entry.dart';
import '../models/training.dart';
import '../services/journal_database.dart';

class ExerciseService {
  final JournalDatabase _instance;

  ExerciseService(this._instance);

  //CREATE
  Future<Exercise> createExercise(Exercise exercise) async {
    final db = await _instance.database;
    final id = await db.insert(exercises, exercise.toJson());
    return exercise.copy(id: id);
  }

  //READ
  Future<Exercise> readExerciseById(int id) async {
      final db = await _instance.database;
      final result = await db.query(
        exercises,
        where: '${ExerciseFields.id} = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return Exercise.fromJson(result.first);
      } else {
        throw Exception('Exercise with ID $id not found');
      }
    }

  Future<List<Exercise>?> readAllExercises() async {
    final db = await _instance.database;
    final result = await db.query(
      exercises,
      orderBy: '${ExerciseFields.name} ASC',
    );
    if (result.isNotEmpty) {
      return result.map((json) => Exercise.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<List<Exercise>?> readAllExercisesByTraining(Training training) async {
    final db = await _instance.database;
    final result = await db.rawQuery('''
    SELECT e.*
    FROM $exercises e
    INNER JOIN $exercise_training_relations r
    ON e.${ExerciseFields.id} = r.${ExerciseTrainingRelationFields.exerciseId}
    WHERE r.${ExerciseTrainingRelationFields.trainingId} = ?
  ''', [training.id]);
    if (result.isNotEmpty) {
      return result.map((json) => Exercise.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<Exercise> readExerciseByName(String name) async {
    final db = await _instance.database;
    final result = await db.query(
      exercises,
      where: '${ExerciseFields.name} = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Exercise.fromJson(result.first);
    } else {
      throw Exception('Exercise with name $name not found');
    }
  }

  //UPDATE
  Future<void> updateExercise(Exercise exercise) async {
    final db = await _instance.database;
    await db.update(
      exercises,
      exercise.toJson(),
      where: '${ExerciseFields.id} = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> updateExerciseOneRM(int exerciseId) async {
    final db = await _instance.database;
    final result = await db.query(
      sets,
      where: '${SetFields.exerciseId} = ?',
      whereArgs: [exerciseId],
      orderBy: '${SetFields.oneRM} DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      Set maxOneRMSet = Set.fromJson(result.first);
      Entry entry = await EntryService(_instance).readEntryById(maxOneRMSet.entryId);
      final currentExercise = await readExerciseById(exerciseId);
      if (currentExercise.oneRM < maxOneRMSet.oneRM) {
        Exercise updatedExercise = Exercise(
            id: currentExercise.id,
            name: currentExercise.name,
            date: entry.date,
            weight: maxOneRMSet.weight,
            reps: maxOneRMSet.reps,
            oneRM: maxOneRMSet.oneRM
        );

        await updateExercise(updatedExercise);
      }
    }
  }

  //DELETE
  Future<int> deleteExercise(int id) async {
    final db = await _instance.database;

    final rowsDeleted = await db.delete(
      exercises,
      where: '${ExerciseFields.id} = ?',
      whereArgs: [id],
    );
    return rowsDeleted;
  }

  Future<void> deleteExerciseFromTraining(int exerciseId, int trainingId) async {
    final db = await _instance.database;
    await db.delete(
      exercise_training_relations,
      where: '${ExerciseTrainingRelationFields.exerciseId} = ? AND ${ExerciseTrainingRelationFields.trainingId} = ?',
      whereArgs: [exerciseId, trainingId],
    );
  }

}
