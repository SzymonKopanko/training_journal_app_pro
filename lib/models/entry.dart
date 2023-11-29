const String entries = 'entries';

class EntryFields {
  static final List<String> values = [id, exerciseId, mainWeight, date];

  static const String id = 'entry_id';
  static const String exerciseId = 'exercise_id';
  static const String mainWeight = 'main_weight';
  static const String date = 'date';
}

class Entry {
  final int? id;
  final int exerciseId;
  final double mainWeight;
  final DateTime date;

  const Entry({
    this.id,
    required this.exerciseId,
    required this.mainWeight,
    required this.date,
  });

  Entry copy({
    int? id,
    int? exerciseId,
    double? mainWeight,
    DateTime? date,
  }) =>
      Entry(
        id: id ?? this.id,
        exerciseId: this.exerciseId,
        mainWeight: this.mainWeight,
        date: date ?? this.date,
      );

  Map<String, Object?> toJson() => {
        EntryFields.id: id,
        EntryFields.exerciseId: exerciseId,
        EntryFields.mainWeight: mainWeight,
        EntryFields.date: date.toString(),
      };

  static Entry fromJson(Map<String, Object?> json) => Entry(
        id: json[EntryFields.id] as int?,
        exerciseId: json[EntryFields.exerciseId] as int,
        mainWeight: json[EntryFields.mainWeight] as double,
        date: DateTime.parse(json[EntryFields.date] as String),
      );
}
