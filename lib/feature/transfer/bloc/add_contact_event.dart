import 'package:equatable/equatable.dart';

abstract class AddContactEvent extends Equatable {
  const AddContactEvent();

  @override
  List<Object?> get props => [];
}

class ContactNameChanged extends AddContactEvent {
  final String name;

  const ContactNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class ContactIdChanged extends AddContactEvent {
  final String contactId;

  const ContactIdChanged(this.contactId);

  @override
  List<Object?> get props => [contactId];
}

class AddContactSubmitted extends AddContactEvent {
  const AddContactSubmitted();
}
