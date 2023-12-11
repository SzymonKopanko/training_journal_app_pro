import 'package:flutter/material.dart';

const String training_weekly_plan_relations = 'training_weekly_plan_relations';

class TrainingWeeklyPlanRelationFields {
  static final List<String> values = [id, trainingId, weeklyPlanId, day, time];

  static const String id = '_id';
  static const String trainingId = 'training_id';
  static const String weeklyPlanId = 'weekly_plan_id';
  static const String day = 'day';
  static const String time = 'time';
}
class TrainingWeeklyPlanRelation {
  final int? id;
  final int trainingId;
  final int weeklyPlanId;
  final int day; // from 1 to 7, as in week
  final TimeOfDay time;

  TrainingWeeklyPlanRelation({
    this.id,
    required this.trainingId,
    required this.weeklyPlanId,
    required this.day,
    required this.time,
  });

  TrainingWeeklyPlanRelation copy({
    int? id,
    int? trainingId,
    int? weeklyPlanId,
    int? day,
    TimeOfDay? time,
  }) =>
      TrainingWeeklyPlanRelation(
        id: id ?? this.id,
        trainingId: trainingId ?? this.trainingId,
        weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
        day: day ?? this.day,
        time: time ?? this.time,
      );

  Map<String, Object?> toJson() => {
    TrainingWeeklyPlanRelationFields.id: id,
    TrainingWeeklyPlanRelationFields.trainingId: trainingId,
    TrainingWeeklyPlanRelationFields.weeklyPlanId: weeklyPlanId,
    TrainingWeeklyPlanRelationFields.day: day,
    TrainingWeeklyPlanRelationFields.time: time.toString(),
  };

  static TrainingWeeklyPlanRelation fromJson(Map<String, Object?> json) {
    return TrainingWeeklyPlanRelation(
      id: json[TrainingWeeklyPlanRelationFields.id] as int?,
      trainingId: json[TrainingWeeklyPlanRelationFields.trainingId] as int,
      weeklyPlanId: json[TrainingWeeklyPlanRelationFields.weeklyPlanId] as int,
      day: json[TrainingWeeklyPlanRelationFields.day] as int,
      time: json[TrainingWeeklyPlanRelationFields.time] as TimeOfDay,
    );
  }

  @override
  String toString() {
    return 'TrainingWeeklyPlanRelation{\n'
        '  id: $id,\n'
        '  trainingId: $trainingId,\n'
        '  weeklyPlanId: $weeklyPlanId,\n'
        '  day: $day\n'
        '  time: $time\n'
        '}';
  }
}
