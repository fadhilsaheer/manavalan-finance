import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'forms.dart';
import 'shared.dart';
import 'theme.dart';

class EntryDetail extends StatelessWidget {
  final AppController app;
  final int entryId;
  const EntryDetail({super.key, required this.app, required this.entryId});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final e = app.data.entries.where((e) => e.id == entryId).firstOrNull;
      if (e == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Transaction')),
          body: const Center(child: Text('This transaction was removed.')),
        );
      }
      final w = app.data.wallets.firstWhere((w) => w.id == e.walletId);
      final loan = app.data.loan(e.loanId);
      final group = app.data.group(e.groupId);
      final chronological = app.data.entries.where(
        (other) =>
            other.walletId == w.id &&
            (other.date.compareTo(e.date) < 0 ||
                other.date == e.date && other.id <= e.id),
      );
      final running =
          w.opening + chronological.fold<int>(0, (sum, e) => sum + e.signed);
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: PageBody(
          children: [
            Text(
              '${e.sign > 0 ? '+' : '−'}${money(e.amount, w.currency)}',
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(color: e.sign > 0 ? AppTheme.green : AppTheme.red),
            ),
            const SizedBox(height: 12),
            Text(e.kind.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wallet'),
              subtitle: Text(w.name),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(prettyDay(e.date)),
            ),
            if (e.kind.ordinary)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Category'),
                subtitle: Text(app.data.categoryName(e.categoryId)),
              ),
            if (group != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Group'),
                subtitle: Text(group.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    push(context, GroupDetail(app: app, groupId: group.id)),
              ),
            if (loan != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Loan'),
                subtitle: Text(loan.person),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    push(context, LoanDetail(app: app, loanId: loan.id)),
              ),
            if (e.transferId != null) ...[
              const Text(
                'This entry is linked to the other wallet. Removing it removes both sides of the transfer.',
                style: TextStyle(color: AppTheme.muted),
              ),
              for (final peer in app.data.entries.where(
                (p) => p.transferId == e.transferId && p.id != e.id,
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Other wallet'),
                  subtitle: Text(
                    app.data.wallets
                        .firstWhere((w) => w.id == peer.walletId)
                        .name,
                  ),
                ),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wallet balance after this entry'),
              subtitle: Text(money(running, w.currency)),
            ),
            if (e.note.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Note'),
                subtitle: Text(e.note),
              ),
            const SizedBox(height: 24),
            if (!w.archived && e.kind.ordinary)
              FilledButton.icon(
                onPressed: () =>
                    push(context, TransactionForm(app: app, existing: e)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit transaction'),
              ),
            if (!w.archived && loan != null && !loan.archived)
              FilledButton.icon(
                onPressed: () => push(
                  context,
                  LoanMovementForm(
                    app: app,
                    loan: loan,
                    existing: e,
                    repayment: e.kind == EntryKind.loanRepayment,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit loan entry'),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red),
              onPressed: app.busy
                  ? null
                  : () async {
                      final ok = await confirm(
                        context,
                        title: 'Delete transaction?',
                        body: e.transferId != null
                            ? 'Both transfer entries will be deleted and both wallet balances updated.'
                            : loan != null
                            ? 'The loan’s outstanding amount and wallet balance will be updated. A principal entry cannot be removed if it would invalidate later repayments.'
                            : 'This entry will be deleted and the wallet balance updated.',
                      );
                      if (!ok || !context.mounted) return;
                      final removed = await perform(
                        context,
                        app,
                        () => app.store.deleteEntry(e.id),
                        success: 'Transaction deleted',
                      );
                      if (removed && context.mounted) Navigator.pop(context);
                    },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete transaction'),
            ),
          ],
        ),
      );
    },
  );
}

