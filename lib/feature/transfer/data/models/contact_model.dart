import '../../domain/entities/contact.dart';

class ContactModel {
  final String name;
  final String bepayId;
  final String address;
  final String contactType;

  const ContactModel({
    required this.name,
    required this.bepayId,
    required this.address,
    required this.contactType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bepayId': bepayId,
      'address': address,
      'contactType': contactType,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['name'] as String,
      bepayId: json['bepayId'] as String,
      address: json['address'] as String,
      contactType: json['contactType'] as String,
    );
  }
}

extension ContactModelMapper on ContactModel {
  Contact toEntity() => Contact(
        name: name,
        bepayId: bepayId,
        address: address,
        contactType: contactType,
      );
}

extension ContactMapper on Contact {
  ContactModel toModel() => ContactModel(
        name: name,
        bepayId: bepayId,
        address: address,
        contactType: contactType,
      );
}
