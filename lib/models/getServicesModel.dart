class GetServicesModel {
  String? message;
  Data? data;

  GetServicesModel({this.message, this.data});

  GetServicesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'].toString();
    data = json['data'] != null ? new Data.fromJson(json['data']as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Services>? services;

  Data({this.services});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? id;
  String? name;
  String? nameBn;
  String? description;
  String? descriptionBn;
  String? imagePath;

  Services(
      {this.id,
        this.name,
        this.nameBn,
        this.description,
        this.descriptionBn,
        this.imagePath});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    nameBn = json['name_bn'].toString();
    description = json['description'].toString();
    descriptionBn = json['description_bn'].toString();
    imagePath = json['image_path'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_bn'] = this.nameBn;
    data['description'] = this.description;
    data['description_bn'] = this.descriptionBn;
    data['image_path'] = this.imagePath;
    return data;
  }
}