class GroupDetail extends StatefulWidget {
  final AppController app;
  final int groupId;
  const GroupDetail({super.key, required this.app, required this.groupId});
  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  DateTimeRange? range;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app, g = widget.app.data.group(widget.groupId);
      if (g == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Group')),
          body: const Center(child: Text('This group was removed.')),
        );
      }
      final w = app.data.wallets.firstWhere((w) => w.id == g.walletId);
      final all = app.data.entries.where((e) => e.groupId == g.id).toList();
      final entries = all
          .where(
            (e) =>
                range == null ||
                e.date.compareTo(dayKey(range!.start)) >= 0 &&
                    e.date.compareTo(dayKey(range!.end)) <= 0,
          )
          .toList();
      final income = app.data.total(entries, EntryKind.income),
          expense = app.data.total(entries, EntryKind.expense);
      final ordered = all.reversed.toList(), balances = <int, int>{};
      var running = 0;
      for (final e in ordered) {
        running += e.signed;
        balances[e.id] = running;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(g.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) async {
                if (action == 'export') {
                  await exportLedger(
                    context,
                    app,
                    all,
                    'manavalan-group-${g.id}',
                  );
                  return;
                }
                if (action == 'edit') {
                  await push(context, GroupForm(app: app, existing: g));
                  return;
                }
                if (action == 'archive') {
                  await perform(
                    context,
                    app,
                    () => app.store.archiveGroup(g.id, !g.archived),
                    success: g.archived ? 'Group restored' : 'Group archived',
                  );
                  return;
                }
                final delete = action == 'delete';
                final confirmed = await confirm(
                  context,
                  title: delete
                      ? 'Delete group and transactions?'
                      : 'Remove group, keep transactions?',
                  body: delete
                      ? '${all.length} transactions will be deleted. Money in: ${money(app.data.total(all, EntryKind.income), w.currency)}. Money out: ${money(app.data.total(all, EntryKind.expense), w.currency)}. Your wallet balance will change.'
                      : 'The group will be removed. All ${all.length} transactions stay in your wallet, with their categories and notes. Your wallet balance stays the same.',
                  action: delete ? 'Delete all' : 'Remove group',
                  destructive: delete,
                );
                if (!confirmed || !context.mounted) return;
                final ok = await perform(
                  context,
                  app,
                  () => app.store.dissolveGroup(g.id, deleteEntries: delete),
                  success: 'Group removed',
                );
                if (ok && context.mounted) Navigator.pop(context);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export ledger CSV'),
                ),
                if (!w.archived)
                  const PopupMenuItem(value: 'edit', child: Text('Edit group')),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(g.archived ? 'Restore group' : 'Archive group'),
                ),
                const PopupMenuItem(
                  value: 'detach',
                  child: Text('Remove group, keep transactions'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete group and transactions',
                    style: TextStyle(color: AppTheme.red),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: PageBody(
          children: [
            if (g.archived)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Archived group',
                  style: TextStyle(color: AppTheme.peach),
                ),
              ),
            if (g.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(g.note),
              ),
            Text('Net balance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              money(income - expense, w.currency),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Stats(
              children: [
                Stat(
                  'Money in',
                  money(income, w.currency),
                  color: AppTheme.green,
                ),
                Stat(
                  'Total spending',
                  money(expense, w.currency),
                  color: AppTheme.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            if (!g.archived && !w.archived)
              FilledButton.icon(
                onPressed: () =>
                    push(context, TransactionForm(app: app, groupId: g.id)),
                icon: const Icon(Icons.add),
                label: const Text('Add transaction'),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    range == null
                        ? 'All dates'
                        : '${prettyDay(dayKey(range!.start))} – ${prettyDay(dayKey(range!.end))}',
                  ),
                  onPressed: () async {
                    final selected = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2200),
                      initialDateRange: range,
                    );
                    if (selected != null && mounted) {
                      setState(() => range = selected);
                    }
                  },
                ),
                if (range != null)
                  TextButton(
                    onPressed: () => setState(() => range = null),
                    child: const Text('Clear dates'),
                  ),
              ],
            ),
            SectionTitle(
              '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
            ),
            if (entries.isEmpty)
              const EmptyState(
                icon: Icons.folder_open_outlined,
                title: 'No entries yet',
                detail: 'Add income or expenses to build this ledger.',
              ),
            for (final e in entries) ...[
              EntryTile(
                app: app,
                entry: e,
                running: balances[e.id],
                onTap: () =>
                    push(context, EntryDetail(app: app, entryId: e.id)),
              ),
              const Divider(),
            ],
          ],
        ),
      );
    },
  );
}

