import 'package:flutter/foundation.dart' hide Category;

import '../data/ledger_store.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  final LedgerStore store;
  LedgerSnapshot data = const LedgerSnapshot();
  int? walletId;
  bool busy = false;
  AppController(this.store);
  Wallet? get wallet =>
      data.wallets.where((w) => w.id == walletId && !w.archived).firstOrNull;
  List<Entry> get entries =>
      data.entries.where((e) => e.walletId == walletId).toList();
  List<Category> get categories =>
      data.categories.where((c) => c.walletId == walletId).toList();
  List<LedgerGroup> get groups =>
      data.groups.where((g) => g.walletId == walletId).toList();
  List<Loan> get loans =>
      data.loans.where((l) => l.walletId == walletId).toList();
  Future<void> init() async {
    walletId = int.tryParse(await store.setting('selected_wallet') ?? '');
    await reload();
  }

  Future<void> reload() async {
    data = await store.snapshot();
    if (wallet == null) {
      walletId = data.wallets.where((w) => !w.archived).firstOrNull?.id;
    }
    await store.setSetting('selected_wallet', walletId?.toString() ?? '');
    notifyListeners();
  }

  Future<void> select(int id) async {
    if (busy) throw const LedgerError('Wait for the current save to finish.');
    walletId = id;
    await reload();
  }

  Future<void> change(Future<void> Function() action) async {
    if (busy) throw const LedgerError('Wait for the current save to finish.');
    busy = true;
    notifyListeners();
    try {
      await action();
      await reload();
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
