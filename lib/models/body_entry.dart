const String body_entries = 'body_entries';

class BodyEntryFields {
  static final List<String> values = [id, dateTime, weight];

  static const String id = 'body_entry_id';
  static const String dateTime = 'date_time';
  static const String weight = 'weight';
}

class BodyEntry {
  final int? id;
  final DateTime dateTime;
  final double weight;

  const BodyEntry({
    this.id,
    required this.dateTime,
    required this.weight,
  });

  BodyEntry copy({
    int? id,
    DateTime? dateTime,
    double? weight,
  }) =>
      BodyEntry(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        weight: weight ?? this.weight,
      );

  Map<String, Object?> toJson() => {
    BodyEntryFields.id: id,
    BodyEntryFields.dateTime: dateTime.toIso8601String(),
    BodyEntryFields.weight: weight,
  };

  static BodyEntry fromJson(Map<String, Object?> json) => BodyEntry(
    id: json[BodyEntryFields.id] as int?,
    dateTime: DateTime.parse(json[BodyEntryFields.dateTime] as String),
    weight: json[BodyEntryFields.weight] as double,
  );

  @override
  String toString() {
    return 'BodyEntry:\n'
        '  id: $id,\n'
        '  dateTime: $dateTime,\n'
        '  weight: $weight,\n';
  }
}
