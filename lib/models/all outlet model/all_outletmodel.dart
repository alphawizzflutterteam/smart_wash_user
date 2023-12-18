import 'dart:convert';

import 'package:dry_cleaners/models/all_service_model/data.dart';

class AllOutletModel {
  String? message;
  Data? data;

  AllOutletModel({this.message, this.data});

  @override
  String toString() => 'AllOutletModel(message: $message, data: $data)';

  factory AllOutletModel.fromMap(Map<String, dynamic> data) {
    return AllOutletModel(
      message: data['message'] as String?,
      data: data['data'] == null
          ? null
          : Data.fromMap(data['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() => {
    'message': message,
    'data': data?.toMap(),
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AllOutletModel].
  factory AllOutletModel.fromJson(String data) {
    return AllOutletModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AllOutletModel] to a JSON string.
  String toJson() => json.encode(toMap());

  AllOutletModel copyWith({
    String? message,
    Data? data,
  }) {
    return AllOutletModel(
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
