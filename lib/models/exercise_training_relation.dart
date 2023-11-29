const String exercise_training_relations = 'exercise_training_relations';

class ExerciseTrainingRelationFields {
  static final List<String> values = [id, exerciseId, trainingId];

  static const String id = '_id';
  static const String exerciseId = 'exercise_id';
  static const String trainingId = 'training_id';
  static const String placement = 'placement';
}
class ExerciseTrainingRelation {
  final int? id;
  final int exerciseId;
  final int trainingId;
  final int placement;

  ExerciseTrainingRelation({
    this.id,
    required this.exerciseId,
    required this.trainingId,
    required this.placement,
  });

  ExerciseTrainingRelation copy({
    int? id,
    int? exerciseId,
    int? trainingId,
    int? placement,
  }) =>
      ExerciseTrainingRelation(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        trainingId: trainingId ?? this.trainingId,
        placement: placement ?? this.placement,
      );

  Map<String, Object?> toJson() => {
    ExerciseTrainingRelationFields.id: id,
    ExerciseTrainingRelationFields.exerciseId: exerciseId,
    ExerciseTrainingRelationFields.trainingId: trainingId,
    ExerciseTrainingRelationFields.placement: placement,
  };

  static ExerciseTrainingRelation fromJson(Map<String, Object?> json) {
    return ExerciseTrainingRelation(
      id: json[ExerciseTrainingRelationFields.id] as int?,
      exerciseId: json[ExerciseTrainingRelationFields.exerciseId] as int,
      trainingId: json[ExerciseTrainingRelationFields.trainingId] as int,
      placement: json[ExerciseTrainingRelationFields.placement] as int,
    );
  }
}
