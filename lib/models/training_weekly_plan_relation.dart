const String training_weekly_plan_relations = 'training_weekly_plan_relations';

class TrainingWeeklyPlanRelationFields {
  static final List<String> values = [id, trainingId, weeklyPlanId];

  static const String id = '_id';
  static const String trainingId = 'training_id';
  static const String weeklyPlanId = 'weekly_plan_id';
  static const String day = 'day';
}
class TrainingWeeklyPlanRelation {
  final int? id;
  final int trainingId;
  final int weeklyPlanId;
  final int day; // from 1 to 7, as in week

  TrainingWeeklyPlanRelation({
    this.id,
    required this.trainingId,
    required this.weeklyPlanId,
    required this.day,
  });

  TrainingWeeklyPlanRelation copy({
    int? id,
    int? trainingId,
    int? weeklyPlanId,
    int? day,
  }) =>
      TrainingWeeklyPlanRelation(
        id: id ?? this.id,
        trainingId: trainingId ?? this.trainingId,
        weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
        day: day ?? this.day,
      );

  Map<String, Object?> toJson() => {
    TrainingWeeklyPlanRelationFields.id: id,
    TrainingWeeklyPlanRelationFields.trainingId: trainingId,
    TrainingWeeklyPlanRelationFields.weeklyPlanId: weeklyPlanId,
    TrainingWeeklyPlanRelationFields.day: day,
  };

  static TrainingWeeklyPlanRelation fromJson(Map<String, Object?> json) {
    return TrainingWeeklyPlanRelation(
      id: json[TrainingWeeklyPlanRelationFields.id] as int?,
      trainingId: json[TrainingWeeklyPlanRelationFields.trainingId] as int,
      weeklyPlanId: json[TrainingWeeklyPlanRelationFields.weeklyPlanId] as int,
      day: json[TrainingWeeklyPlanRelationFields.day] as int,
    );
  }
}
