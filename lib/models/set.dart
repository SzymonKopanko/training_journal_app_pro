const String sets = 'sets';

class SetFields {
  static final List<String> values = [id, entryId, exerciseId, weight, reps, rir, oneRM];

  static const String id = 'set_id';
  static const String entryId = 'entry_id';
  static const String exerciseId = 'exercise_id';
  static const String weight = 'weight';
  static const String reps = 'reps';
  static const String rir = 'rir';
  static const String oneRM = 'oneRM';

}

class Set {
  final int? id;
  final int entryId;
  final int exerciseId;
  final double weight;
  final int reps;
  final int rir;
  final double oneRM;

  const Set({
    this.id,
    required this.entryId,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.rir,
    required this.oneRM,
  });

  Set copy({
    int? id,
    int? entryId,
    int? exerciseId,
    double? weight,
    int? reps,
    int? rir,
    double? oneRM,
  }) =>
      Set(
        id: id ?? this.id,
        entryId: entryId ?? this.entryId,
        exerciseId: this.exerciseId,
        weight: weight ?? this.weight,
        reps: reps ?? this.reps,
        rir: rir ?? this.rir,
        oneRM: oneRM ?? this.oneRM,
      );

  Map<String, Object?> toJson() => {
    SetFields.id: id,
    SetFields.entryId: entryId,
    SetFields.exerciseId: exerciseId,
    SetFields.weight: weight,
    SetFields.reps: reps,
    SetFields.rir: rir,
    SetFields.oneRM: oneRM,
  };

  static Set fromJson(Map<String, Object?> json) => Set(
    id: json[SetFields.id] as int?,
    entryId: json[SetFields.entryId] as int,
    exerciseId: json[SetFields.exerciseId] as int,
    weight: json[SetFields.weight] as double,
    reps: json[SetFields.reps] as int,
    rir: json[SetFields.rir] as int,
    oneRM: json[SetFields.oneRM] as double,
  );
}
