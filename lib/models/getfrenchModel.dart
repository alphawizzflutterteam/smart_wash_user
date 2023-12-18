// To parse this JSON data, do
//
//     final getFrenchModel = getFrenchModelFromJson(jsonString);

import 'dart:convert';

// GetFrenchModel getFrenchModelFromJson(String str) => GetFrenchModel.fromJson(json.decode(str));
//
// String getFrenchModelToJson(GetFrenchModel data) => json.encode(data.toJson());

class GetFrenchModel {
  String message;
  Data data;

  GetFrenchModel({
    required this.message,
    required this.data,
  });

  factory GetFrenchModel.fromJson(Map<String, dynamic> json) => GetFrenchModel(
    message: json["message"].toString(),
    data: Data.fromJson(json["data"] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<Franchise>? franchise;

  Data({this.franchise});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Franchise'] != null) {
      franchise = <Franchise>[];
      json['Franchise'].forEach((v) {
        franchise!.add(new Franchise.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.franchise != null) {
      data['Franchise'] = this.franchise!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Franchise {
  String id;
  String firstName;
  String lastName;
  String mobile;
  String email;
  String emailVerifiedAt;
  String mobileVerifiedAt;
  String isActive;
  String password;
  String profilePhotoId;
  String gender;
  String address;
  String serviceP;
  String services;
  String alternativePhone;
  String rememberToken;
  DateTime createdAt;
  DateTime updatedAt;
  String drivingLience;
  String dateOfBirth;
  String role;
  String vendorId;
  String lat;
  String lang;

  Franchise({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.emailVerifiedAt,
    required this.mobileVerifiedAt,
    required this.isActive,
    required this.password,
    required this.profilePhotoId,
    required this.gender,
    required this.address,
    required this.serviceP,
    required this.services,
    required this.alternativePhone,
    required this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    required this.drivingLience,
    required this.dateOfBirth,
    required this.role,
    required this.vendorId,
    required this.lat,
    required this.lang,
  });

  factory Franchise.fromJson(Map<String, dynamic> json) => Franchise(
    id: json["id"].toString(),
    firstName: json["first_name"].toString(),
    lastName: json["last_name"].toString(),
    mobile: json["mobile"].toString(),
    email: json["email"].toString(),
    emailVerifiedAt: json["email_verified_at"].toString(),
    mobileVerifiedAt: json["mobile_verified_at"].toString(),
    isActive: json["is_active"].toString(),
    password: json["password"].toString(),
    profilePhotoId: json["profile_photo_id"].toString(),
    gender: json["gender"].toString(),
    address: json["address"].toString(),
    serviceP: json["service_p"].toString(),
    services: json["services"].toString(),
    alternativePhone: json["alternative_phone"].toString(),
    rememberToken: json["remember_token"].toString(),
    createdAt: DateTime.parse(json["created_at"].toString()),
    updatedAt: DateTime.parse(json["updated_at"].toString()),
    drivingLience: json["driving_lience"].toString(),
    dateOfBirth: json["date_of_birth"].toString(),
    role: json["role"].toString(),
    vendorId: json["vendor_id"].toString(),
    lat: json["lat"].toString(),
    lang: json["lang"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "mobile": mobile,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "mobile_verified_at": mobileVerifiedAt,
    "is_active": isActive,
    "password": password,
    "profile_photo_id": profilePhotoId,
    "gender": gender,
    "address": address,
    "service_p": serviceP,
    "services": services,
    "alternative_phone": alternativePhone,
    "remember_token": rememberToken,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "driving_lience": drivingLience,
    "date_of_birth": dateOfBirth,
    "role": role,
    "vendor_id": vendorId,
    "lat": lat,
    "lang": lang,
  };
}
