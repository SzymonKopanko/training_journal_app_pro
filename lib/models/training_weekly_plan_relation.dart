const String training_weekly_plan_relations = 'training_weekly_plan_relations';

class TrainingWeeklyPlanRelationFields {
  static final List<String> values = [id, weeklyPlanId, trainingId, dayOfWeek];

  static const String id = '_id';
  static const String weeklyPlanId = 'weekly_plan_id';
  static const String trainingId = 'training_id';
  static const String dayOfWeek = 'day_of_week';
}

class TrainingWeeklyPlanRelation {
  final int? id;
  final int weeklyPlanId;
  final int trainingId;
  final int dayOfWeek;

  const TrainingWeeklyPlanRelation({
    this.id,
    required this.weeklyPlanId,
    required this.trainingId,
    required this.dayOfWeek,
  });

  TrainingWeeklyPlanRelation copy({
    int? id,
    int? weeklyPlanId,
    int? trainingId,
    int? dayOfWeek,
  }) =>
      TrainingWeeklyPlanRelation(
        id: id ?? this.id,
        weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
        trainingId: trainingId ?? this.trainingId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      );

  Map<String, Object?> toJson() => {
        TrainingWeeklyPlanRelationFields.id: id,
        TrainingWeeklyPlanRelationFields.weeklyPlanId: weeklyPlanId,
        TrainingWeeklyPlanRelationFields.trainingId: trainingId,
        TrainingWeeklyPlanRelationFields.dayOfWeek: dayOfWeek,
      };

  static TrainingWeeklyPlanRelation fromJson(Map<String, Object?> json) =>
      TrainingWeeklyPlanRelation(
        id: json[TrainingWeeklyPlanRelationFields.id] as int?,
        weeklyPlanId:
            json[TrainingWeeklyPlanRelationFields.weeklyPlanId] as int,
        trainingId: json[TrainingWeeklyPlanRelationFields.trainingId] as int,
        dayOfWeek: json[TrainingWeeklyPlanRelationFields.dayOfWeek] as int,
      );
}
