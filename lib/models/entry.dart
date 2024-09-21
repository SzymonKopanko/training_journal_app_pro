const String entries = 'entries';

class EntryFields {
  static final List<String> values = [id, exerciseId, mainWeight, date, bodyweight];

  static const String id = 'entry_id';
  static const String exerciseId = 'exercise_id';
  static const String mainWeight = 'main_weight';
  static const String date = 'date';
  static const String bodyweight = 'bodyweight'; // Nowe pole
}

class Entry {
  final int? id;
  final int exerciseId;
  final double mainWeight;
  final DateTime date;
  final double bodyweight; // Nowe pole

  const Entry({
    this.id,
    required this.exerciseId,
    required this.mainWeight,
    required this.date,
    required this.bodyweight, // Nowe pole
  });

  Entry copy({
    int? id,
    int? exerciseId,
    double? mainWeight,
    DateTime? date,
    double? bodyweight, // Nowe pole
  }) =>
      Entry(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        mainWeight: mainWeight ?? this.mainWeight,
        date: date ?? this.date,
        bodyweight: bodyweight ?? this.bodyweight, // Nowe pole
      );

  Map<String, Object?> toJson() => {
    EntryFields.id: id,
    EntryFields.exerciseId: exerciseId,
    EntryFields.mainWeight: mainWeight,
    EntryFields.date: date.toIso8601String(), // Użyj `toIso8601String()` dla poprawnej konwersji daty
    EntryFields.bodyweight: bodyweight, // Nowe pole
  };

  static Entry fromJson(Map<String, Object?> json) => Entry(
    id: json[EntryFields.id] as int?,
    exerciseId: json[EntryFields.exerciseId] as int,
    mainWeight: json[EntryFields.mainWeight] as double,
    date: DateTime.parse(json[EntryFields.date] as String),
    bodyweight: json[EntryFields.bodyweight] as double, // Nowe pole
  );

  @override
  String toString() {
    return '\t\t\tEntry{\n\t\t\t'
        '  id: $id,\n\t\t\t'
        '  exerciseId: $exerciseId,\n\t\t\t'
        '  mainWeight: $mainWeight,\n\t\t\t'
        '  date: $date,\n\t\t\t'
        '  bodyweight: $bodyweight\n\t\t\t' // Nowe pole
        '}\n';
  }
}
