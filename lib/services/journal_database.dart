import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:training_journal_app/services/exercise_service.dart';
import '../models/body_entry.dart';
import '../models/exercise_body_part_relation.dart';
import '../models/exercise_training_relation.dart';
import '../models/set.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/training.dart';
import '../models/body_part.dart';
import 'body_part_service.dart';

class JournalDatabase {

  static final JournalDatabase instance = JournalDatabase._init();
  static Database? _database;

  JournalDatabase._init();


  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'training.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> printPath() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'training.db');
    debugPrint('Database path: $path');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDB() async {
    if (Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
    }
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'training.db');
    await deleteDatabase(path);
    _database = null;
  }

  Future _createDB(Database db, int version) async {
    print("\n\nWywołałem _createDB!!!!!!!!!!!!\n\n");
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textTypeNotNull = 'TEXT NOT NULL';
    const integerTypeNotNull = 'INTEGER NOT NULL';
    const realTypeNotNull = 'REAL NOT NULL';
    const integerType = 'INTEGER';

    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');

    await db.execute('''
      CREATE TABLE $trainings (
      ${TrainingFields.id} $idType,
      ${TrainingFields.name} $textTypeNotNull UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $body_entries (
      ${BodyEntryFields.id} $idType,
      ${BodyEntryFields.dateTime} $integerTypeNotNull,
      ${BodyEntryFields.weight} $realTypeNotNull
      )
    ''');

    await db.execute('''
      CREATE TABLE $exercises (
      ${ExerciseFields.id} $idType,
      ${ExerciseFields.name} $textTypeNotNull UNIQUE,
      ${ExerciseFields.date} $textTypeNotNull,
      ${ExerciseFields.weight} $realTypeNotNull,
      ${ExerciseFields.reps} $integerTypeNotNull,
      ${ExerciseFields.oneRM} $realTypeNotNull,
      ${ExerciseFields.notes} $textTypeNotNull,
      ${ExerciseFields.restTime} $integerType,
      ${ExerciseFields.bodyweightPercentage} $integerType
      )
    ''');


    await db.execute('''
      CREATE TABLE $body_parts (
      ${BodyPartFields.id} $idType,
      ${BodyPartFields.name} $textTypeNotNull UNIQUE
      )''');


    await db.execute('''
      CREATE TABLE $exercise_body_part_relations (
      ${ExerciseBodyPartRelationFields.id} $idType,
      ${ExerciseBodyPartRelationFields.exerciseId} $integerTypeNotNull,
      ${ExerciseBodyPartRelationFields.bodyPartId} $integerTypeNotNull,
      FOREIGN KEY (${ExerciseBodyPartRelationFields.exerciseId})
        REFERENCES $exercises(${ExerciseFields.id})
          ON DELETE CASCADE,
      FOREIGN KEY (${ExerciseBodyPartRelationFields.bodyPartId})
        REFERENCES $trainings(${BodyPartFields.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $exercise_training_relations (
      ${ExerciseTrainingRelationFields.id} $idType,
      ${ExerciseTrainingRelationFields.exerciseId} $integerTypeNotNull,
      ${ExerciseTrainingRelationFields.trainingId} $integerTypeNotNull,
      ${ExerciseTrainingRelationFields.placement} $integerTypeNotNull,
      FOREIGN KEY (${ExerciseTrainingRelationFields.exerciseId})
        REFERENCES $exercises(${ExerciseFields.id})
          ON DELETE CASCADE,
      FOREIGN KEY (${ExerciseTrainingRelationFields.trainingId})
        REFERENCES $trainings(${TrainingFields.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $entries (
      ${EntryFields.id} $idType,
      ${EntryFields.exerciseId} $integerTypeNotNull,
      ${EntryFields.mainWeight} $realTypeNotNull,
      ${EntryFields.date} $textTypeNotNull,
      ${EntryFields.bodyweight} $realTypeNotNull,
        FOREIGN KEY (${EntryFields.exerciseId})
        REFERENCES $exercises(${ExerciseFields.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $sets (
      ${SetFields.id} $idType,
      ${SetFields.entryId} $integerTypeNotNull,
      ${SetFields.exerciseId} $integerTypeNotNull,
      ${SetFields.weight} $realTypeNotNull,
      ${SetFields.reps} $integerTypeNotNull,
      ${SetFields.rir} $integerTypeNotNull,
      ${SetFields.oneRM} $realTypeNotNull,
      FOREIGN KEY (${SetFields.entryId})
        REFERENCES $entries(${EntryFields.id})
        ON DELETE CASCADE,
      FOREIGN KEY (${SetFields.exerciseId})
        REFERENCES $exercises(${ExerciseFields.id})
        ON DELETE CASCADE
      )
    ''');
  }
}
