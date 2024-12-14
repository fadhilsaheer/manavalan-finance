import 'package:manavalan_finance/models/wallet.dart';
import 'package:manavalan_finance/models/category.dart';
import 'package:manavalan_finance/models/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        opening_balance REAL NOT NULL,
        balance REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wallet_id INTEGER NOT NULL,
        category_id INTEGER,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        balance_before REAL NOT NULL,
        balance_after REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  // Wallet operations
  Future<int> insertWallet(Wallet wallet) async {
    final db = await instance.database;
    return await db.insert('wallets', wallet.toMap());
  }

  Future<List<Wallet>> getWallets() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('wallets');
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
  }

  Future<Wallet?> getWallet(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Wallet.fromMap(maps.first);
  }

  // Category operations
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategoriesByWallet(int walletId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Transaction operations
  Future<int> insertTransaction(FinanceTransaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<FinanceTransaction>> getTransactionsByWallet(int walletId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'date DESC',
    );
    return List.generate(
        maps.length, (i) => FinanceTransaction.fromMap(maps[i]));
  }

  Future<Map<String, double>> getWalletStats(
    int walletId, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) async {
    final db = await instance.database;
    String whereClause = 'wallet_id = ?';
    List<dynamic> whereArgs = [walletId];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    if (categoryId != null) {
      whereClause += ' AND category_id = ?';
      whereArgs.add(categoryId);
    }

    final creditsResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE $whereClause AND type = 'credit'
    ''', whereArgs);

    final debitsResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE $whereClause AND type = 'debit'
    ''', whereArgs);

    return {
      'income': creditsResult.first['total'] as double? ?? 0.0,
      'expense': debitsResult.first['total'] as double? ?? 0.0,
    };
  }
}
