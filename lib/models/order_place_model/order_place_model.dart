// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:flutter/foundation.dart';

class OrderPlaceModel {
  String franchise_id;
  String vendor_id;
  String deliver_type;
  String pick_date;
  String pick_hour;
  String delivery_date;
  String delivery_hour;
  List<OrderProductModel> products;
  String address_id;
  String? coupon_id;
  String? instruction;
  String? payment_type;
  List<String> additional_service_id;
  OrderPlaceModel({
    required this.franchise_id,
    required this.vendor_id,
    required this.deliver_type,
    required this.pick_date,
    required this.pick_hour,
    required this.delivery_date,
    required this.delivery_hour,
    required this.products,
    required this.address_id,
    this.coupon_id,
    this.instruction,
    required this.payment_type,
    required this.additional_service_id,
  });

  OrderPlaceModel copyWith({
    String? franchise_id,
    String? vendor_id,
    String? deliver_type,
    String? pick_date,
    String? pick_hour,
    String? delivery_date,
    String? delivery_hour,
    List<OrderProductModel>? products,
    String? address_id,
    String? coupon_id,
    String? instruction,
    String? payment_type,
    List<String>? additional_service_id,
  }) {
    return OrderPlaceModel(
      franchise_id: franchise_id ?? this.franchise_id,
      vendor_id: vendor_id ?? this.vendor_id,
      deliver_type: deliver_type ?? this.deliver_type,
      pick_date: pick_date ?? this.pick_date,
      pick_hour: pick_hour ?? this.pick_hour,
      delivery_date: delivery_date ?? this.delivery_date,
      delivery_hour: delivery_hour ?? this.delivery_hour,
      products: products ?? this.products,
      address_id: address_id ?? this.address_id,
      coupon_id: coupon_id ?? this.coupon_id,
      instruction: instruction ?? this.instruction,
      payment_type: payment_type ?? this.payment_type,
      additional_service_id:
          additional_service_id ?? this.additional_service_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'franchise_id': franchise_id,
      'vendor_id': vendor_id,
      'deliver_type': deliver_type,
      'pick_date': pick_date,
      'pick_hour': pick_hour,
      'delivery_date': delivery_date,
      'delivery_hour': delivery_hour,
      'products': products.map((x) => x.toMap()).toList(),
      'address_id': address_id,
      'coupon_id': coupon_id,
      'instruction': instruction,
      'payment_type': payment_type,
      'additional_service_id': additional_service_id,
    };
  }

  factory OrderPlaceModel.fromMap(Map<String, dynamic> map) {
    return OrderPlaceModel(
      franchise_id: map['franchise_id'] as String,
      vendor_id: map['vendor_id'] as String,
      deliver_type: map['deliver_type'] as String,
      pick_date: map['pick_date'] as String,
      pick_hour: map['pick_hour'] as String,
      delivery_date: map['delivery_date'] as String,
      delivery_hour: map['delivery_hour'] as String,
      payment_type: map['payment_type'] as String,
      products: List<OrderProductModel>.from(
        (map['products'] as List<int>).map<OrderProductModel>(
          (x) => OrderProductModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      address_id: map['address_id'] as String,
      coupon_id: map['coupon_id'] != null ? map['coupon_id'] as String : null,
      instruction:
          map['instruction'] != null ? map['instruction'] as String : null,
      additional_service_id: List<String>.from(
        map['additional_service_id'] as List<String>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderPlaceModel.fromJson(String source) =>
      OrderPlaceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderPlaceModel('
        ' franchise_id : $franchise_id ,vendor_id : $vendor_id ,deliver_type : $deliver_type ,'
        ' pick_date: $pick_date, pick_hour: $pick_hour,payment_type: $payment_type, delivery_date: $delivery_date, delivery_hour: $delivery_hour, products: $products, address_id: $address_id, coupon_id: $coupon_id, instruction: $instruction, additional_service_id: $additional_service_id)';
  }

  @override
  bool operator ==(covariant OrderPlaceModel other) {
    if (identical(this, other)) return true;

    return other.vendor_id == vendor_id &&
        other.deliver_type == deliver_type &&
        other.pick_date == pick_date &&
        other.pick_hour == pick_hour &&
        other.delivery_date == delivery_date &&
        other.delivery_hour == delivery_hour &&
        listEquals(other.products, products) &&
        other.address_id == address_id &&
        other.coupon_id == coupon_id &&
        other.payment_type == payment_type &&
        other.instruction == instruction &&
        listEquals(other.additional_service_id, additional_service_id);
  }

  @override
  int get hashCode {
    return vendor_id.hashCode ^
        deliver_type.hashCode ^
        pick_date.hashCode ^
        pick_hour.hashCode ^
        delivery_date.hashCode ^
        delivery_hour.hashCode ^
        products.hashCode ^
        address_id.hashCode ^
        coupon_id.hashCode ^
        payment_type.hashCode ^
        instruction.hashCode ^
        additional_service_id.hashCode;
  }
}

class OrderProductModel {
  String id;
  String quantity;
  String? subid;
  OrderProductModel({
    required this.id,
    required this.quantity,
    this.subid,
  });

  OrderProductModel copyWith({
    String? id,
    String? quantity,
    String? subid,
  }) {
    return OrderProductModel(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      subid: subid ?? this.subid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'quantity': quantity,
      "sub_product_id": subid
    };
  }

  factory OrderProductModel.fromMap(Map<String, dynamic> map) {
    return OrderProductModel(
      id: map['id'] as String,
      quantity: map['quantity'] as String,
      subid: map['sub_product_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderProductModel.fromJson(String source) =>
      OrderProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'OrderProductModel(id: $id,  quantity: $quantity, sub_product_id: $subid)';

  @override
  bool operator ==(covariant OrderProductModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.quantity == quantity && other.subid == subid;
  }

  @override
  int get hashCode => id.hashCode ^ quantity.hashCode ^ subid.hashCode;
}
