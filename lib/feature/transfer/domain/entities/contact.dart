import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String name;
  final String bepayId;
  final String address;
  final String contactType; // e.g. "Verified bepayID", "Ethereum Network", "External Contact"

  const Contact({
    required this.name,
    required this.bepayId,
    required this.address,
    required this.contactType,
  });

  bool get isExternalAddress => bepayId.isEmpty || !address.endsWith('@bepay');

  @override
  List<Object?> get props => [name, bepayId, address, contactType];
}
