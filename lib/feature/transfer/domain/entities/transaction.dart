import 'package:equatable/equatable.dart';

enum TransactionStatus {
  success,
  pending,
  failed;

  String get displayName {
    switch (this) {
      case TransactionStatus.success:
        return 'Successful';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}

class Transaction extends Equatable {
  final String recipientName;
  final String recipientAddress;
  final String networkName;
  final String amount;
  final String fee;
  final String total;
  final String transactionId;
  final DateTime timestamp;
  final String coinSymbol;
  final String? memo;
  final TransactionStatus status;

  const Transaction({
    required this.recipientName,
    required this.recipientAddress,
    required this.networkName,
    required this.amount,
    required this.fee,
    required this.total,
    required this.transactionId,
    required this.timestamp,
    required this.coinSymbol,
    required this.status,
    this.memo,
  });

  @override
  List<Object?> get props => [
        recipientName,
        recipientAddress,
        networkName,
        amount,
        fee,
        total,
        transactionId,
        timestamp,
        coinSymbol,
        memo,
        status,
      ];
}
