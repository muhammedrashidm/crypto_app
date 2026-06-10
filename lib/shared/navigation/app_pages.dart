enum AppPages {
  walletHome('/wallet', 'WalletHome'),
  recentTransactions('/recent-transactions', 'RecentTransactions'),
  recipientEntry('/transfer/recipient', 'RecipientEntry'),
  amountEntry('/transfer/amount', 'AmountEntry'),
  reviewTransaction('/transfer/review', 'ReviewTransaction'),
  pinConfirmation('/transfer/pin', 'PinConfirmation'),
  transactionResult('/transfer/result', 'TransactionResult'),
  addContact('/transfer/add-contact', 'AddContact'),
  qrScanner('/transfer/qr-scanner', 'QrScanner');

  final String path;
  final String name;

  const AppPages(this.path, this.name);
}
