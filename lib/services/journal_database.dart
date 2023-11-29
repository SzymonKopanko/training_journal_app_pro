import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/body_entry.dart';
import '../models/exercise_training_relation.dart';
import '../models/set.dart';
import '../models/entry.dart';
import '../models/exercise.dart';
import '../models/training.dart';
import '../models/training_weekly_plan_relation.dart';
import '../models/weekly_plan.dart';

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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE $weekly_plans (
      ${WeeklyPlanFields.id} $idType,
      ${WeeklyPlanFields.name} $textType UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $trainings (
      ${TrainingFields.id} $idType,
      ${TrainingFields.name} $textType UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $body_entries (
      ${BodyEntryFields.id} $idType,
      ${BodyEntryFields.date} $integerType,
      ${BodyEntryFields.weight} $realType,
      ${BodyEntryFields.fatFreeWeight} $realType,
      ${BodyEntryFields.bodyfat} $realType
      )
    ''');

    await db.execute('''
      CREATE TABLE $exercises (
      ${ExerciseFields.id} $idType,
      ${ExerciseFields.name} $textType UNIQUE,
      ${ExerciseFields.date} $textType,
      ${ExerciseFields.weight} $realType,
      ${ExerciseFields.reps} $integerType,
      ${ExerciseFields.oneRM} $realType
      )
    ''');

    await db.execute('''
      CREATE TABLE $training_weekly_plan_relations (
      ${TrainingWeeklyPlanRelationFields.id} $idType,
      ${TrainingWeeklyPlanRelationFields.trainingId} $integerType,
      ${TrainingWeeklyPlanRelationFields.weeklyPlanId} $integerType,
      ${TrainingWeeklyPlanRelationFields.day} $integerType,
      FOREIGN KEY (${TrainingWeeklyPlanRelationFields.trainingId})
        REFERENCES $trainings(${TrainingFields.id})
          ON DELETE CASCADE,
      FOREIGN KEY (${WeeklyPlanFields.id})
        REFERENCES $weekly_plans(${WeeklyPlanFields.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $exercise_training_relations (
      ${ExerciseTrainingRelationFields.id} $idType,
      ${ExerciseTrainingRelationFields.exerciseId} $integerType,
      ${ExerciseTrainingRelationFields.trainingId} $integerType,
      ${ExerciseTrainingRelationFields.placement} $integerType,
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
      ${EntryFields.exerciseId} $integerType,
      ${EntryFields.mainWeight} $realType,
      ${EntryFields.date} $textType,
      FOREIGN KEY (${EntryFields.exerciseId})
        REFERENCES $exercises(${ExerciseFields.id})
          ON DELETE CASCADE

      )
    ''');

    await db.execute('''
      CREATE TABLE $sets (
      ${SetFields.id} $idType,
      ${SetFields.entryId} $integerType,
      ${SetFields.exerciseId} $integerType,
      ${SetFields.weight} $realType,
      ${SetFields.reps} $integerType,
      ${SetFields.rir} $integerType,
      ${SetFields.oneRM} $realType,
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
