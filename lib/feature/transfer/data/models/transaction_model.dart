import '../../domain/entities/transaction.dart';

class TransactionModel {
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
  final String status;

  const TransactionModel({
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

  Map<String, dynamic> toJson() => {
        'recipientName': recipientName,
        'recipientAddress': recipientAddress,
        'networkName': networkName,
        'amount': amount,
        'fee': fee,
        'total': total,
        'transactionId': transactionId,
        'timestamp': timestamp.toIso8601String(),
        'coinSymbol': coinSymbol,
        'memo': memo,
        'status': status,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        recipientName: json['recipientName'] as String,
        recipientAddress: json['recipientAddress'] as String,
        networkName: json['networkName'] as String,
        amount: json['amount'] as String,
        fee: json['fee'] as String,
        total: json['total'] as String,
        transactionId: json['transactionId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        coinSymbol: json['coinSymbol'] as String,
        memo: json['memo'] as String?,
        status: (json['status'] as String?) ?? 'success',
      );
}

extension TransactionModelMapper on TransactionModel {
  Transaction toEntity() {
    TransactionStatus entityStatus = TransactionStatus.success;
    if (status == 'pending') {
      entityStatus = TransactionStatus.pending;
    } else if (status == 'failed') {
      entityStatus = TransactionStatus.failed;
    }
    
    return Transaction(
      recipientName: recipientName,
      recipientAddress: recipientAddress,
      networkName: networkName,
      amount: amount,
      fee: fee,
      total: total,
      transactionId: transactionId,
      timestamp: timestamp,
      coinSymbol: coinSymbol,
      memo: memo,
      status: entityStatus,
    );
  }
}

extension TransactionMapper on Transaction {
  TransactionModel toModel() => TransactionModel(
        recipientName: recipientName,
        recipientAddress: recipientAddress,
        networkName: networkName,
        amount: amount,
        fee: fee,
        total: total,
        transactionId: transactionId,
        timestamp: timestamp,
        coinSymbol: coinSymbol,
        memo: memo,
        status: status.name,
      );
}
