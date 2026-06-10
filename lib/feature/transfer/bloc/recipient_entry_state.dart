import 'package:equatable/equatable.dart';
import '../domain/entities/contact.dart';

enum RecipientEntryStatus { initial, loading, success, failure }

class RecipientEntryState extends Equatable {
  final List<Contact> recentRecipients;
  final List<Contact> searchResults;
  final String? validationError;
  final String query;
  final RecipientEntryStatus status;
  final String? errorMessage;

  const RecipientEntryState({
    this.recentRecipients = const [],
    this.searchResults = const [],
    this.validationError,
    this.query = '',
    this.status = RecipientEntryStatus.initial,
    this.errorMessage,
  });

  RecipientEntryState copyWith({
    List<Contact>? recentRecipients,
    List<Contact>? searchResults,
    String? validationError,
    String? query,
    RecipientEntryStatus? status,
    String? errorMessage,
    bool resetValidationError = false,
  }) {
    return RecipientEntryState(
      recentRecipients: recentRecipients ?? this.recentRecipients,
      searchResults: searchResults ?? this.searchResults,
      validationError: resetValidationError ? null : (validationError ?? this.validationError),
      query: query ?? this.query,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        recentRecipients,
        searchResults,
        validationError,
        query,
        status,
        errorMessage,
      ];
}
