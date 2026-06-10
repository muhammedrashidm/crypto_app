import 'package:equatable/equatable.dart';
import '../domain/entities/create_transaction.dart';

abstract class ReviewTransactionEvent extends Equatable {
  const ReviewTransactionEvent();

  @override
  List<Object?> get props => [];
}

class ConfirmReviewEvent extends ReviewTransactionEvent {
  final CreateTransaction createTx;

  const ConfirmReviewEvent({required this.createTx});

  @override
  List<Object?> get props => [createTx];
}

class InitReviewTransactionEvent extends ReviewTransactionEvent {
  final String coinSymbol;

  const InitReviewTransactionEvent({required this.coinSymbol});

  @override
  List<Object?> get props => [coinSymbol];
}

