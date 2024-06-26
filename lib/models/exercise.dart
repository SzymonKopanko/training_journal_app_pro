const String exercises = 'exercises';

class ExerciseFields {
  static final List<String> values = [id, name, date, weight, reps, oneRM, notes];

  static const String id = 'exercise_id';
  static const String name = 'name';
  static const String date = 'date';
  static const String weight = 'weight';
  static const String reps = 'reps';
  static const String oneRM = 'oneRM';
  static const String notes = 'notes';
}

class Exercise {
  final int? id;
  final String name;
  final DateTime date;
  final double weight;
  final int reps;
  final double oneRM;
  final String notes;

  const Exercise({
    this.id,
    required this.name,
    required this.date,
    required this.weight,
    required this.reps,
    required this.oneRM,
    required this.notes,
  });

  Exercise copy({
    int? id,
    String? name,
    DateTime? date,
    double? weight,
    int? reps,
    double? oneRM,
    String? notes,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        oneRM: oneRM ?? this.oneRM,
        notes: notes ?? this.notes,
      );

  Map<String, Object?> toJson() => {
    ExerciseFields.id: id,
    ExerciseFields.name: name,
    ExerciseFields.date: date.toIso8601String(),
    ExerciseFields.weight: weight,
    ExerciseFields.reps: reps,
    ExerciseFields.oneRM: oneRM,
    ExerciseFields.notes: notes,
  };

  static Exercise fromJson(Map<String, Object?> json) => Exercise(
    id: json[ExerciseFields.id] as int?,
    name: json[ExerciseFields.name] as String,
    date: DateTime.parse(json[ExerciseFields.date] as String),
    weight: json[ExerciseFields.weight] as double,
    reps: json[ExerciseFields.reps] as int,
    oneRM: json[ExerciseFields.oneRM] as double,
    notes: json[ExerciseFields.notes] as String,
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
        '  notes: $notes\n'
        '}\n';
  }
}
