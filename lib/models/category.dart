class Category {
  final int? id;
  final int walletId;
  final String name;

  Category({
    this.id,
    required this.walletId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_id': walletId,
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      walletId: map['wallet_id'],
      name: map['name'],
    );
  }
}
