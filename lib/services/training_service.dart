import 'package:flutter/cupertino.dart';
import '../models/exercise_training_relation.dart';
import '../models/training.dart';
import '../services/journal_database.dart';

class TrainingService {
  final JournalDatabase _instance;

  TrainingService(this._instance);

  //CREATE
  Future<Training> createTraining(Training training) async {
    final db = await _instance.database;
    final id = await db.insert(trainings, training.toJson());
    return training.copy(id: id);
  }

  Future<ExerciseTrainingRelation> createExerciseTrainingRelation(ExerciseTrainingRelation exerciseTrainingRelation) async {
    final db = await _instance.database;
    final id = await db.insert(exercise_training_relations, exerciseTrainingRelation.toJson());
    return exerciseTrainingRelation.copy(id: id);
  }

  //READ
  Future<List<Training>?> readAllTrainings() async {
    final db = await _instance.database;
    final result = await db.query(
      trainings,
      orderBy: '${TrainingFields.name} ASC',
    );
    if(result.isNotEmpty){
      return result.map((json) => Training.fromJson(json)).toList();
    }
    else{
      return null;
    }
  }

  Future<Training> readTrainingById(int trainingId) async {
    final db = await _instance.database;
    final result = await db.query(
      trainings,
      where: '${TrainingFields.id} = ?',
      whereArgs: [trainingId],
    );
    if (result.isNotEmpty) {
      return Training.fromJson(result.first);
    } else {
      throw Exception('Training with ID $trainingId NOT FOUND!');
    }
  }

  Future<Training> readTrainingByName(String name) async {
    final db = await _instance.database;
    final result = await db.query(
      trainings,
      where: '${TrainingFields.name} = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Training.fromJson(result.first);
    } else {
      throw Exception('Training with name $name NOT FOUND!');
    }
  }

  //UPDATE
  Future<int> updateTraining(Training training) async {
    final db = await _instance.database;
    return await db.update(
      trainings,
      training.toJson(),
      where: '${TrainingFields.id} = ?',
      whereArgs: [training.id],
    );
  }

  //DELETE
  Future<int> deleteTraining(int trainingId) async {
    final db = await _instance.database;
    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');
    final rowsDeleted = await db.delete(
      trainings,
      where: '${TrainingFields.id} = ?',
      whereArgs: [trainingId],
    );
    return rowsDeleted;
  }
}
