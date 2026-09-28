import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:manavalan_finance/core/models.dart';
import 'package:manavalan_finance/data/ledger_store.dart';

void main() {
  late LedgerStore store;
  late int wallet;
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    store = await LedgerStore.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    wallet = await store.saveWallet(
      name: 'Personal',
      currency: 'INR',
      opening: 100000,
    );
  });
  tearDown(() => store.db.close());

  test('decimal money is exact and invalid input is rejected', () {
    expect(parseMoney('0.10') + parseMoney('0.20'), 30);
    expect(parseMoney('-12.34', signed: true), -1234);
    for (final value in ['NaN', '1.001', '-1', '0', '1e5', '100000000001']) {
      expect(() => parseMoney(value), throwsA(isA<LedgerError>()));
    }
  });
  test('wallet seed hierarchy is independent', () async {
    final other = await store.saveWallet(
      name: 'Work',
      currency: 'USD',
      opening: 0,
    );
    final snapshot = await store.snapshot();
    expect(
      snapshot.categories
          .where((c) => c.walletId == wallet && c.parentId == null)
          .length,
      10,
    );
    expect(
      snapshot.categories.where((c) => c.walletId == other).length,
      snapshot.categories.where((c) => c.walletId == wallet).length,
    );
  });
  test(
    'editing and deleting backdated transactions derives correct balance',
    () async {
      final id = await store.saveEntry(
        walletId: wallet,
        amount: 1000,
        kind: EntryKind.expense,
        date: '2026-09-20',
      );
      await store.saveEntry(
        walletId: wallet,
        amount: 2000,
        kind: EntryKind.income,
        date: '2026-09-01',
      );
      await store.saveEntry(
        id: id,
        walletId: wallet,
        amount: 500,
        kind: EntryKind.expense,
        date: '2026-08-01',
      );
      var s = await store.snapshot();
      expect(s.balance(s.wallets.first), 101500);
      await store.deleteEntry(id);
      s = await store.snapshot();
      expect(s.balance(s.wallets.first), 102000);
    },
  );
  test('cross-wallet categories and groups are rejected', () async {
    final other = await store.saveWallet(
      name: 'Other',
      currency: 'INR',
      opening: 0,
    );
    final s = await store.snapshot();
    final category = s.categories.firstWhere(
      (c) => c.walletId == other && c.kind == 'expense',
    );
    final group = await store.saveGroup(walletId: other, name: 'Trip');
    for (final link in ['category', 'group']) {
      await expectLater(
        store.saveEntry(
          walletId: wallet,
          amount: 100,
          kind: EntryKind.expense,
          date: '2026-09-01',
          categoryId: link == 'category' ? category.id : null,
          groupId: link == 'group' ? group : null,
        ),
        throwsA(isA<LedgerError>()),
      );
    }
    expect((await store.snapshot()).entries, isEmpty);
  });
  test(
    'categories enforce two levels and deleting parent retains entries',
    () async {
      final s = await store.snapshot();
      final child = s.categories.firstWhere((c) => c.parentId != null);
      await expectLater(
        store.saveCategory(
          walletId: wallet,
          parentId: child.id,
          name: 'Third',
          kind: 'expense',
          icon: 'food',
        ),
        throwsA(isA<LedgerError>()),
      );
      await store.saveEntry(
        walletId: wallet,
        amount: 100,
        kind: EntryKind.expense,
        date: '2026-09-01',
        categoryId: child.id,
      );
      await store.deleteCategory(child.parentId!);
      final after = await store.snapshot();
      expect(after.entries.single.categoryId, isNull);
      expect(after.balance(after.wallets.first), 99900);
    },
  );
  test('group removal detaches entries and deletion removes entries', () async {
    for (final removeEntries in [false, true]) {
      final group = await store.saveGroup(walletId: wallet, name: 'Trip');
      await store.saveEntry(
        walletId: wallet,
        amount: 500,
        kind: EntryKind.expense,
        date: '2026-09-01',
        groupId: group,
      );
      await store.dissolveGroup(group, deleteEntries: removeEntries);
      final s = await store.snapshot();
      expect(s.groups, isEmpty);
      expect(s.entries.where((e) => e.groupId != null), isEmpty);
      expect(s.entries.length, 1);
      expect(s.balance(s.wallets.first), 99500);
    }
  });
  test(
    'lent and borrowed partial repayments affect cash but not spending',
    () async {
      final lent = await store.createLoan(
        walletId: wallet,
        person: 'Alex',
        direction: 'lent',
        amount: 50000,
        date: '2026-09-01',
      );
      await store.loanMovement(
        lent,
        amount: 15000,
        repayment: true,
        date: '2026-09-02',
      );
      final borrowed = await store.createLoan(
        walletId: wallet,
        person: 'Sam',
        direction: 'borrowed',
        amount: 10000,
        date: '2026-09-01',
      );
      await store.loanMovement(
        borrowed,
        amount: 2000,
        repayment: true,
        date: '2026-09-02',
      );
      final s = await store.snapshot();
      expect(s.outstanding(s.loan(lent)!), 35000);
      expect(s.outstanding(s.loan(borrowed)!), 8000);
      expect(s.balance(s.wallets.first), 73000);
      expect(s.total(s.entries, EntryKind.expense), 0);
      expect(s.total(s.entries, EntryKind.income), 0);
    },
  );
  test(
    'overpayment, backdated repayment, and deleting principal roll back',
    () async {
      final id = await store.createLoan(
        walletId: wallet,
        person: 'Alex',
        direction: 'lent',
        amount: 10000,
        date: '2026-09-01',
      );
      await store.loanMovement(
        id,
        amount: 5000,
        repayment: true,
        date: '2026-09-02',
      );
      await expectLater(
        store.loanMovement(
          id,
          amount: 6000,
          repayment: true,
          date: '2026-09-03',
        ),
        throwsA(isA<LedgerError>()),
      );
      await expectLater(
        store.loanMovement(
          id,
          amount: 1000,
          repayment: true,
          date: '2026-08-31',
        ),
        throwsA(isA<LedgerError>()),
      );
      final before = await store.snapshot();
      await expectLater(
        store.deleteEntry(before.entries.last.id),
        throwsA(isA<LedgerError>()),
      );
      expect((await store.snapshot()).entries.length, 2);
    },
  );
  test('existing debt creates no phantom cash movement', () async {
    final id = await store.createLoan(
      walletId: wallet,
      person: 'Alex',
      direction: 'lent',
      amount: 10000,
      date: '2026-09-01',
      openingOnly: true,
    );
    var s = await store.snapshot();
    expect(s.entries, isEmpty);
    expect(s.balance(s.wallets.first), 100000);
    expect(s.outstanding(s.loan(id)!), 10000);
    await store.loanMovement(
      id,
      amount: 10000,
      repayment: true,
      date: '2026-09-02',
    );
    s = await store.snapshot();
    expect(s.outstanding(s.loan(id)!), 0);
    expect(s.balance(s.wallets.first), 110000);
  });
  test(
    'transfers are paired, excluded from reports, and removed together',
    () async {
      final other = await store.saveWallet(
        name: 'Savings',
        currency: 'INR',
        opening: 0,
      );
      await store.transfer(
        from: wallet,
        to: other,
        amount: 10000,
        date: '2026-09-01',
      );
      var s = await store.snapshot();
      expect(s.balance(s.wallets.first), 90000);
      expect(s.balance(s.wallets.last), 10000);
      expect(s.total(s.entries, EntryKind.expense), 0);
      await expectLater(
        store.deleteWallet(wallet),
        throwsA(isA<LedgerError>()),
      );
      await store.deleteEntry(s.entries.first.id);
      s = await store.snapshot();
      expect(s.entries, isEmpty);
      expect(s.balance(s.wallets.first), 100000);
    },
  );
  test('currency mismatch transfer fails without writes', () async {
    final other = await store.saveWallet(
      name: 'Dollar',
      currency: 'USD',
      opening: 0,
    );
    await expectLater(
      store.transfer(from: wallet, to: other, amount: 100, date: '2026-09-01'),
      throwsA(isA<LedgerError>()),
    );
    expect((await store.snapshot()).entries, isEmpty);
  });
  test(
    'backup restores all links and rejects invalid replacement atomically',
    () async {
      final group = await store.saveGroup(walletId: wallet, name: 'Trip');
      await store.saveEntry(
        walletId: wallet,
        amount: 1000,
        kind: EntryKind.expense,
        date: '2026-09-01',
        groupId: group,
      );
      final backup = await store.backup();
      await store.dissolveGroup(group, deleteEntries: true);
      await store.restore(backup);
      expect((await store.snapshot()).entries.single.groupId, group);
      final broken = jsonDecode(backup) as Map<String, dynamic>;
      (broken['entries'] as List).first['amount'] = -1;
      await expectLater(
        store.restore(jsonEncode(broken)),
        throwsA(isA<LedgerError>()),
      );
      expect(await store.backup(), contains('Trip'));
      expect((await store.snapshot()).entries.single.amount, 1000);
    },
  );
  test('archive protects wallets from accidental writes', () async {
    await store.archiveWallet(wallet, true);
    await expectLater(
      store.saveEntry(
        walletId: wallet,
        amount: 100,
        kind: EntryKind.income,
        date: '2026-09-01',
      ),
      throwsA(isA<LedgerError>()),
    );
    await store.archiveWallet(wallet, false);
    await store.saveEntry(
      walletId: wallet,
      amount: 100,
      kind: EntryKind.income,
      date: '2026-09-01',
    );
    expect((await store.snapshot()).entries.length, 1);
  });
}
