import 'package:flutter/cupertino.dart';
import '../models/set.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../services/journal_database.dart';

class SetService {
  final JournalDatabase _instance;

  SetService(this._instance);

  //CREATE
  Future<Set> createSet(Set set) async {
    final db = await _instance.database;
    final id = await db.insert(sets, set.toJson());
    return set.copy(id: id);
  }

  //READ
  Future<Set> readSetById(int id) async {
    final db = await _instance.database;
    final result = await db.query(
      sets,
      columns: SetFields.values,
      where: '${SetFields.id} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Set.fromJson(result.first);
    } else {
      throw Exception('Set with ID $id not found');
    }
  }

  Future<List<Set>?> readAllSets() async {
    final db = await _instance.database;
    final result = await db.query(
      sets,
    );
    if (result.isNotEmpty) {
      return result.map((json) => Set.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<List<Set>> readAllSetsByEntry(Entry entry) async {
    final db = await _instance.database;
    final result = await db.query(
      sets,
      where: '${SetFields.entryId} = ?',
      whereArgs: [entry.id],
    );
    if (result.isNotEmpty) {
      return result.map((json) => Set.fromJson(json)).toList();
    } else {
      throw Exception('Sets NOT FOUND for ${entry.toString()}');
    }
  }

  Future<List<int>> readListOfRepsFromSetsByEntry(Entry entry) async {
    List<Set> sets = await readAllSetsByEntry(entry);
    return sets.map((set) => set.reps).toList();
  }

  Future<List<double>> readListOfWeightsFromSetsByEntry(Entry entry) async {
    List<Set> sets = await readAllSetsByEntry(entry);
    return sets.map((set) => set.weight).toList();
  }

  Future<List<int>> readListOfRIRsFromSetsByEntry(Entry entry) async {
    List<Set> sets = await readAllSetsByEntry(entry);
    return sets.map((set) => set.rir).toList();
  }

  Future<List<Set>?> readAllSetsByExercise(Exercise exercise) async{
    final db = await _instance.database;
    final result = await db.query(
      sets,
      where: '${SetFields.exerciseId} = ?',
      whereArgs: [exercise.id],
    );
    if (result.isNotEmpty) {
      return result.map((json) => Set.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<Set> readBestSetByExercise(Exercise exercise) async{
    final db = await _instance.database;
    final result = await db.query(
      sets,
      where: '${SetFields.exerciseId} = ?',
      whereArgs: [exercise.id],
      orderBy: '${SetFields.oneRM} DESC',
      limit: 1,
    );
    return Set.fromJson(result.first);
  }

  Future<Set> readBestSetFromEntry(Entry entry) async {
    List<Set> sets = await readAllSetsByEntry(entry);
    double maxOneRM = 0;
    int bestId = 0;
    int id = 0;
    for (Set set in sets) {
      if (set.oneRM > maxOneRM) {
        maxOneRM = set.oneRM;
        bestId = id;
      }
      id++;
    }
    return sets.elementAt(bestId);
  }

  //DELETE
  Future<int> deleteSet(int id) async {
    final db = await _instance.database;
    final rowsDeleted = await db.delete(
      sets,
      where: '${SetFields.id} = ?',
      whereArgs: [id],
    );
    return rowsDeleted;
  }

  Future<int> deleteAllSetsByEntry(Entry entry) async {
    final db = await _instance.database;
    final rowsDeleted = await db.delete(
      sets,
      where: '${SetFields.entryId} = ?',
      whereArgs: [entry.id],
    );
    return rowsDeleted;
  }


  double calculateOneRM(double weight, int reps){
    if(repPercentages.containsKey(reps)){
      return weight / repPercentages[reps]!;
    } else {
      return weight * 2;
    }
  }

  static final Map<int, double> repPercentages = {
    1: 1.0,   2: 0.97,  3: 0.94,  4: 0.92,  5: 0.89,
    6: 0.86,  7: 0.83,  8: 0.81,  9: 0.78,  10: 0.75,
    11: 0.73, 12: 0.71, 13: 0.70, 14: 0.68, 15: 0.67,
    16: 0.65, 17: 0.64, 18: 0.63, 19: 0.61, 20: 0.60,
    21: 0.59, 22: 0.58, 23: 0.57, 24: 0.56, 25: 0.55,
    26: 0.54, 27: 0.53, 28: 0.52, 29: 0.51, 30: 0.50,
  };
}
