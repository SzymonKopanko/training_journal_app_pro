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
    final db = await _instance.database;
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
    for (String bodyPartName in bodyPartNames) {
      final bodyPart = BodyPart(name: bodyPartName);
      await db.insert(body_parts, bodyPart.toJson());
    }
  }

  Future<void> createStarterExercisesAndBodyPartsWithRelations() async {
    final exerciseBodyPartMap = {
      'Band-Assisted Bench Press': ['Chest'],
      'Bench Press': ['Chest'],
      'Bench Press Against Band': ['Chest'],
      'Board Press': ['Chest'],
      'Cable Chest Press': ['Chest'],
      'Close-Grip Bench Press': ['Chest', 'Triceps'],
      'Close-Grip Feet-Up Bench Press': ['Chest', 'Triceps'],
      'Decline Bench Press': ['Chest'],
      'Decline Push-Up': ['Chest'],
      'Dumbbell Chest Fly': ['Chest'],
      'Dumbbell Chest Press': ['Chest'],
      'Dumbbell Decline Chest Press': ['Chest'],
      'Dumbbell Floor Press': ['Chest'],
      'Dumbbell Pullover': ['Chest', 'Lats'],
      'Feet-Up Bench Press': ['Chest'],
      'Floor Press': ['Chest'],
      'Incline Bench Press': ['Chest'],
      'Incline Dumbbell Press': ['Chest'],
      'Incline Push-Up': ['Chest'],
      'Kettlebell Floor Press': ['Chest'],
      'Kneeling Incline Push-Up': ['Chest'],
      'Kneeling Push-Up': ['Chest'],
      'Machine Chest Fly': ['Chest'],
      'Machine Chest Press': ['Chest'],
      'Pec Deck': ['Chest'],
      'Pin Bench Press': ['Chest'],
      'Push-Up': ['Chest'],
      'Push-Up Against Wall': ['Chest'],
      'Push-Ups With Feet in Rings': ['Chest'],
      'Resistance Band Chest Fly': ['Chest'],
      'Smith Machine Bench Press': ['Chest'],
      'Smith Machine Incline Bench Press': ['Chest'],
      'Standing Cable Chest Fly': ['Chest'],
      'Standing Resistance Band Chest Fly': ['Chest'],

      // Ćwiczenia na ramiona
      'Barbell Front Raise': ['Front Delts'],
      'Dumbbell Shoulder Press': ['Front Delts', 'Triceps'],
      'Band External Shoulder Rotation': ['Rear Delts'],
      'Band Internal Shoulder Rotation': ['Rear Delts'],
      'Band Pull-Apart': ['Rear Delts'],
      'Barbell Rear Delt Row': ['Rear Delts', 'Lats'],
      'Cable Lateral Raise': ['Side Delts'],
      'Cable Rear Delt Row': ['Rear Delts', 'Lats'],
      'Dumbbell Lateral Raise': ['Side Delts'],
      'Dumbbell Rear Delt Row': ['Rear Delts'],
      'Face Pull': ['Rear Delts'],
      'Seated Dumbbell Shoulder Press': ['Front Delts'],
      'Seated Barbell Overhead Press': ['Front Delts', 'Triceps'],
      'Snatch Grip Behind the Neck Press': ['Front Delts'],

      // Ćwiczenia na bicepsy
      'Barbell Curl': ['Biceps'],
      'Barbell Preacher Curl': ['Biceps'],
      'Bodyweight Curl': ['Biceps'],
      'Cable Curl With Bar': ['Biceps'],
      'Cable Curl With Rope': ['Biceps'],
      'Concentration Curl': ['Biceps'],
      'Dumbbell Curl': ['Biceps'],
      'Dumbbell Preacher Curl': ['Biceps'],
      'Hammer Curl': ['Biceps', 'Forearms'],
      'Incline Dumbbell Curl': ['Biceps'],
      'Machine Bicep Curl': ['Biceps'],
      'Spider Curl': ['Biceps'],

      // Ćwiczenia na tricepsy
      'Barbell Standing Triceps Extension': ['Triceps'],
      'Barbell Lying Triceps Extension': ['Triceps'],
      'Bench Dip': ['Triceps', 'Chest'],
      'Close-Grip Push-Up': ['Triceps', 'Chest'],
      'Dumbbell Lying Triceps Extension': ['Triceps'],
      'Dumbbell Standing Triceps Extension': ['Triceps'],
      'Overhead Cable Triceps Extension': ['Triceps'],
      'Tricep Bodyweight Extension': ['Triceps'],
      'Tricep Pushdown With Bar': ['Triceps'],
      'Tricep Pushdown With Rope': ['Triceps'],

      // Ćwiczenia na nogi
      'Air Squat': ['Quads'],
      'Barbell Hack Squat': ['Quads', 'Glutes'],
      'Barbell Lunge': ['Quads', 'Glutes'],
      'Barbell Walking Lunge': ['Quads', 'Glutes'],
      'Belt Squat': ['Quads', 'Glutes'],
      'Body Weight Lunge': ['Quads'],
      'Box Squat': ['Quads', 'Glutes'],
      'Bulgarian Split Squat': ['Quads', 'Glutes'],
      'Dumbbell Lunge': ['Quads', 'Glutes'],
      'Dumbbell Squat': ['Quads', 'Glutes'],
      'Front Squat': ['Quads'],
      'Goblet Squat': ['Quads', 'Glutes'],
      'Leg Curl On Ball': ['Hamstrings'],
      'Leg Extension': ['Quads'],
      'Leg Press': ['Quads', 'Glutes'],
      'Lying Leg Curl': ['Hamstrings'],
      'Romanian Deadlift': ['Hamstrings', 'Glutes'],
      'Seated Leg Curl': ['Hamstrings'],
      'Sumo Squat': ['Quads', 'Glutes'],

      // Ćwiczenia na plecy
      'Barbell Row': ['Lats', 'Traps'],
      'Dumbbell Row': ['Lats', 'Traps'],
      'Dumbbell Shrug': ['Traps'],
      'Lat Pulldown': ['Lats'],
      'Pull-Up': ['Lats', 'Biceps'],
      'Seated Row': ['Lats', 'Traps'],
      'T-Bar Row': ['Lats', 'Traps'],
      'Wide-Grip Pull-Up': ['Lats'],

      // Ćwiczenia na brzuch
      'Crunch': ['Abs'],
      'Hanging Leg Raise': ['Abs'],
      'Leg Raise': ['Abs'],
      'Plank': ['Abs', 'Core'],
      'Russian Twist': ['Abs', 'Obliques'],

      // Ćwiczenia na łydki
      'Seated Calf Raise': ['Calves'],
      'Donkey Calf Raise': ['Calves'],
      'Standing Calf Raise': ['Calves'],

      // Ćwiczenia na przedramiona
      'Barbell Wrist Curl': ['Forearm Flexors'],
      'Dumbbell Wrist Curl': ['Forearm Flexors'],
      'Reverse Barbell Wrist Curl': ['Forearm Extensors'],
      'Reverse Dumbbell Wrist Curl': ['Forearm Extensors'],
    };
    final exerciseService =
        ExerciseService(_instance);

    for (var entry in exerciseBodyPartMap.entries) {
      final exerciseName = entry.key;
      final bodyParts = entry.value;

      var exercise = await exerciseService.readExerciseByName(exerciseName);
      exercise ??= await exerciseService.createExercise(Exercise(name: exerciseName, date: DateTime.now(), weight: 0.0, reps: 0, oneRM: 0.0, notes: '', restTime: 0, bodyweightPercentage: 0));
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
}
