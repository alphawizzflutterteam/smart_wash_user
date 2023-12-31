import 'dart:convert';

import 'package:collection/collection.dart';

class Address {
  int? id;
  String? addressName;
  String? roadNo;
  String? houseNo;
  dynamic houseName;
  String? flatNo;
  dynamic block;
  String? area;
  dynamic subDistrictId;
  dynamic districtId;
  String? addressLine;
  String? addressLine2;
  String? deliveryNote;
  String? postCode;
  String? latitude;
  String? longitude;

  Address({
    this.id,
    this.addressName,
    this.roadNo,
    this.houseNo,
    this.houseName,
    this.flatNo,
    this.block,
    this.area,
    this.subDistrictId,
    this.districtId,
    this.addressLine,
    this.addressLine2,
    this.deliveryNote,
    this.postCode,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    return 'Address(id: $id, addressName: $addressName, roadNo: $roadNo, houseNo: $houseNo, houseName: $houseName, flatNo: $flatNo, block: $block, area: $area, subDistrictId: $subDistrictId, districtId: $districtId, addressLine: $addressLine, addressLine2: $addressLine2, deliveryNote: $deliveryNote, postCode: $postCode, latitude: $latitude, longitude: $longitude)';
  }

  factory Address.fromMap(Map<String, dynamic> data) => Address(
        id: data['id'] as int?,
        addressName: data['address_name'] as String?,
        roadNo: data['road_no'] as String?,
        houseNo: data['house_no'] as String?,
        houseName: data['house_name'] as dynamic,
        flatNo: data['flat_no'] as String?,
        block: data['block'] as dynamic,
        area: data['area'] as String?,
        subDistrictId: data['sub_district_id'] as dynamic,
        districtId: data['district_id'] as dynamic,
        addressLine: data['address_line'] as String?,
        addressLine2: data['address_line2'] as String?,
        deliveryNote: data['delivery_note'] as String?,
        postCode: data['post_code'] as String?,
        latitude: data['latitude'].toString(),
        longitude: data['longitude'].toString(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'address_name': addressName,
        'road_no': roadNo,
        'house_no': houseNo,
        'house_name': houseName,
        'flat_no': flatNo,
        'block': block,
        'area': area,
        'sub_district_id': subDistrictId,
        'district_id': districtId,
        'address_line': addressLine,
        'address_line2': addressLine2,
        'delivery_note': deliveryNote,
        'post_code': postCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Address].
  factory Address.fromJson(String data) {
    return Address.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Address] to a JSON string.
  String toJson() => json.encode(toMap());

  Address copyWith({
    int? id,
    String? addressName,
    String? roadNo,
    String? houseNo,
    dynamic houseName,
    String? flatNo,
    dynamic block,
    String? area,
    dynamic subDistrictId,
    dynamic districtId,
    String? addressLine,
    String? addressLine2,
    String? deliveryNote,
    String? postCode,
    String? latitude,
    String? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      addressName: addressName ?? this.addressName,
      roadNo: roadNo ?? this.roadNo,
      houseNo: houseNo ?? this.houseNo,
      houseName: houseName ?? this.houseName,
      flatNo: flatNo ?? this.flatNo,
      block: block ?? this.block,
      area: area ?? this.area,
      subDistrictId: subDistrictId ?? this.subDistrictId,
      districtId: districtId ?? this.districtId,
      addressLine: addressLine ?? this.addressLine,
      addressLine2: addressLine2 ?? this.addressLine2,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      postCode: postCode ?? this.postCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Address) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toMap(), toMap());
  }

  @override
  int get hashCode =>
      id.hashCode ^
      addressName.hashCode ^
      roadNo.hashCode ^
      houseNo.hashCode ^
      houseName.hashCode ^
      flatNo.hashCode ^
      block.hashCode ^
      area.hashCode ^
      subDistrictId.hashCode ^
      districtId.hashCode ^
      addressLine.hashCode ^
      addressLine2.hashCode ^
      deliveryNote.hashCode ^
      postCode.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;
}