class LoanDetail extends StatelessWidget {
  final AppController app;
  final int loanId;
  const LoanDetail({super.key, required this.app, required this.loanId});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final l = app.data.loan(loanId);
      if (l == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Loan')),
          body: const Center(child: Text('This loan was removed.')),
        );
      }
      final w = app.data.wallets.firstWhere((w) => w.id == l.walletId);
      final entries = app.data.entries.where((e) => e.loanId == l.id).toList();
      final outstanding = app.data.outstanding(l);
      final advanced =
              l.opening + app.data.total(entries, EntryKind.loanAdvance),
          returned = app.data.total(entries, EntryKind.loanRepayment);
      var running = l.opening;
      final balances = <int, int>{};
      for (final e in entries.reversed) {
        running += e.kind == EntryKind.loanAdvance ? e.amount : -e.amount;
        balances[e.id] = running;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(l.person),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) async {
                if (action == 'export') {
                  await exportLedger(
                    context,
                    app,
                    entries,
                    'manavalan-loan-${l.id}',
                  );
                  return;
                }
                if (action == 'edit') {
                  await push(context, LoanForm(app: app, existing: l));
                  return;
                }
                if (action == 'archive') {
                  await perform(
                    context,
                    app,
                    () => app.store.archiveLoan(l.id, !l.archived),
                    success: l.archived ? 'Loan restored' : 'Loan archived',
                  );
                  return;
                }
                final confirmed = await confirm(
                  context,
                  title: 'Delete loan and its entries?',
                  body:
                      '${entries.length} cash movements and this loan will be deleted. Outstanding: ${money(outstanding, w.currency)}. The wallet balance will change by ${money(-entries.fold<int>(0, (sum, e) => sum + e.signed), w.currency)}.',
                );
                if (!confirmed || !context.mounted) return;
                final ok = await perform(
                  context,
                  app,
                  () => app.store.deleteLoan(l.id),
                  success: 'Loan deleted',
                );
                if (ok && context.mounted) Navigator.pop(context);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export cash movements CSV'),
                ),
                if (!w.archived)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit details'),
                  ),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(l.archived ? 'Restore loan' : 'Archive loan'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete loan and entries',
                    style: TextStyle(color: AppTheme.red),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: PageBody(
          children: [
            Text(
              l.lent ? 'Owed to you' : 'You owe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              money(outstanding, w.currency),
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(color: l.lent ? AppTheme.green : AppTheme.peach),
            ),
            const SizedBox(height: 12),
            Text(
              l.archived
                  ? 'Archived · still included in outstanding totals'
                  : outstanding == 0
                  ? 'Settled'
                  : 'Open loan',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 28),
            Stats(
              children: [
                Stat(
                  'Total ${l.lent ? 'lent' : 'borrowed'}',
                  money(advanced, w.currency),
                ),
                Stat(
                  'Repaid',
                  money(returned, w.currency),
                  color: AppTheme.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Started ${prettyDay(l.date)}${l.due == null ? '' : ' · Due ${prettyDay(l.due!)}'}',
            ),
            if (l.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(l.note),
              ),
            const SizedBox(height: 28),
            if (!l.archived && !w.archived) ...[
              if (outstanding > 0)
                FilledButton.icon(
                  onPressed: () =>
                      push(context, LoanMovementForm(app: app, loan: l)),
                  icon: const Icon(Icons.check),
                  label: const Text('Record repayment'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => push(
                  context,
                  LoanMovementForm(app: app, loan: l, repayment: false),
                ),
                icon: const Icon(Icons.add),
                label: Text(l.lent ? 'Lend more' : 'Borrow more'),
              ),
            ],
            const SectionTitle('Repayment ledger'),
            for (final e in entries) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  e.kind == EntryKind.loanRepayment
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                  color: e.kind == EntryKind.loanRepayment
                      ? AppTheme.green
                      : AppTheme.accent,
                ),
                title: Text(
                  '${e.kind == EntryKind.loanRepayment ? 'Repayment' : 'Advance'} · ${money(e.amount, w.currency)}',
                ),
                subtitle: Text(
                  '${prettyDay(e.date)}\nOutstanding after: ${money(balances[e.id]!, w.currency)}${e.note.isEmpty ? '' : '\n${e.note}'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    push(context, EntryDetail(app: app, entryId: e.id)),
              ),
              const Divider(),
            ],
            if (l.opening > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Opening outstanding ${money(l.opening, w.currency)} · ${prettyDay(l.date)}\nNo wallet cash movement was created for this opening amount.',
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ),
          ],
        ),
      );
    },
  );
}
