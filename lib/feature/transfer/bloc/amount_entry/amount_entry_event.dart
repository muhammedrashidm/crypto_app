import 'package:equatable/equatable.dart';

abstract class AmountEntryEvent extends Equatable {
  const AmountEntryEvent();

  @override
  List<Object?> get props => [];
}

class FetchMaxAvailableEvent extends AmountEntryEvent {
  final String coinSymbol;
  final String network;

  const FetchMaxAvailableEvent({
    required this.coinSymbol,
    required this.network,
  });

  @override
  List<Object?> get props => [coinSymbol, network];
}

class UpdateAmountInputEvent extends AmountEntryEvent {
  final String digit;

  const UpdateAmountInputEvent(this.digit);

  @override
  List<Object?> get props => [digit];
}

class BackspaceAmountInputEvent extends AmountEntryEvent {
  const BackspaceAmountInputEvent();
}

class SetMaxAmountInputEvent extends AmountEntryEvent {
  const SetMaxAmountInputEvent();
}
