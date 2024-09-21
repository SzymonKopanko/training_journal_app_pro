const String exercises = 'exercises';

class ExerciseFields {
  static final List<String> values = [
    id, name, date, weight, reps, oneRM, notes, restTime, bodyweightPercentage
  ];

  static const String id = 'exercise_id';
  static const String name = 'name';
  static const String date = 'date';
  static const String weight = 'weight';
  static const String reps = 'reps';
  static const String oneRM = 'oneRM';
  static const String notes = 'notes';
  static const String restTime = 'rest_time';
  static const String bodyweightPercentage = 'bodyweight_percentage'; // Nowe pole
}

class Exercise {
  final int? id;
  final String name;
  final DateTime date;
  final double weight;
  final int reps;
  final double oneRM;
  final String notes;
  final int restTime;
  final int bodyweightPercentage; // Nowe pole

  const Exercise({
    this.id,
    required this.name,
    required this.date,
    required this.weight,
    required this.reps,
    required this.oneRM,
    required this.notes,
    required this.restTime,
    required this.bodyweightPercentage, // Nowe pole
  });

  Exercise copy({
    int? id,
    String? name,
    DateTime? date,
    double? weight,
    int? reps,
    double? oneRM,
    String? notes,
    int? restTime,
    int? bodyweightPercentage, // Nowe pole
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        oneRM: oneRM ?? this.oneRM,
        notes: notes ?? this.notes,
        restTime: restTime ?? this.restTime,
        bodyweightPercentage: bodyweightPercentage ?? this.bodyweightPercentage, // Nowe pole
      );

  Map<String, Object?> toJson() => {
    ExerciseFields.id: id,
    ExerciseFields.name: name,
    ExerciseFields.date: date.toIso8601String(),
    ExerciseFields.weight: weight,
    ExerciseFields.reps: reps,
    ExerciseFields.oneRM: oneRM,
    ExerciseFields.notes: notes,
    ExerciseFields.restTime: restTime,
    ExerciseFields.bodyweightPercentage: bodyweightPercentage, // Nowe pole
  };

  static Exercise fromJson(Map<String, Object?> json) => Exercise(
    id: json[ExerciseFields.id] as int?,
    name: json[ExerciseFields.name] as String,
    date: DateTime.parse(json[ExerciseFields.date] as String),
    weight: json[ExerciseFields.weight] as double,
    reps: json[ExerciseFields.reps] as int,
    oneRM: json[ExerciseFields.oneRM] as double,
    notes: json[ExerciseFields.notes] as String,
    restTime: json[ExerciseFields.restTime] as int,
    bodyweightPercentage: json[ExerciseFields.bodyweightPercentage] as int, // Nowe pole
  );

  @override
  String toString() {
    return 'Exercise{\n'
        '  id: $id,\n'
        '  name: $name,\n'
        '  date: $date,\n'
        '  weight: $weight,\n'
        '  reps: $reps,\n'
        '  oneRM: $oneRM,\n'
        '  notes: $notes,\n'
        '  restTime: $restTime,\n'
        '  bodyweightPercentage: $bodyweightPercentage\n' // Nowe pole
        '}\n';
  }
}
