const String exercise_body_part_relations = 'exercise_body_part_relations';

class ExerciseBodyPartRelationFields {
  static final List<String> values = [id, exerciseId, bodyPartId];

  static const String id = '_id';
  static const String exerciseId = 'exercise_id';
  static const String bodyPartId = 'body_part_id';
}
class ExerciseBodyPartRelation {
  final int? id;
  final int exerciseId;
  final int bodyPartId;

  ExerciseBodyPartRelation({
    this.id,
    required this.exerciseId,
    required this.bodyPartId,
  });

  ExerciseBodyPartRelation copy({
    int? id,
    int? exerciseId,
    int? bodyPartId,
  }) =>
      ExerciseBodyPartRelation(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        bodyPartId: bodyPartId ?? this.bodyPartId,
      );

  Map<String, Object?> toJson() => {
    ExerciseBodyPartRelationFields.id: id,
    ExerciseBodyPartRelationFields.exerciseId: exerciseId,
    ExerciseBodyPartRelationFields.bodyPartId: bodyPartId,
  };

  static ExerciseBodyPartRelation fromJson(Map<String, Object?> json) {
    return ExerciseBodyPartRelation(
      id: json[ExerciseBodyPartRelationFields.id] as int?,
      exerciseId: json[ExerciseBodyPartRelationFields.exerciseId] as int,
      bodyPartId: json[ExerciseBodyPartRelationFields.bodyPartId] as int,
    );
  }

  @override
  String toString() {
    return 'ExerciseBodyPartRelation{\n'
        '  id: $id,\n'
        '  exerciseId: $exerciseId,\n'
        '  bodyPartId: $bodyPartId,\n'
        '}';
  }
}
