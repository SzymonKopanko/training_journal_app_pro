import '../models/body_part.dart';
import '../models/exercise.dart';
import '../models/exercise_body_part_relation.dart';
import '../services/journal_database.dart';
import 'exercise_service.dart';

class BodyPartService {
  final JournalDatabase _instance;

  BodyPartService(this._instance);

  //CREATE
  Future<BodyPart> createBodyPart(BodyPart bodyPart) async {
    final db = await _instance.database;
    final id = await db.insert(body_parts, bodyPart.toJson());
    return bodyPart.copy(id: id);
  }

  Future<void> createAllBodyParts() async {
    final bodyPartNames = [
      'Front Neck',
      'Back Neck',
      'Traps',
      'Front Delts',
      'Side Delts',
      'Rear Delts',
      'Upper Back',
      'Lower Back',
      'Middle Back',
      'Lats',
      'Chest',
      'Abs',
      'Biceps',
      'Triceps',
      'Forearm Flexors',
      'Forearm Extensors',
      'Glute',
      'Quads',
      'Hamstrings',
      'Calves',
      'Tibialis'
    ];
    for (var bodyPartName in bodyPartNames) {
      var bodyPart = await readBodyPartByName(bodyPartName);
      bodyPart ??= await createBodyPart(BodyPart(name: bodyPartName));
    }
  }

  Future<void>
      createStarterExercisesAndBodyPartsWithRelationsWithSomeEdits() async {
    final exerciseBodyPartMap = {
      //klata
      'Bench Press': [
        ['Chest', 'Triceps', 'Front Delts'],
        150,
        0
      ],
      'Incline Bench Press': [
        ['Chest', 'Triceps', 'Front Delts'],
        120,
        0
      ],
      'Machine Chest Fly': [
        ['Chest'],
        120,
        0
      ],

      //barki
      'Dumbbell Lateral Raise': [
        ['Side Delts', 'Traps'],
        60,
        10
      ],
      'Dumbbell Rear Lateral Raise': [
        ['Rear Delts', 'Upper Back'],
        60,
        10
      ],

      //biceps
      'Barbell Curl': [
        ['Biceps'],
        90,
        0
      ],
      'Dumbbell Curl': [
        ['Biceps'],
        60,
        0
      ],
      'Hammer Curl': [
        ['Biceps'],
        90,
        0
      ],
      'Incline Dumbbell Curl': [
        ['Biceps'],
        60,
        0
      ],

      //triceps
      'Overhead Triceps Extension': [
        ['Triceps'],
        90,
        0
      ],
      'JM Press': [
        ['Triceps'],
        120,
        0
      ],

      //nogi
      'Barbell Squat': [
        ['Quads', 'Hamstrings', 'Glutes'],
        180,
        75
      ],
      'Romanian Deadlift': [
        ['Hamstrings', 'Glutes'],
        90,
        50
      ],
      'Standing Calf Raise': [
        ['Calves'],
        60,
        95
      ],

      //plecy
      'Seated Row': [
        ['Lats', 'Traps', 'Forearm Flexors'],
        120,
        0
      ],
      'Pull-Ups': [
        ['Lats', 'Forearm Flexors'],
        120,
        90
      ],

      //brzuch
      'Incline Sit Ups': [
        ['Abs'],
        120,
        60
      ],

      //szyja
      'Front Neck Curls': [
        ['Front Neck'],
        90,
        10
      ],
      'Back Neck Curls': [
        ['Back Neck'],
        90,
        10
      ],

      //przedramiona
      'Bar Hang': [
        ['Forearm Flexors'],
        60,
        100
      ],
      'Dumbbell Wrist Curl': [
        ['Forearm Flexors'],
        60,
        0
      ],
      'Reverse Dumbbell Wrist Curl': [
        ['Forearm Extensors'],
        60,
        0
      ],
    };
    final exerciseService = ExerciseService(_instance);

    for (var entry in exerciseBodyPartMap.entries) {
      final exerciseName = entry.key;
      var exercise = await exerciseService.readExerciseByName(exerciseName);
      exercise ??= await exerciseService.createExercise(Exercise(
          name: exerciseName,
          date: DateTime.now(),
          weight: 0.0,
          reps: 0,
          oneRM: 0.0,
          notes: '',
          restTime: entry.value[1] as int,
          bodyweightPercentage: entry.value[2] as int));
      for (var bodyPartName in entry.value[0] as List<String>) {
        var bodyPart = await readBodyPartByName(bodyPartName);
        bodyPart ??= await createBodyPart(BodyPart(name: bodyPartName));
        final relation = ExerciseBodyPartRelation(
          exerciseId: exercise.id!,
          bodyPartId: bodyPart.id!,
        );
        await createExerciseBodyPartRelation(relation);
      }
    }
  }

