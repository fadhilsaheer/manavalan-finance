import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/models.dart';
import 'seeds.dart';

class LedgerStore {
  final Database db;
  LedgerStore(this.db);
  static const tables = [
    'wallets',
    'categories',
    'groups',
    'loans',
    'transfers',
    'entries',
    'settings',
  ];

  static Future<LedgerStore> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final f = factory ?? databaseFactory;
    final file = path ?? p.join(await f.getDatabasesPath(), 'manavalan.db');
    return LedgerStore(
      await f.openDatabase(
        file,
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: schema,
        ),
      ),
    );
  }

  static Future<void> schema(Database db, int version) async {
    await db.execute('''CREATE TABLE wallets (
      id INTEGER PRIMARY KEY, name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 80),
      currency TEXT NOT NULL CHECK(currency IN ('INR','USD','EUR','GBP','AED')),
      opening INTEGER NOT NULL CHECK(typeof(opening) = 'integer' AND abs(opening) <= $maxMoney),
      icon TEXT NOT NULL DEFAULT 'wallet', color INTEGER NOT NULL DEFAULT 0,
      archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)))''');
    await db.execute(
      '''CREATE TABLE categories (
      id INTEGER PRIMARY KEY, wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
      parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
      name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 80),
      kind TEXT NOT NULL CHECK(kind IN ('income','expense')), icon TEXT NOT NULL,
      position INTEGER NOT NULL DEFAULT 0, archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)))''',
    );
    await db.execute(
      '''CREATE TABLE groups (
      id INTEGER PRIMARY KEY, wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
      name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 80), note TEXT NOT NULL DEFAULT '',
      icon TEXT NOT NULL DEFAULT 'group', archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)))''',
    );
    await db.execute('''CREATE TABLE loans (
      id INTEGER PRIMARY KEY, wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
      person TEXT NOT NULL CHECK(length(trim(person)) BETWEEN 1 AND 80),
      direction TEXT NOT NULL CHECK(direction IN ('lent','borrowed')),
      opening INTEGER NOT NULL DEFAULT 0 CHECK(typeof(opening) = 'integer' AND opening BETWEEN 0 AND $maxMoney),
      date TEXT NOT NULL, due TEXT, note TEXT NOT NULL DEFAULT '',
      archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)))''');
    await db.execute(
      '''CREATE TABLE transfers (
      id INTEGER PRIMARY KEY, from_wallet INTEGER NOT NULL REFERENCES wallets(id),
      to_wallet INTEGER NOT NULL REFERENCES wallets(id),
      amount INTEGER NOT NULL CHECK(typeof(amount) = 'integer' AND amount BETWEEN 1 AND $maxMoney),
      date TEXT NOT NULL, note TEXT NOT NULL DEFAULT '', CHECK(from_wallet != to_wallet))''',
    );
    await db.execute('''CREATE TABLE entries (
      id INTEGER PRIMARY KEY, wallet_id INTEGER NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
      amount INTEGER NOT NULL CHECK(typeof(amount) = 'integer' AND amount BETWEEN 1 AND $maxMoney),
      sign INTEGER NOT NULL CHECK(sign IN (-1,1)),
      kind TEXT NOT NULL CHECK(kind IN ('income','expense','loanAdvance','loanRepayment','transferIn','transferOut')),
      date TEXT NOT NULL, note TEXT NOT NULL DEFAULT '',
      category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
      group_id INTEGER REFERENCES groups(id) ON DELETE SET NULL,
      loan_id INTEGER REFERENCES loans(id) ON DELETE CASCADE,
      transfer_id INTEGER REFERENCES transfers(id) ON DELETE CASCADE,
      CHECK((kind IN ('income','expense') AND loan_id IS NULL AND transfer_id IS NULL)
        OR (kind IN ('loanAdvance','loanRepayment') AND loan_id IS NOT NULL AND transfer_id IS NULL AND category_id IS NULL AND group_id IS NULL)
        OR (kind IN ('transferIn','transferOut') AND transfer_id IS NOT NULL AND loan_id IS NULL AND category_id IS NULL AND group_id IS NULL)),
      CHECK(kind NOT IN ('income','transferIn') OR sign = 1),
      CHECK(kind NOT IN ('expense','transferOut') OR sign = -1))''');
    await db.execute(
      'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE INDEX entries_wallet_date ON entries(wallet_id,date DESC,id DESC)',
    );
    await db.execute('CREATE INDEX entries_group ON entries(group_id)');
    await db.execute('CREATE INDEX entries_loan ON entries(loan_id)');
    await db.execute(
      'CREATE INDEX categories_wallet ON categories(wallet_id,parent_id)',
    );
  }

  Future<LedgerSnapshot> snapshot() async => db.transaction(
    (txn) async => LedgerSnapshot(
      wallets: (await txn.query(
        'wallets',
        orderBy: 'archived, id',
      )).map(Wallet.new).toList(),
      categories: (await txn.query(
        'categories',
        orderBy: 'position, id',
      )).map(Category.new).toList(),
      groups: (await txn.query(
        'groups',
        orderBy: 'archived, name COLLATE NOCASE',
      )).map(LedgerGroup.new).toList(),
      loans: (await txn.query(
        'loans',
        orderBy: 'archived, date DESC, id DESC',
      )).map(Loan.new).toList(),
      entries: (await txn.query(
        'entries',
        orderBy: 'date DESC, id DESC',
      )).map(Entry.new).toList(),
    ),
  );

  Future<String?> setting(String key) async =>
      (await db.query(
            'settings',
            where: 'key = ?',
            whereArgs: [key],
          )).firstOrNull?['value']
          as String?;
  Future<void> setSetting(String key, String value) async {
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Wallet> _wallet(
    DatabaseExecutor txn,
    int id, {
    bool active = true,
  }) async {
    final rows = await txn.query('wallets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty || (active && rows.first['archived'] == 1)) {
      throw const LedgerError('Select an active wallet.');
    }
    return Wallet(rows.first);
  }

  void _amount(int amount, {bool signed = false, bool zero = false}) {
    if (amount.abs() > maxMoney ||
        (!signed && amount < 0) ||
        (!zero && amount == 0)) {
      throw const LedgerError('Invalid amount.');
    }
  }

  void _date(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null || dayKey(parsed) != date) {
      throw const LedgerError('Choose a valid date.');
    }
  }

  Future<int> saveWallet({
    int? id,
    required String name,
    required String currency,
    required int opening,
    String icon = 'wallet',
    int color = 0,
  }) async {
    requireName(name);
    _amount(opening, signed: true, zero: true);
    if (!currencies.contains(currency)) {
      throw const LedgerError('Choose a supported currency.');
    }
    return db.transaction((txn) async {
      if (id != null) {
        final old = await _wallet(txn, id, active: false);
        if (old.currency != currency &&
            (await txn.query(
              'entries',
              where: 'wallet_id = ?',
              whereArgs: [id],
              limit: 1,
            )).isNotEmpty) {
          throw const LedgerError(
            'Currency cannot change after transactions are recorded.',
          );
        }
        if (old.currency != currency &&
            (await txn.query(
              'loans',
              where: 'wallet_id = ?',
              whereArgs: [id],
              limit: 1,
            )).isNotEmpty) {
          throw const LedgerError('Currency cannot change while loans exist.');
        }
        await txn.update(
          'wallets',
          {
            'name': name.trim(),
            'currency': currency,
            'opening': opening,
            'icon': icon,
            'color': color,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        return id;
      }
      final walletId = await txn.insert('wallets', {
        'name': name.trim(),
        'currency': currency,
        'opening': opening,
        'icon': icon,
        'color': color,
      });
      for (final (name, kind, icon, children) in starterCategories) {
        final parentId = await txn.insert('categories', {
          'wallet_id': walletId,
          'name': name,
          'kind': kind,
          'icon': icon,
        });
        for (var i = 0; i < children.length; i++) {
          await txn.insert('categories', {
            'wallet_id': walletId,
            'parent_id': parentId,
            'name': children[i],
            'kind': kind,
            'icon': icon,
            'position': i,
          });
        }
      }
      return walletId;
    });
  }

  Future<void> archiveWallet(int id, bool archive) async {
    await db.update(
      'wallets',
      {'archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWallet(int id) async => db.transaction((txn) async {
    if ((await txn.query(
      'transfers',
      where: 'from_wallet = ? OR to_wallet = ?',
      whereArgs: [id, id],
      limit: 1,
    )).isNotEmpty) {
      throw const LedgerError(
        'This wallet has transfers. Archive it, or remove its transfers before deleting it.',
      );
    }
    await txn.delete('wallets', where: 'id = ?', whereArgs: [id]);
  });

  Future<int> saveCategory({
    int? id,
    required int walletId,
    int? parentId,
    required String name,
    required String kind,
    required String icon,
    int position = 0,
  }) async {
    requireName(name);
    if (!['income', 'expense'].contains(kind)) {
      throw const LedgerError('Choose income or expense.');
    }
    return db.transaction((txn) async {
      await _wallet(txn, walletId);
      if (parentId != null) {
        final parents = await txn.query(
          'categories',
          where: 'id = ? AND wallet_id = ? AND parent_id IS NULL AND kind = ? AND archived = 0',
          whereArgs: [parentId, walletId, kind],
        );
        if (parents.isEmpty || parentId == id) {
          throw const LedgerError(
            'Choose an active main category of the same type.',
          );
        }
      }
      if (id != null) {
        final old = (await txn.query(
          'categories',
          where: 'id = ? AND wallet_id = ?',
          whereArgs: [id, walletId],
        )).firstOrNull;
        if (old == null) throw const LedgerError('Category not found.');
        final children = await txn.query(
          'categories',
          where: 'parent_id = ?',
          whereArgs: [id],
        );
        if (parentId != null && children.isNotEmpty) {
          throw const LedgerError('Move this category’s subcategories first.');
        }
        final ids = [id, ...children.map((c) => c['id'])];
        if (old['kind'] != kind &&
            (await txn.rawQuery(
              'SELECT id FROM entries WHERE category_id IN (${List.filled(ids.length, '?').join(',')}) LIMIT 1',
              ids,
            )).isNotEmpty) {
          throw const LedgerError(
            'A used category cannot change between income and expense.',
          );
        }
        await txn.update(
          'categories',
          {
            'name': name.trim(),
            'kind': kind,
            'icon': icon,
            'parent_id': parentId,
            'position': position,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        await txn.update(
          'categories',
          {'kind': kind},
          where: 'parent_id = ?',
          whereArgs: [id],
        );
        return id;
      }
      return txn.insert('categories', {
        'wallet_id': walletId,
        'parent_id': parentId,
        'name': name.trim(),
        'kind': kind,
        'icon': icon,
        'position': position,
      });
    });
  }

  Future<void> archiveCategory(int id, bool archive) async =>
      db.transaction((txn) async {
        final row = (await txn.query(
          'categories',
          where: 'id = ?',
          whereArgs: [id],
        )).first;
        if (!archive && row['parent_id'] != null) {
          final parent = (await txn.query(
            'categories',
            where: 'id = ?',
            whereArgs: [row['parent_id']],
          )).first;
          if (parent['archived'] == 1) {
            throw const LedgerError('Restore the main category first.');
          }
        }
        await txn.update(
          'categories',
          {'archived': archive ? 1 : 0},
          where: 'id = ? OR parent_id = ?',
          whereArgs: [id, id],
        );
      });
  Future<void> deleteCategory(int id) async {
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveGroup({
    int? id,
    required int walletId,
    required String name,
    String note = '',
    String icon = 'group',
  }) async {
    requireName(name);
    return db.transaction((txn) async {
      await _wallet(txn, walletId);
      if (id != null) {
        final changed = await txn.update(
          'groups',
          {'name': name.trim(), 'note': note, 'icon': icon},
          where: 'id = ? AND wallet_id = ?',
          whereArgs: [id, walletId],
        );
        if (changed == 0) throw const LedgerError('Group not found.');
        return id;
      }
      return txn.insert('groups', {
        'wallet_id': walletId,
        'name': name.trim(),
        'note': note,
        'icon': icon,
      });
    });
  }

  Future<void> archiveGroup(int id, bool archive) async {
    await db.update(
      'groups',
      {'archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> dissolveGroup(int id, {required bool deleteEntries}) async =>
      db.transaction((txn) async {
        if (deleteEntries) {
          await txn.delete('entries', where: 'group_id = ?', whereArgs: [id]);
        }
        await txn.delete('groups', where: 'id = ?', whereArgs: [id]);
      });

  Future<int> saveEntry({
    int? id,
    required int walletId,
    required int amount,
    required EntryKind kind,
    required String date,
    String note = '',
    int? categoryId,
    int? groupId,
  }) async {
    _amount(amount);
    _date(date);
    if (!kind.ordinary) {
      throw const LedgerError(
        'Use the loan or transfer workflow for this entry.',
      );
    }
    return db.transaction((txn) async {
      await _wallet(txn, walletId);
      if (categoryId != null) {
        final row = (await txn.query(
          'categories',
          where: 'id = ? AND wallet_id = ? AND kind = ?',
          whereArgs: [categoryId, walletId, kind.name],
        )).firstOrNull;
        if (row == null || (row['archived'] == 1 && id == null)) {
          throw const LedgerError(
            'Choose a category in this wallet matching the transaction type.',
          );
        }
      }
      if (groupId != null) {
        final row = (await txn.query(
          'groups',
          where: 'id = ? AND wallet_id = ?',
          whereArgs: [groupId, walletId],
        )).firstOrNull;
        if (row == null || (row['archived'] == 1 && id == null)) {
          throw const LedgerError('Choose an active group in this wallet.');
        }
      }
      final values = {
        'wallet_id': walletId,
        'amount': amount,
        'sign': kind == EntryKind.income ? 1 : -1,
        'kind': kind.name,
        'date': date,
        'note': note.trim(),
        'category_id': categoryId,
        'group_id': groupId,
      };
      if (id != null) {
        final changed = await txn.update(
          'entries',
          values,
          where: "id = ? AND wallet_id = ? AND kind IN ('income','expense')",
          whereArgs: [id, walletId],
        );
        if (changed == 0) {
          throw const LedgerError(
            'Transaction not found or managed by a loan/transfer.',
          );
        }
        return id;
      }
      return txn.insert('entries', values);
    });
  }

  Future<int> createLoan({
    required int walletId,
    required String person,
    required String direction,
    required int amount,
    required String date,
    String? due,
    String note = '',
    bool openingOnly = false,
  }) async {
    requireName(person);
    _amount(amount);
    _date(date);
    if (due != null) _date(due);
    if (due != null && due.compareTo(date) < 0) {
      throw const LedgerError('Due date must be on or after the loan date.');
    }
    if (!['lent', 'borrowed'].contains(direction)) {
      throw const LedgerError('Choose lent or borrowed.');
    }
    return db.transaction((txn) async {
      await _wallet(txn, walletId);
      final id = await txn.insert('loans', {
        'wallet_id': walletId,
        'person': person.trim(),
        'direction': direction,
        'opening': openingOnly ? amount : 0,
        'date': date,
        'due': due,
        'note': note.trim(),
      });
      if (!openingOnly) {
        await txn.insert('entries', {
          'wallet_id': walletId,
          'loan_id': id,
          'amount': amount,
          'sign': direction == 'lent' ? -1 : 1,
          'kind': EntryKind.loanAdvance.name,
          'date': date,
          'note': note.trim(),
        });
      }
      return id;
    });
  }

  Future<void> updateLoan(
    int id, {
    required String person,
    String? due,
    String note = '',
  }) async {
    requireName(person);
    if (due != null) _date(due);
    final loan = Loan(
      (await db.query('loans', where: 'id = ?', whereArgs: [id])).first,
    );
    if (due != null && due.compareTo(loan.date) < 0) {
      throw const LedgerError('Due date must be on or after the loan date.');
    }
    await db.update(
      'loans',
      {'person': person.trim(), 'due': due, 'note': note.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> loanMovement(
    int loanId, {
    required int amount,
    required bool repayment,
    required String date,
    String note = '',
  }) async {
    _amount(amount);
    _date(date);
    await db.transaction((txn) async {
      final loan = Loan(
        (await txn.query('loans', where: 'id = ?', whereArgs: [loanId])).first,
      );
      await _wallet(txn, loan.walletId);
      if (loan.archived) {
        throw const LedgerError('Restore this loan before adding entries.');
      }
      if (date.compareTo(loan.date) < 0) {
        throw const LedgerError(
          'An entry cannot be earlier than the loan date.',
        );
      }
      await txn.insert('entries', {
        'wallet_id': loan.walletId,
        'loan_id': loanId,
        'amount': amount,
        'kind': repayment ? 'loanRepayment' : 'loanAdvance',
        'sign': (loan.lent != repayment) ? -1 : 1,
        'date': date,
        'note': note.trim(),
      });
      await _checkLoans(txn);
    });
  }

  static Future<void> _checkLoans(DatabaseExecutor txn) async {
    for (final row in await txn.query('loans')) {
      final loan = Loan(row);
      var balance = loan.opening;
      for (final row in await txn.query(
        'entries',
        where: 'loan_id = ?',
        whereArgs: [loan.id],
        orderBy: 'date, id',
      )) {
        final e = Entry(row);
        if (e.walletId != loan.walletId ||
            e.date.compareTo(loan.date) < 0 ||
            e.sign !=
                ((loan.lent != (e.kind == EntryKind.loanRepayment)) ? -1 : 1)) {
          throw const LedgerError('Invalid linked loan transaction.');
        }
        balance += e.kind == EntryKind.loanAdvance ? e.amount : -e.amount;
        if (balance < 0) {
          throw const LedgerError(
            'Repayment exceeds the amount outstanding on that date.',
          );
        }
        if (balance > maxMoney) {
          throw const LedgerError(
            'The outstanding amount exceeds the supported limit.',
          );
        }
      }
    }
  }

  Future<void> archiveLoan(int id, bool archive) async {
    await db.update(
      'loans',
      {'archived': archive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteLoan(int id) async {
    await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteEntry(int id) async => db.transaction((txn) async {
    final row = (await txn.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    )).firstOrNull;
    if (row == null) return;
    if (row['transfer_id'] != null) {
      await txn.delete(
        'transfers',
        where: 'id = ?',
        whereArgs: [row['transfer_id']],
      );
    } else {
      await txn.delete('entries', where: 'id = ?', whereArgs: [id]);
      if (row['loan_id'] != null) await _checkLoans(txn);
    }
  });

  Future<int> transfer({
    required int from,
    required int to,
    required int amount,
    required String date,
    String note = '',
  }) async {
    _amount(amount);
    _date(date);
    return db.transaction((txn) async {
      final source = await _wallet(txn, from);
      final dest = await _wallet(txn, to);
      if (from == to || source.currency != dest.currency) {
        throw const LedgerError(
          'Choose two different wallets with the same currency.',
        );
      }
      final id = await txn.insert('transfers', {
        'from_wallet': from,
        'to_wallet': to,
        'amount': amount,
        'date': date,
        'note': note.trim(),
      });
      for (final (wallet, kind, sign) in [
        (from, 'transferOut', -1),
        (to, 'transferIn', 1),
      ]) {
        await txn.insert('entries', {
          'wallet_id': wallet,
          'kind': kind,
          'sign': sign,
          'transfer_id': id,
          'amount': amount,
          'date': date,
          'note': note.trim(),
        });
      }
      return id;
    });
  }

  Future<String> backup() async => db.transaction((txn) async {
    final data = <String, Object?>{
      'format': 'manavalan-finance',
      'version': 1,
      'created': DateTime.now().toUtc().toIso8601String(),
    };
    for (final table in tables) {
      data[table] = await txn.query(table);
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  });

  Future<void> restore(String json) async {
    if (json.length > 20000000) {
      throw const LedgerError('Backup is too large (maximum 20 MB).');
    }
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      data = decoded;
      if (data['format'] != 'manavalan-finance' || data['version'] != 1) {
        throw const FormatException();
      }
      for (final table in tables) {
        if (data[table] is! List || (data[table] as List).length > 100000) {
          throw const FormatException();
        }
        for (final row in data[table] as List) {
          if (row is! Map<String, dynamic> ||
              row.values.any((v) => v != null && v is! String && v is! int)) {
            throw const FormatException();
          }
        }
      }
    } catch (_) {
      throw const LedgerError(
        'This is not a supported Manavalan Finance backup.',
      );
    }
    try {
      await db.transaction((txn) async {
        for (final table in tables.reversed) {
          await txn.delete(table);
        }
        for (final table in tables) {
          for (final row in data[table] as List) {
            await txn.insert(table, Map<String, Object?>.from(row as Map));
          }
        }
        await _validate(txn);
      });
    } on LedgerError {
      rethrow;
    } catch (_) {
      throw const LedgerError(
        'Backup contains invalid or incomplete data. Your current data is unchanged.',
      );
    }
  }

  static Future<void> _validate(DatabaseExecutor txn) async {
    for (final table in ['entries', 'loans', 'transfers']) {
      for (final row in await txn.query(table)) {
        for (final field in ['date', if (table == 'loans') 'due']) {
          final value = row[field];
          if (value != null &&
              (value is! String ||
                  DateTime.tryParse(value) == null ||
                  dayKey(DateTime.parse(value)) != value)) {
            throw const LedgerError('Backup contains an invalid date.');
          }
        }
        if (table == 'loans' &&
            row['due'] != null &&
            (row['due'] as String).compareTo(row['date'] as String) < 0) {
          throw const LedgerError('Backup contains an invalid due date.');
        }
      }
    }
    final invalid = await txn.rawQuery(
      '''SELECT c.id FROM categories c JOIN categories p ON c.parent_id = p.id WHERE c.wallet_id != p.wallet_id OR c.kind != p.kind OR p.parent_id IS NOT NULL OR c.id = p.id
      UNION ALL SELECT e.id FROM entries e JOIN categories c ON e.category_id = c.id WHERE e.wallet_id != c.wallet_id OR e.kind != c.kind
      UNION ALL SELECT e.id FROM entries e JOIN groups g ON e.group_id = g.id WHERE e.wallet_id != g.wallet_id''',
    );
    if (invalid.isNotEmpty) {
      throw const LedgerError(
        'Backup contains inconsistent category or group links.',
      );
    }
    for (final row in await txn.query('transfers')) {
      final from = Wallet(
        (await txn.query(
          'wallets',
          where: 'id = ?',
          whereArgs: [row['from_wallet']],
        )).first,
      );
      final to = Wallet(
        (await txn.query(
          'wallets',
          where: 'id = ?',
          whereArgs: [row['to_wallet']],
        )).first,
      );
      final entries = (await txn.query(
        'entries',
        where: 'transfer_id = ?',
        whereArgs: [row['id']],
      )).map(Entry.new).toList();
      if (from.currency != to.currency ||
          entries.length != 2 ||
          !entries.any(
            (e) => e.walletId == from.id && e.kind == EntryKind.transferOut,
          ) ||
          !entries.any(
            (e) => e.walletId == to.id && e.kind == EntryKind.transferIn,
          ) ||
          entries.any(
            (e) => e.amount != row['amount'] || e.date != row['date'],
          )) {
        throw const LedgerError('Backup contains an incomplete transfer.');
      }
    }
    await _checkLoans(txn);
    if ((await txn.rawQuery('PRAGMA foreign_key_check')).isNotEmpty) {
      throw const LedgerError('Backup contains broken references.');
    }
  }
}
