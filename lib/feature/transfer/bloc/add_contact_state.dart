import 'package:equatable/equatable.dart';
import '../domain/entities/contact.dart';

class AddContactState extends Equatable {
  final String name;
  final String contactId;
  final String? nameError;
  final String? contactIdError;
  final String detectedType;
  final bool isSubmitting;
  final bool isSuccess;
  final Contact? createdContact;
  final String? errorMessage;

  const AddContactState({
    this.name = '',
    this.contactId = '',
    this.nameError,
    this.contactIdError,
    this.detectedType = 'Unknown',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.createdContact,
    this.errorMessage,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      contactId.trim().isNotEmpty &&
      nameError == null &&
      contactIdError == null &&
      detectedType != 'Unknown';

  AddContactState copyWith({
    String? name,
    String? contactId,
    String? nameError,
    String? contactIdError,
    String? detectedType,
    bool? isSubmitting,
    bool? isSuccess,
    Contact? createdContact,
    String? errorMessage,
    bool clearNameError = false,
    bool clearContactIdError = false,
    bool clearErrorMessage = false,
  }) {
    return AddContactState(
      name: name ?? this.name,
      contactId: contactId ?? this.contactId,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      contactIdError: clearContactIdError ? null : (contactIdError ?? this.contactIdError),
      detectedType: detectedType ?? this.detectedType,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      createdContact: createdContact ?? this.createdContact,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        name,
        contactId,
        nameError,
        contactIdError,
        detectedType,
        isSubmitting,
        isSuccess,
        createdContact,
        errorMessage,
      ];
}