  Future<void> createStarterExercisesAndBodyPartsWithRelations() async {
    final exerciseBodyPartMap = {
      //klata
      'Bench Press': ['Chest', 'Triceps', 'Front Delts'],
      'Incline Bench Press': ['Chest', 'Triceps', 'Front Delts'],
      'Machine Chest Fly': ['Chest'],

      //barki
      'Dumbbell Lateral Raise': ['Side Delts', 'Traps'],
      'Dumbbell Rear Lateral Raise': ['Rear Delts', 'Upper Back'],

      //biceps
      'Barbell Curl': ['Biceps'],
      'Dumbbell Curl': ['Biceps'],
      'Hammer Curl': ['Biceps'],
      'Incline Dumbbell Curl': ['Biceps'],

      //triceps
      'Overhead Triceps Extension': ['Triceps'],
      'JM Press': ['Triceps'],

      //nogi
      'Barbell Squat': ['Quads', 'Hamstrings', 'Glutes'],
      'Romanian Deadlift': ['Hamstrings', 'Glutes'],
      'Standing Calf Raise': ['Calves'],

      //plecy
      'Seated Row': ['Lats', 'Traps'],
      'Pull-Ups': ['Lats', 'Forearm Flexors'],

      //brzuch
      'Incline Sit Ups': ['Abs'],

      //szyja
      'Front Neck Curls': ['Front Neck'],
      'Back Neck Curls': ['Back Neck'],

      //przedramiona
      'Bar Hang': ['Forearm Flexors'],
      'Dumbbell Wrist Curl': ['Forearm Flexors'],
      'Reverse Dumbbell Wrist Curl': ['Forearm Extensors'],
    };
    final exerciseService = ExerciseService(_instance);

    for (var entry in exerciseBodyPartMap.entries) {
      final exerciseName = entry.key;
      final bodyParts = entry.value;

      var exercise = await exerciseService.readExerciseByName(exerciseName);
      exercise ??= await exerciseService.createExercise(Exercise(
          name: exerciseName,
          date: DateTime.now(),
          weight: 0.0,
          reps: 0,
          oneRM: 0.0,
          notes: '',
          restTime: 0,
          bodyweightPercentage: 0));
      for (var bodyPartName in bodyParts) {
        var bodyPart = await readBodyPartByName(bodyPartName);
        bodyPart ??= await createBodyPart(BodyPart(name: bodyPartName));
        final relation = ExerciseBodyPartRelation(
          exerciseId: exercise.id!,
          bodyPartId: bodyPart.id!,
        );
        await createExerciseBodyPartRelation(relation);
      }
    }
  }

  Future<ExerciseBodyPartRelation> createExerciseBodyPartRelation(
      ExerciseBodyPartRelation exerciseBodyPartRelation) async {
    final db = await _instance.database;
    final existingRelation = await db.query(
      exercise_body_part_relations,
      where:
          '${ExerciseBodyPartRelationFields.exerciseId} = ? AND ${ExerciseBodyPartRelationFields.bodyPartId} = ?',
      whereArgs: [
        exerciseBodyPartRelation.exerciseId,
        exerciseBodyPartRelation.bodyPartId
      ],
    );
    if (existingRelation.isNotEmpty) {
      return ExerciseBodyPartRelation.fromJson(existingRelation.first);
    }
    final id = await db.insert(
        exercise_body_part_relations, exerciseBodyPartRelation.toJson());

    return exerciseBodyPartRelation.copy(id: id);
  }

  //READ
  Future<List<BodyPart>?> readAllBodyParts() async {
    final db = await _instance.database;
    final result = await db.query(
      body_parts,
      orderBy: '${BodyPartFields.name} ASC',
    );
    if (result.isNotEmpty) {
      return result.map((json) => BodyPart.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<BodyPart> readBodyPartById(int bodyPartId) async {
    final db = await _instance.database;
    final result = await db.query(
      body_parts,
      where: '${BodyPartFields.id} = ?',
      whereArgs: [bodyPartId],
    );
    if (result.isNotEmpty) {
      return BodyPart.fromJson(result.first);
    } else {
      throw Exception('BodyPart with ID $bodyPartId NOT FOUND!');
    }
  }

  Future<BodyPart?> readBodyPartByName(String name) async {
    final db = await _instance.database;
    final result = await db.query(
      body_parts,
      where: '${BodyPartFields.name} = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return BodyPart.fromJson(result.first);
    } else {
      print('BodyPart with name $name NOT FOUND!');
      return null;
    }
  }

  Future<List<BodyPart>?> readAllBodyPartsByExercise(Exercise exercise) async {
    final db = await _instance.database;
    final result = await db.rawQuery('''
    SELECT bp.*
    FROM $body_parts bp
    INNER JOIN $exercise_body_part_relations r
    ON bp.${BodyPartFields.id} = r.${ExerciseBodyPartRelationFields.bodyPartId}
    WHERE r.${ExerciseBodyPartRelationFields.exerciseId} = ?
  ''', [exercise.id]);

    if (result.isNotEmpty) {
      return result.map((json) => BodyPart.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  //UPDATE
  Future<int> updateBodyPart(BodyPart bodyPart) async {
    final db = await _instance.database;
    return await db.update(
      body_parts,
      bodyPart.toJson(),
      where: '${BodyPartFields.id} = ?',
      whereArgs: [bodyPart.id],
    );
  }

  //DELETE
  Future<int> deleteBodyPart(int bodyPartId) async {
    final db = await _instance.database;
    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');
    final rowsDeleted = await db.delete(
      body_parts,
      where: '${BodyPartFields.id} = ?',
      whereArgs: [bodyPartId],
    );
    return rowsDeleted;
  }

  Future<int> deleteAllBodyPartExerciseRelationsByExercise(
      Exercise exercise) async {
    final db = await _instance.database;

    await db.execute('''
    PRAGMA foreign_keys = ON
    ''');

    final rowsDeleted = await db.delete(
      exercise_body_part_relations,
      where: '${ExerciseBodyPartRelationFields.exerciseId} = ?',
      whereArgs: [exercise.id],
    );

    return rowsDeleted;
  }
}
