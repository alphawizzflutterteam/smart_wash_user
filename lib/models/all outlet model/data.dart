import 'dart:convert';

import 'package:dry_cleaners/models/all_service_model/service.dart';

import 'outlet.dart';

class Data {
  List<Outlets>? outlets;

  Data({this.outlets});

  @override
  String toString() => 'Data(outlets: $outlets)';

  factory Data.fromMap(Map<String, dynamic> data) => Data(
    outlets: (data['outlets'] as List<dynamic>?)
        ?.map((e) => Outlets.fromMap(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'outlets': outlets?.map((e) => e.toMap()).toList(),
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
  factory Data.fromJson(String data) {
    return Data.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
  String toJson() => json.encode(toMap());

  Data copyWith({
    List<Outlets>? outlets,
  }) {
    return Data(
      outlets: outlets ?? this.outlets,
    );
  }
}
