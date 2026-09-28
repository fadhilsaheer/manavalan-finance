import 'package:intl/intl.dart';

typedef DbRow = Map<String, Object?>;

class LedgerError implements Exception {
  final String message;
  const LedgerError(this.message);
  @override
  String toString() => message;
}

const currencies = ['INR', 'USD', 'EUR', 'GBP', 'AED'];
const maxMoney = 1000000000000;

int parseMoney(String text, {bool signed = false, bool allowZero = false}) {
  final value = text.trim();
  if (!RegExp(signed ? r'^-?\d+(\.\d{1,2})?$' : r'^\d+(\.\d{1,2})?$')
      .hasMatch(value)) {
    throw const LedgerError(
      'Enter a valid amount with up to 2 decimal places.',
    );
  }
  final parts = value.replaceAll('-', '').split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null || whole > maxMoney ~/ 100) {
    throw const LedgerError('This amount is too large.');
  }
  var cents =
      whole * 100 +
      int.parse(parts.length == 2 ? parts[1].padRight(2, '0') : '0');
  if (value.startsWith('-')) cents = -cents;
  if (cents.abs() > maxMoney || (!allowZero && cents == 0)) {
    throw const LedgerError(
      'Enter an amount greater than zero and within the supported limit.',
    );
  }
  return cents;
}

String moneyInput(int cents) =>
    '${cents < 0 ? '-' : ''}${cents.abs() ~/ 100}.${(cents.abs() % 100).toString().padLeft(2, '0')}';
String money(int cents, String currency) => NumberFormat.currency(
  locale: currency == 'INR' ? 'en_IN' : 'en_US',
  symbol: switch (currency) {
    'INR' => '₹',
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'AED' => 'AED ',
    _ => '$currency ',
  },
  decimalDigits: 2,
).format(cents / 100);
String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
String prettyDay(String day) =>
    DateFormat('d MMM yyyy').format(DateTime.parse(day));
void requireName(String name) {
  if (name.trim().isEmpty || name.trim().length > 80) {
    throw const LedgerError('Use a name between 1 and 80 characters.');
  }
}

enum EntryKind {
  income,
  expense,
  loanAdvance,
  loanRepayment,
  transferIn,
  transferOut;

  String get label => switch (this) {
    income => 'Income',
    expense => 'Expense',
    loanAdvance => 'Loan advance',
    loanRepayment => 'Repayment',
    transferIn => 'Transfer in',
    transferOut => 'Transfer out',
  };
  bool get ordinary => this == income || this == expense;
}

class Wallet {
  final DbRow row;
  const Wallet(this.row);
  int get id => row['id'] as int;
  String get name => row['name'] as String;
  String get currency => row['currency'] as String;
  String get icon => row['icon'] as String;
  int get color => row['color'] as int;
  int get opening => row['opening'] as int;
  bool get archived => row['archived'] == 1;
}

class Category {
  final DbRow row;
  const Category(this.row);
  int get id => row['id'] as int;
  int get walletId => row['wallet_id'] as int;
  int? get parentId => row['parent_id'] as int?;
  String get name => row['name'] as String;
  String get kind => row['kind'] as String;
  String get icon => row['icon'] as String;
  int get position => row['position'] as int;
  bool get archived => row['archived'] == 1;
}

class LedgerGroup {
  final DbRow row;
  const LedgerGroup(this.row);
  int get id => row['id'] as int;
  int get walletId => row['wallet_id'] as int;
  String get name => row['name'] as String;
  String get note => row['note'] as String;
  String get icon => row['icon'] as String;
  bool get archived => row['archived'] == 1;
}

class Loan {
  final DbRow row;
  const Loan(this.row);
  int get id => row['id'] as int;
  int get walletId => row['wallet_id'] as int;
  String get person => row['person'] as String;
  String get direction => row['direction'] as String;
  bool get lent => direction == 'lent';
  String get date => row['date'] as String;
  String? get due => row['due'] as String?;
  int get opening => row['opening'] as int;
  String get note => row['note'] as String;
  bool get archived => row['archived'] == 1;
}

class Entry {
  final DbRow row;
  const Entry(this.row);
  int get id => row['id'] as int;
  int get walletId => row['wallet_id'] as int;
  int get amount => row['amount'] as int;
  int get sign => row['sign'] as int;
  int get signed => amount * sign;
  EntryKind get kind => EntryKind.values.byName(row['kind'] as String);
  String get date => row['date'] as String;
  String get note => row['note'] as String;
  int? get categoryId => row['category_id'] as int?;
  int? get groupId => row['group_id'] as int?;
  int? get loanId => row['loan_id'] as int?;
  int? get transferId => row['transfer_id'] as int?;
}

class LedgerSnapshot {
  final List<Wallet> wallets;
  final List<Category> categories;
  final List<LedgerGroup> groups;
  final List<Loan> loans;
  final List<Entry> entries;
  const LedgerSnapshot({
    this.wallets = const [],
    this.categories = const [],
    this.groups = const [],
    this.loans = const [],
    this.entries = const [],
  });
  int balance(Wallet w) =>
      w.opening +
      entries
          .where((e) => e.walletId == w.id)
          .fold(0, (sum, e) => sum + e.signed);
  int outstanding(Loan loan) =>
      loan.opening +
      entries
          .where((e) => e.loanId == loan.id)
          .fold(
            0,
            (sum, e) =>
                sum + (e.kind == EntryKind.loanAdvance ? e.amount : -e.amount),
          );
  int total(Iterable<Entry> rows, EntryKind kind) =>
      rows.where((e) => e.kind == kind).fold(0, (sum, e) => sum + e.amount);
  Category? category(int? id) =>
      categories.where((c) => c.id == id).firstOrNull;
  LedgerGroup? group(int? id) => groups.where((g) => g.id == id).firstOrNull;
  Loan? loan(int? id) => loans.where((l) => l.id == id).firstOrNull;
  String categoryName(int? id) {
    final c = category(id);
    if (c == null) return 'Uncategorised';
    final parent = category(c.parentId);
    return parent == null ? c.name : '${parent.name} / ${c.name}';
  }
}
