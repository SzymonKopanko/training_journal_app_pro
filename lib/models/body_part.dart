const String body_parts = 'body_parts';

class BodyPartFields {
  static final List<String> values = [
    id, name
  ];

  static const String id = 'body_part_id';
  static const String name = 'name';
}

class BodyPart {
  final int? id;
  final String name;

  const BodyPart({
    this.id,
    required this.name,
  });

  BodyPart copy({
    int? id,
    String? name,
  }) =>
      BodyPart(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  Map<String, Object?> toJson() => {
    BodyPartFields.id: id,
    BodyPartFields.name: name,
  };

  static BodyPart fromJson(Map<String, Object?> json) => BodyPart(
    id: json[BodyPartFields.id] as int?,
    name: json[BodyPartFields.name] as String,
  );

  @override
  String toString() {
    return 'BodyPart{\n'
        '  id: $id,\n'
        '  name: $name,\n'
        '}\n';
  }
}
