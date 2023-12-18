// To parse this JSON data, do
//
//     final outletgetModel = outletgetModelFromJson(jsonString);

import 'dart:convert';

OutletgetModel outletgetModelFromJson(String str) => OutletgetModel.fromJson(json.decode(str)as Map<String, dynamic>);

String outletgetModelToJson(OutletgetModel data) => json.encode(data.toJson());

class OutletgetModel {
  String? message;
  Data? data;

  OutletgetModel({
    this.message,
    this.data,
  });

  factory OutletgetModel.fromJson(Map<String, dynamic> json) => OutletgetModel(
    message: json["message"].toString(),
    data: json["data"] == null ? null : Data.fromJson( json["data"] as Map<String, dynamic> ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Outlet>? outlets;

  Data({
    this.outlets,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    outlets: json["outlets"] == null ? [] : List<Outlet>.from((json["outlets"] as List).map((x) => Outlet.fromJson(x as Map<String, dynamic>))),
  );

  Map<String, dynamic> toJson() => {
    "outlets": outlets == null ? [] : List<dynamic>.from(outlets!.map((x) => x.toJson())),
  };
}

class Outlet {
  String? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? email;
  DateTime? emailVerifiedAt;
  DateTime? mobileVerifiedAt;
  String? isActive;
  String? profilePhotoId;
  String? gender;
  String? address;
  String? serviceP;
  String? services;
  dynamic alternativePhone;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic drivingLience;
  dynamic dateOfBirth;

  Outlet({
    this.id,
    this.firstName,
    this.lastName,
    this.mobile,
    this.email,
    this.emailVerifiedAt,
    this.mobileVerifiedAt,
    this.isActive,
    this.profilePhotoId,
    this.gender,
    this.address,
    this.serviceP,
    this.services,
    this.alternativePhone,
    this.createdAt,
    this.updatedAt,
    this.drivingLience,
    this.dateOfBirth,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
    id: json["id"].toString(),
    firstName: json["first_name"].toString(),
    lastName: json["last_name"].toString(),
    mobile: json["mobile"].toString(),
    email: json["email"].toString(),
    emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"].toString()),
    mobileVerifiedAt: json["mobile_verified_at"] == null ? null : DateTime.parse(json["mobile_verified_at"].toString()),
    isActive: json["is_active"].toString(),
    profilePhotoId: json["profile_photo_id"].toString(),
    gender: json["gender"].toString(),
    address: json["address"].toString(),
    serviceP: json["service_p"].toString(),
    services: json["services"].toString(),
    alternativePhone: json["alternative_phone"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"].toString()),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"].toString()),
    drivingLience: json["driving_lience"],
    dateOfBirth: json["date_of_birth"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "mobile": mobile,
    "email": email,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "mobile_verified_at": mobileVerifiedAt?.toIso8601String(),
    "is_active": isActive,
    "profile_photo_id": profilePhotoId,
    "gender": gender,
    "address": address,
    "service_p": serviceP,
    "services": services,
    "alternative_phone": alternativePhone,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "driving_lience": drivingLience,
    "date_of_birth": dateOfBirth,
  };
}
