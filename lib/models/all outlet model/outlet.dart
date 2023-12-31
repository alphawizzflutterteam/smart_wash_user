import 'dart:convert';

class Outlets {
  int? id;
  String? name;
  dynamic nameBn;
  String? description;
  dynamic descriptionBn;
  String? imagePath;

  Outlets({
    this.id,
    this.name,
    this.nameBn,
    this.description,
    this.descriptionBn,
    this.imagePath,
  });

  @override
  String toString() {
    return 'Outlets(id: $id, name: $name, nameBn: $nameBn, description: $description, descriptionBn: $descriptionBn, imagePath: $imagePath)';
  }

  factory Outlets.fromMap(Map<String, dynamic> data) => Outlets(
    id: data['id'] as int?,
    name: data['name'] as String?,
    nameBn: data['name_bn'] as dynamic,
    description: data['description'] as String?,
    descriptionBn: data['description_bn'] as dynamic,
    imagePath: data['image_path'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'name_bn': nameBn,
    'description': description,
    'description_bn': descriptionBn,
    'image_path': imagePath,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Outlets].
  factory Outlets.fromJson(String data) {
    return Outlets.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Outlets] to a JSON string.
  String toJson() => json.encode(toMap());

  Outlets copyWith({
    int? id,
    String? name,
    dynamic nameBn,
    String? description,
    dynamic descriptionBn,
    String? imagePath,
  }) {
    return Outlets(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      description: description ?? this.description,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
