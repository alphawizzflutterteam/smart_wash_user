import 'dart:convert';

class Drivers {
  int? id;
  int? userId;
  String? createdAt;
  String? updatedAt;
  int? isApprove;
  Drivers({this.id, this.userId, this.createdAt, this.updatedAt,this.isApprove});

  factory Drivers.fromMap(Map<String, dynamic> data) {
    return Drivers(
      id: data['id'] as int?,
      userId: data['user_id'] as int?,
      createdAt: data['created_at'] as String?,
      updatedAt: data['updated_at'] as String?,
      isApprove: data['is_approve'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'isApprove': isApprove,
  };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Drivers].
  factory Drivers.fromJson(String data) {
    return Drivers.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Drivers] to a JSON string.
  String toJson() => json.encode(toMap());
}
