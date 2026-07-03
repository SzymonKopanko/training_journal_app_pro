import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/body_entry.dart';
import '../models/body_part.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/exercise_body_part_relation.dart';
import '../models/exercise_training_relation.dart';
import '../models/set.dart';
import '../models/training.dart';
import '../models/training_weekly_plan_relation.dart';
import '../models/weekly_plan.dart';

class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();
  static Database? _database;
  static Future<Database>? _openingDatabase;

  JournalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Równoległe wywołania muszą współdzielić ten sam Future — inaczej
    // sqflite otwiera ten sam plik wielokrotnie i pojawia się "database locked".
    _openingDatabase ??= _initDB();
    _database = await _openingDatabase!;
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
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static const int _databaseVersion = 3;

  Future<void> _onConfigure(Database db) async {
    // Wymuszamy klucze obce przy każdym otwarciu bazy (nie tylko przy tworzeniu).
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migracje addytywne, uruchamiane kolejno w zależności od wersji startowej.
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
  }

  // v1 -> v2: kolumna date_time w body_entries była zadeklarowana jako INTEGER,
  // mimo że przechowujemy wartości ISO8601 (TEXT). Przebudowujemy tabelę na TEXT,
  // zachowując istniejące dane. body_entries nie ma przychodzących kluczy obcych,
  // więc przebudowa jest bezpieczna.
  Future<void> _migrateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE ${body_entries}_new (
      ${BodyEntryFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${BodyEntryFields.dateTime} TEXT NOT NULL,
      ${BodyEntryFields.weight} REAL NOT NULL
      )
    ''');
    await db.execute('''
      INSERT INTO ${body_entries}_new
        (${BodyEntryFields.id}, ${BodyEntryFields.dateTime}, ${BodyEntryFields.weight})
      SELECT ${BodyEntryFields.id}, ${BodyEntryFields.dateTime}, ${BodyEntryFields.weight}
      FROM $body_entries
    ''');
    await db.execute('DROP TABLE $body_entries');
    await db.execute('ALTER TABLE ${body_entries}_new RENAME TO $body_entries');
  }

  Future<void> _migrateToV3(Database db) async {
    await db.execute('''
      CREATE TABLE $weekly_plans (
      ${WeeklyPlanFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${WeeklyPlanFields.name} TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE $training_weekly_plan_relations (
      ${TrainingWeeklyPlanRelationFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${TrainingWeeklyPlanRelationFields.weeklyPlanId} INTEGER NOT NULL,
      ${TrainingWeeklyPlanRelationFields.trainingId} INTEGER NOT NULL,
      ${TrainingWeeklyPlanRelationFields.dayOfWeek} INTEGER NOT NULL,
      FOREIGN KEY (${TrainingWeeklyPlanRelationFields.weeklyPlanId})
        REFERENCES $weekly_plans(${WeeklyPlanFields.id})
          ON DELETE CASCADE,
      FOREIGN KEY (${TrainingWeeklyPlanRelationFields.trainingId})
        REFERENCES $trainings(${TrainingFields.id})
          ON DELETE CASCADE,
      UNIQUE (${TrainingWeeklyPlanRelationFields.weeklyPlanId},
              ${TrainingWeeklyPlanRelationFields.dayOfWeek})
      )
    ''');
  }

  Future<void> printPath() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'training.db');
    debugPrint('Database path: $path');
  }

  Future close() async {
    final db = _database;
    if (db == null) return;
    await db.close();
    _database = null;
    _openingDatabase = null;
  }

  Future<void> deleteDB() async {
    await close();
    if (Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
    }
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'training.db');
    await deleteDatabase(path);
  }

  Future _createDB(Database db, int version) async {
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
      ${BodyEntryFields.dateTime} $textTypeNotNull,
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
        REFERENCES $body_parts(${BodyPartFields.id})
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

    await db.execute('''
      CREATE TABLE $weekly_plans (
      ${WeeklyPlanFields.id} $idType,
      ${WeeklyPlanFields.name} $textTypeNotNull UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $training_weekly_plan_relations (
      ${TrainingWeeklyPlanRelationFields.id} $idType,
      ${TrainingWeeklyPlanRelationFields.weeklyPlanId} $integerTypeNotNull,
      ${TrainingWeeklyPlanRelationFields.trainingId} $integerTypeNotNull,
      ${TrainingWeeklyPlanRelationFields.dayOfWeek} $integerTypeNotNull,
      FOREIGN KEY (${TrainingWeeklyPlanRelationFields.weeklyPlanId})
        REFERENCES $weekly_plans(${WeeklyPlanFields.id})
          ON DELETE CASCADE,
      FOREIGN KEY (${TrainingWeeklyPlanRelationFields.trainingId})
        REFERENCES $trainings(${TrainingFields.id})
          ON DELETE CASCADE,
      UNIQUE (${TrainingWeeklyPlanRelationFields.weeklyPlanId},
              ${TrainingWeeklyPlanRelationFields.dayOfWeek})
      )
    ''');
  }
}
