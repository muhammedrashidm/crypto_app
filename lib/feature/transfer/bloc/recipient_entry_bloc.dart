import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/get_recent_recipients_usecase.dart';
import 'recipient_entry_event.dart';
import 'recipient_entry_state.dart';

@injectable
class RecipientEntryBloc extends Bloc<RecipientEntryEvent, RecipientEntryState> {
  final GetRecentRecipientsUseCase _getRecentRecipientsUseCase;

  RecipientEntryBloc(
    this._getRecentRecipientsUseCase,
  ) : super(const RecipientEntryState()) {
    on<LoadRecipientsEvent>(_onLoadRecipients);
  }

  String? _validateQuery(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return null;

    // 1. Check if it contains @ (bepayID or Email)
    if (clean.contains('@')) {
      if (clean.endsWith('@bepay')) {
        final usernamePart = clean.substring(0, clean.length - 7);
        final bepayIdReg = RegExp(r'^[a-zA-Z0-9]{3,}$');
        if (!bepayIdReg.hasMatch(usernamePart)) {
          return 'Invalid bepayID. Format: username@bepay (at least 3 alphanumeric chars)';
        }
        return null;
      } else {
        final emailReg = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailReg.hasMatch(clean)) {
          return 'Invalid email address format.';
        }
        return null;
      }
    }

    // 2. Check if it looks like a Wallet Address
    if (clean.startsWith('0x') || (clean.length == 42 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(clean))) {
      final ethReg = RegExp(r'^0x[a-fA-F0-9]{40}$');
      if (!ethReg.hasMatch(clean)) {
        return 'Invalid wallet address. Must start with 0x followed by 40 hex characters.';
      }
      return null;
    }

    // 3. Check if it looks like a Phone Number
    final isPhoneLike = clean.startsWith('+') || RegExp(r'^[0-9\s\-]+$').hasMatch(clean);
    if (isPhoneLike) {
      final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return 'Invalid phone number format.';
      }
      return null;
    }

    // 4. Otherwise, it's a Name search. No validation error.
    return null;
  }

  Future<void> _onLoadRecipients(
    LoadRecipientsEvent event,
    Emitter<RecipientEntryState> emit,
  ) async {
    final query = event.query ?? '';
    
    if (query.trim().isEmpty) {
      emit(state.copyWith(
        status: RecipientEntryStatus.loading,
        query: '',
        resetValidationError: true,
      ));
      final result = await _getRecentRecipientsUseCase(query: '');
      result.fold(
        (failure) => emit(state.copyWith(
          status: RecipientEntryStatus.failure,
          errorMessage: failure.message,
        )),
        (recipients) => emit(state.copyWith(
          recentRecipients: recipients,
          searchResults: const [],
          status: RecipientEntryStatus.success,
        )),
      );
      return;
    }

    final validationError = _validateQuery(query);
    if (validationError != null) {
      emit(state.copyWith(
        query: query,
        validationError: validationError,
        searchResults: const [],
        status: RecipientEntryStatus.success,
      ));
      return;
    }

    emit(state.copyWith(
      status: RecipientEntryStatus.loading,
      query: query,
      resetValidationError: true,
    ));
    
    final result = await _getRecentRecipientsUseCase(query: query);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RecipientEntryStatus.failure,
        errorMessage: failure.message,
      )),
      (recipients) => emit(state.copyWith(
        searchResults: recipients,
        status: RecipientEntryStatus.success,
      )),
    );
  }
}
