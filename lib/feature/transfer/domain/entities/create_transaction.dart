import 'package:equatable/equatable.dart';
import 'contact.dart';

class CreateTransaction extends Equatable {
  final String coinSymbol;
  final String network;
  final Contact? recipient;
  final String? amount;
  final String? memo;

  const CreateTransaction({
    required this.coinSymbol,
    required this.network,
    this.recipient,
    this.amount,
    this.memo,
  });

  CreateTransaction copyWith({
    String? coinSymbol,
    String? network,
    Contact? recipient,
    String? amount,
    String? memo,
  }) {
    return CreateTransaction(
      coinSymbol: coinSymbol ?? this.coinSymbol,
      network: network ?? this.network,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
    );
  }

  @override
  List<Object?> get props => [coinSymbol, network, recipient, amount, memo];
}
