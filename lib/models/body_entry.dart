const String body_entries = 'body_entries';

class BodyEntryFields {
  static final List<String> values = [id, date, weight, fatFreeWeight, bodyfat];

  static const String id = 'body_entry_id';
  static const String date = 'date';
  static const String weight = 'weight';
  static const String fatFreeWeight = 'fatFreeWeight';
  static const String bodyfat = 'bodyfat';
}

class BodyEntry {
  final int? id;
  final DateTime date;
  final double weight;
  final double fatFreeWeight;
  final double bodyfat;

  const BodyEntry({
    this.id,
    required this.date,
    required this.weight,
    required this.fatFreeWeight,
    required this.bodyfat,
  });

  BodyEntry copy({
    int? id,
    DateTime? date,
    double? weight,
    double? fatFreeWeight,
    double? bodyfat,
  }) =>
      BodyEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        fatFreeWeight: fatFreeWeight ?? this.fatFreeWeight,
        bodyfat: bodyfat ?? this.bodyfat,
      );

  Map<String, Object?> toJson() => {
    BodyEntryFields.id: id,
    BodyEntryFields.date: date.toIso8601String(),
    BodyEntryFields.weight: weight,
    BodyEntryFields.fatFreeWeight: fatFreeWeight,
    BodyEntryFields.bodyfat: bodyfat,
  };

  static BodyEntry fromJson(Map<String, Object?> json) => BodyEntry(
    id: json[BodyEntryFields.id] as int?,
    date: DateTime.parse(json[BodyEntryFields.date] as String),
    weight: json[BodyEntryFields.weight] as double,
    fatFreeWeight: json[BodyEntryFields.fatFreeWeight] as double,
    bodyfat: json[BodyEntryFields.bodyfat] as double,
  );
}
