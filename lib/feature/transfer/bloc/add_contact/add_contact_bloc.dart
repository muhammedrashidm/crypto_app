import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/contact.dart';
import '../../domain/usecases/add_contact_usecase.dart';
import 'add_contact_event.dart';
import 'add_contact_state.dart';

@injectable
class AddContactBloc extends Bloc<AddContactEvent, AddContactState> {
  final AddContactUseCase _addContactUseCase;

  AddContactBloc(this._addContactUseCase) : super(const AddContactState()) {
    on<ContactNameChanged>(_onNameChanged);
    on<ContactIdChanged>(_onIdChanged);
    on<AddContactSubmitted>(_onSubmitted);
  }

  void _onNameChanged(ContactNameChanged event, Emitter<AddContactState> emit) {
    final name = event.name;
    final nameError = name.trim().isEmpty ? 'Name cannot be empty.' : null;
    
    emit(state.copyWith(
      name: name,
      nameError: nameError,
      clearNameError: nameError == null,
    ));
  }

  void _onIdChanged(ContactIdChanged event, Emitter<AddContactState> emit) {
    final rawId = event.contactId;
    final clean = rawId.trim();
    
    if (clean.isEmpty) {
      emit(state.copyWith(
        contactId: rawId,
        contactIdError: 'Contact ID cannot be empty.',
        detectedType: 'Unknown',
      ));
      return;
    }

    String? error;
    String type = 'Unknown';

    // 1. Check if it looks like bepayID
    if (clean.endsWith('@bepay')) {
      final usernamePart = clean.substring(0, clean.length - 7);
      final bepayIdReg = RegExp(r'^[a-zA-Z0-9]{3,}$');
      if (!bepayIdReg.hasMatch(usernamePart)) {
        error = 'Invalid bepayID. Minimum 3 alphanumeric characters before @bepay.';
      } else {
        type = 'Verified bepayID';
      }
    }
    // 2. Check if it looks like a wallet address
    else if (clean.startsWith('0x') || (clean.length == 42 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(clean))) {
      final ethReg = RegExp(r'^0x[a-fA-F0-9]{40}$');
      if (!ethReg.hasMatch(clean)) {
        error = 'Invalid wallet address. Must start with 0x followed by 40 hex characters.';
      } else {
        type = 'Ethereum Network';
      }
    }
    // 3. Check if it looks like a phone number
    else if (clean.startsWith('+') || RegExp(r'^[0-9\s\-]+$').hasMatch(clean)) {
      final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
      if (!clean.startsWith('+')) {
        error = 'Phone number must start with + followed by country code.';
      } else if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        error = 'Invalid phone number length. Must be 7 to 15 digits.';
      } else {
        type = 'External Contact (Phone)';
      }
    }
    // 4. Check if it looks like an email
    else if (clean.contains('@')) {
      final emailReg = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailReg.hasMatch(clean)) {
        error = 'Invalid email address format.';
      } else {
        type = 'External Contact (Email)';
      }
    }
    // 5. No match
    else {
      error = 'Invalid ID format. Enter a valid bepayID, wallet address, email, or phone.';
    }

    emit(state.copyWith(
      contactId: rawId,
      contactIdError: error,
      detectedType: type,
      clearContactIdError: error == null,
    ));
  }

  Future<void> _onSubmitted(AddContactSubmitted event, Emitter<AddContactState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    final cleanId = state.contactId.trim();
    final contact = Contact(
      name: state.name.trim(),
      address: cleanId,
      bepayId: state.detectedType == 'Verified bepayID' ? cleanId : '',
      contactType: state.detectedType,
    );

    final result = await _addContactUseCase(contact);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        createdContact: contact,
      )),
    );
  }
}
