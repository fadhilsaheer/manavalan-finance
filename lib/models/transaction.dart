class FinanceTransaction {
  final int? id;
  final int walletId;
  final int? categoryId;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String? note;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime date;

  FinanceTransaction({
    this.id,
    required this.walletId,
    this.categoryId,
    required this.amount,
    required this.type,
    this.note,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'note': note,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'date': date.toIso8601String(),
    };
  }

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'],
      walletId: map['wallet_id'],
      categoryId: map['category_id'],
      amount: map['amount'],
      type: map['type'],
      note: map['note'],
      balanceBefore: map['balance_before'],
      balanceAfter: map['balance_after'],
      date: DateTime.parse(map['date']),
    );
  }
}
