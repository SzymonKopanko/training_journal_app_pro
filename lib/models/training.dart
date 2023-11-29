const String trainings = 'trainings';

class TrainingFields {
  static final List<String> values = [id, name];

  static const String id = 'training_id';
  static const String name = 'name';
}
class Training {
  final int? id;
  final String name;

  Training({
    this.id,
    required this.name,
  });

  Training copy({
    int? id,
    String? name,
  }) =>
      Training(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  Map<String, Object?> toJson() => {
    TrainingFields.id: id,
    TrainingFields.name: name,
  };

  static Training fromJson(Map<String, Object?> json) {
    return Training(
      id: json[TrainingFields.id] as int?,
      name: json[TrainingFields.name] as String,
    );
  }
}
