class Wallet {
  final int? id;
  final String name;
  double balance;
  final double openingBalance;

  Wallet({
    this.id,
    required this.name,
    required this.openingBalance,
    this.balance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'opening_balance': openingBalance,
      'balance': balance,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      openingBalance: map['opening_balance'],
      balance: map['balance'],
    );
  }
}
