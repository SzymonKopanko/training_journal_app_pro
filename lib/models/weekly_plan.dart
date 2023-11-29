const String weekly_plans = 'weekly_plans';

class WeeklyPlanFields {
  static final List<String> values = [id, name];

  static const String id = 'weekly_plan_id';
  static const String name = 'name';
}
class WeeklyPlan {
  final int? id;
  final String name;

  WeeklyPlan({
    this.id,
    required this.name,
  });

  WeeklyPlan copy({
    int? id,
    String? name,
  }) =>
      WeeklyPlan(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  Map<String, Object?> toJson() => {
    WeeklyPlanFields.id: id,
    WeeklyPlanFields.name: name,
  };

  static WeeklyPlan fromJson(Map<String, Object?> json) {
    return WeeklyPlan(
      id: json[WeeklyPlanFields.id] as int?,
      name: json[WeeklyPlanFields.name] as String,
    );
  }
}
