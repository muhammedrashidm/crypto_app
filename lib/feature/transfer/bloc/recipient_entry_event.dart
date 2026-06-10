import 'package:equatable/equatable.dart';

abstract class RecipientEntryEvent extends Equatable {
  const RecipientEntryEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipientsEvent extends RecipientEntryEvent {
  final String? query;

  const LoadRecipientsEvent({this.query});

  @override
  List<Object?> get props => [query];
}
