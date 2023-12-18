
class GetOutletModel {
  GetOutletModel({
    String? message,
    Data? data,}){
    _message = message;
    _data = data;
  }

  GetOutletModel.fromJson(dynamic json) {
    _message = json['message'].toString();
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _message;
  Data? _data;
  GetOutletModel copyWith({  String? message,
    Data? data,
  }) => GetOutletModel(  message: message ?? _message,
    data: data ?? _data,
  );
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}


class Data {
  Data({
    List<Outlets>? outlets,}){
    _outlets = outlets;
  }

  Data.fromJson(dynamic json) {
    if (json['outlets'] != null) {
      _outlets = [];
      json['outlets'].forEach((v) {
        _outlets?.add(Outlets.fromJson(v));
      });
    }
  }
  List<Outlets>? _outlets;
  Data copyWith({  List<Outlets>? outlets,
  }) => Data(  outlets: outlets ?? _outlets,
  );
  List<Outlets>? get outlets => _outlets;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_outlets != null) {
      map['outlets'] = _outlets?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}



class Outlets {
  Outlets({
    String? id,
    String? firstName,
    String? lastName,
    String? name,
    String? mobile,
    String? email,
    String? emailVerifiedAt,
    String? mobileVerifiedAt,
    String? isActive,
    String? profilePhotoId,
    String? gender,
    String? address,
    String? serviceP,
    String? services,
    dynamic alternativePhone,
    String? createdAt,
    String? updatedAt,
    dynamic drivingLience,
    dynamic dateOfBirth,}){
    _id = id;
    _firstName = firstName;
    _lastName = lastName;
    _name = name;
    _mobile = mobile;
    _email = email;
    _emailVerifiedAt = emailVerifiedAt;
    _mobileVerifiedAt = mobileVerifiedAt;
    _isActive = isActive;
    _profilePhotoId = profilePhotoId;
    _gender = gender;
    _address = address;
    _serviceP = serviceP;
    _services = services;
    _alternativePhone = alternativePhone;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _drivingLience = drivingLience;
    _dateOfBirth = dateOfBirth;
  }

  Outlets.fromJson(dynamic json) {
    _id = json['id'].toString();
    _firstName = json['first_name'].toString();
    _lastName = json['last_name'].toString();
    _name = json['name'].toString();
    _mobile = json['mobile'].toString();
    _email = json['email'].toString();
    _emailVerifiedAt = json['email_verified_at'].toString();
    _mobileVerifiedAt = json['mobile_verified_at'].toString();
    _isActive = json['is_active'].toString();
    _profilePhotoId = json['profile_photo_path'].toString();
    _gender = json['gender'].toString();
    _address = json['address'].toString();
    _serviceP = json['service_p'].toString();
    _services = json['services'].toString();
    _alternativePhone = json['alternative_phone'];
    _createdAt = json['created_at'].toString();
    _updatedAt = json['updated_at'].toString();
    _drivingLience = json['driving_lience'];
    _dateOfBirth = json['date_of_birth'];
  }
  String? _id;
  String? _firstName;
  String? _lastName;
  String? _name;
  String? _mobile;
  String? _email;
  String? _emailVerifiedAt;
  String? _mobileVerifiedAt;
  String? _isActive;
  String? _profilePhotoId;
  String? _gender;
  String? _address;
  String? _serviceP;
  String? _services;
  dynamic _alternativePhone;
  String? _createdAt;
  String? _updatedAt;
  dynamic _drivingLience;
  dynamic _dateOfBirth;
  Outlets copyWith({  String? id,
    String? firstName,
    String? lastName,
    String? name,
    String? mobile,
    String? email,
    String? emailVerifiedAt,
    String? mobileVerifiedAt,
    String? isActive,
    String? profilePhotoId,
    String? gender,
    String? address,
    String? serviceP,
    String? services,
    dynamic alternativePhone,
    String? createdAt,
    String? updatedAt,
    dynamic drivingLience,
    dynamic dateOfBirth,
  }) => Outlets(


    id: id ?? _id,
    firstName: firstName ?? _firstName,
    lastName: lastName ?? _lastName,
    name: name ?? _name,
    mobile: mobile ?? _mobile,
    email: email ?? _email,
    emailVerifiedAt: emailVerifiedAt ?? _emailVerifiedAt,
    mobileVerifiedAt: mobileVerifiedAt ?? _mobileVerifiedAt,
    isActive: isActive ?? _isActive,
    profilePhotoId: profilePhotoId ?? _profilePhotoId,
    gender: gender ?? _gender,
    address: address ?? _address,
    serviceP: serviceP ?? _serviceP,
    services: services ?? _services,
    alternativePhone: alternativePhone ?? _alternativePhone,
    createdAt: createdAt ?? _createdAt,
    updatedAt: updatedAt ?? _updatedAt,
    drivingLience: drivingLience ?? _drivingLience,
    dateOfBirth: dateOfBirth ?? _dateOfBirth,
  );
  String? get id => _id;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get name => _name;
  String? get mobile => _mobile;
  String? get email => _email;
  String? get emailVerifiedAt => _emailVerifiedAt;
  String? get mobileVerifiedAt => _mobileVerifiedAt;
  String? get isActive => _isActive;
  String? get profilePhotoId => _profilePhotoId;
  String? get gender => _gender;
  String? get address => _address;
  String? get serviceP => _serviceP;
  String? get services => _services;
  dynamic get alternativePhone => _alternativePhone;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  dynamic get drivingLience => _drivingLience;
  dynamic get dateOfBirth => _dateOfBirth;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['first_name'] = _firstName;
    map['last_name'] = _lastName;
    map['name'] = _name;
    map['mobile'] = _mobile;
    map['email'] = _email;
    map['email_verified_at'] = _emailVerifiedAt;
    map['mobile_verified_at'] = _mobileVerifiedAt;
    map['is_active'] = _isActive;
    map['profile_photo_path'] = _profilePhotoId;
    map['gender'] = _gender;
    map['address'] = _address;
    map['service_p'] = _serviceP;
    map['services'] = _services;
    map['alternative_phone'] = _alternativePhone;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['driving_lience'] = _drivingLience;
    map['date_of_birth'] = _dateOfBirth;
    return map;
  }

}