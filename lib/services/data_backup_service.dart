import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/body_entry.dart';
import '../models/body_part.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/exercise_body_part_relation.dart';
import '../models/exercise_training_relation.dart';
import '../models/set.dart';
import '../models/training.dart';
import 'journal_database.dart';

/// Eksport/import całej bazy danych do formatu JSON.
class DataBackupService {
  DataBackupService(this._database);

  final JournalDatabase _database;

  static const exportFormatVersion = 2;
  static const requiredKeys = [
    'formatVersion',
    'exportedAt',
    'bodyParts',
    'exercises',
    'exerciseBodyPartRelations',
    'trainings',
    'exerciseTrainingRelations',
    'entries',
    'sets',
    'bodyEntries',
  ];

  Future<Map<String, dynamic>> exportToMap() async {
    final db = await _database.database;
    return {
      'formatVersion': exportFormatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'bodyParts': await db.query(body_parts),
      'exercises': await db.query(exercises),
      'exerciseBodyPartRelations': await db.query(exercise_body_part_relations),
      'trainings': await db.query(trainings),
      'exerciseTrainingRelations': await db.query(exercise_training_relations),
      'entries': await db.query(entries),
      'sets': await db.query(sets),
      'bodyEntries': await db.query(body_entries),
    };
  }

  Future<String> exportToJson() async {
    return const JsonEncoder.withIndent('  ').convert(await exportToMap());
  }

  void _validateImportMap(Map<String, dynamic> data) {
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        throw FormatException('Missing key: $key');
      }
    }
    final version = data['formatVersion'];
    if (version is! int || version > exportFormatVersion) {
      throw FormatException('Unsupported format version: $version');
    }
    for (final key in requiredKeys.skip(2)) {
      if (data[key] is! List) {
        throw FormatException('Key $key must be a list');
      }
    }
  }

  Future<void> importFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Root JSON must be an object');
    }
    _validateImportMap(decoded);
    await _importRows(decoded);
  }

  Future<void> _importRows(Map<String, dynamic> data) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await _insertAll(
        txn,
        body_parts,
        data['bodyParts'] as List,
      );
      await _insertAll(
        txn,
        exercises,
        data['exercises'] as List,
      );
      await _insertAll(
        txn,
        trainings,
        data['trainings'] as List,
      );
      await _insertAll(
        txn,
        exercise_body_part_relations,
        data['exerciseBodyPartRelations'] as List,
      );
      await _insertAll(
        txn,
        exercise_training_relations,
        data['exerciseTrainingRelations'] as List,
      );
      await _insertAll(
        txn,
        entries,
        data['entries'] as List,
      );
      await _insertAll(
        txn,
        sets,
        data['sets'] as List,
      );
      await _insertAll(
        txn,
        body_entries,
        data['bodyEntries'] as List,
      );
    });
  }

  Future<void> _insertAll(
    Transaction txn,
    String table,
    List<dynamic> rows,
  ) async {
    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('Invalid row in $table');
      }
      await txn.insert(
        table,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
