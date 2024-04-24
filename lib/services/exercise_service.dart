import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/exercise_training_relation.dart';
import '../services/entry_service.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/entry.dart';
import '../models/training.dart';
import '../services/journal_database.dart';
import 'set_service.dart';

class ExerciseService {
  final JournalDatabase _instance;

  ExerciseService(this._instance);

  //CREATE
  Future<Exercise> createExercise(Exercise exercise) async {
    final db = await _instance.database;
    final id = await db.insert(exercises, exercise.toJson());
    return exercise.copy(id: id);
  }

  Future<Exercise> createExerciseWithManuallyEnteredId(Exercise exercise) async {
    final db = await _instance.database;
    await db.insert(
      exercises,
      exercise.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return exercise;
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

  Future<Exercise?> readExerciseByIdDebug(int id) async {
    final db = await _instance.database;
    final result = await db.query(
      exercises,
      where: '${ExerciseFields.id} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Exercise.fromJson(result.first);
    } else {
      debugPrint('Exercise with ID $id not found');
      return null;
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
    debugPrint("UPDATING EXERCISE!");
    debugPrint(exercise.toString());

    // Pobierz wszystkie wpisy dla danego ćwiczenia
    final exerciseEntries = await EntryService(_instance).readAllEntriesByExercise(exercise);
    if(exerciseEntries != null) {
      // Wypisz wpisy
      for (final entry in exerciseEntries) {
        debugPrint(entry.toString());

        // Pobierz wszystkie sety dla danego wpisu
        final entrySets = await SetService(_instance).readAllSetsByEntry(entry);
        for (final set in entrySets) {
          debugPrint(set.toString());
        }

      }
    }
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
      if (currentExercise.oneRM != maxOneRMSet.oneRM || currentExercise.reps != maxOneRMSet.reps) {
        Exercise updatedExercise = Exercise(
            id: currentExercise.id,
            name: currentExercise.name,
            date: entry.date,
            weight: maxOneRMSet.weight,
            reps: maxOneRMSet.reps,
            oneRM: maxOneRMSet.oneRM,
            notes: currentExercise.notes
        );

        await updateExercise(updatedExercise);
      }
    }
    else{
      final currentExercise = await readExerciseById(exerciseId);
      Exercise updatedExercise = Exercise(
          id: currentExercise.id,
          name: currentExercise.name,
          date: currentExercise.date,
          weight: 0.0,
          reps: 0,
          oneRM: 0.0,
          notes: currentExercise.notes
      );

      await updateExercise(updatedExercise);
    }
  }

  //DELETE
  Future<int> deleteExercise(int id) async {
    final db = await _instance.database;
    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');
    debugPrint("DELETING EXERCISE!");
    final rowsDeleted = await db.delete(
      exercises,
      where: '${ExerciseFields.id} = ?',
      whereArgs: [id],
    );
    return rowsDeleted;
  }

  Future<void> deleteExerciseFromTraining(int exerciseId, int trainingId) async {
    final db = await _instance.database;
    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');
    await db.delete(
      exercise_training_relations,
      where: '${ExerciseTrainingRelationFields.exerciseId} = ? AND ${ExerciseTrainingRelationFields.trainingId} = ?',
      whereArgs: [exerciseId, trainingId],
    );
  }

}
