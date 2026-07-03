import 'package:flutter/cupertino.dart';
import 'package:training_journal_app/services/exercise_service.dart';

import '../models/entry.dart';
import '../services/journal_database.dart';
import '../models/exercise.dart';

class EntryService {
  final JournalDatabase _instance;
  EntryService(this._instance);

  //CREATE
  Future<Entry> createEntry(Entry entry) async {
    final db = await _instance.database;
    final id = await db.insert(entries, entry.toJson());
    return entry.copy(id: id);
  }

  //READ
  Future<List<Entry>?> readAllEntries() async {
    final db = await _instance.database;
    final result = await db.query(
        entries,
        orderBy: '${EntryFields.date} DESC'
    );
    if (result.isNotEmpty) {
      return result.map((json) => Entry.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<Entry> readEntryById(int id) async {
    final db = await _instance.database;
    final result = await db.query(
      entries,
      columns: EntryFields.values,
      where: '${EntryFields.id} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Entry.fromJson(result.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Entry>?> readAllEntriesByExercise(Exercise exercise) async {
    final db = await _instance.database;
    final result = await db.query(
        entries,
        where: '${EntryFields.exerciseId} = ?',
        whereArgs: [exercise.id],
        orderBy: '${EntryFields.date} DESC'
    );
    if (result.isNotEmpty) {
      return result.map((json) => Entry.fromJson(json)).toList();
    } else {
      debugPrint('Entries NOT FOUND for ${exercise.toString()}');
      return null;
    }
  }

  Future<List<Entry>?> readLastEntriesByExercise(Exercise exercise) async {
    final db = await _instance.database;
    final result = await db.query(
      entries,
      where: '${EntryFields.exerciseId} = ?',
      whereArgs: [exercise.id],
      orderBy: '${EntryFields.date} DESC',
      limit: 7,
    );
    if (result.isNotEmpty) {
      return result.map((json) => Entry.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  //UPDATE
  Future<void> updateEntry(Entry entry) async {
    final db = await _instance.database;
    await db.update(
        entries,
        entry.toJson(),
        where: '${EntryFields.id} = ?',
        whereArgs: [entry.id],
    );
  }

  //DELETE
  Future<int> deleteEntry(int id) async {
    final db = await _instance.database;
    final deletedEntry = await readEntryById(id);
    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');
    final rowsDeleted = await db.delete(
      entries,
      where: '${EntryFields.id} = ?',
      whereArgs: [id],
    );
    await ExerciseService(_instance).updateExerciseOneRM(deletedEntry.exerciseId);
    return rowsDeleted;
  }


}
