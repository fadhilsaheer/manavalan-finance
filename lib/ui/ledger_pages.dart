import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'forms.dart';
import 'shared.dart';
import 'theme.dart';
import 'details.dart';

class OverviewPage extends StatefulWidget {
  final AppController app;
  const OverviewPage({super.key, required this.app});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    final app = widget.app, s = widget.app.data, w = widget.app.wallet!;
    final prefix = DateFormat('yyyy-MM').format(month);
    final entries = app.entries
        .where((e) => e.date.startsWith(prefix))
        .toList();
    final income = s.total(entries, EntryKind.income),
        expenses = s.total(entries, EntryKind.expense);
    final owed = app.loans
        .where((l) => l.lent)
        .fold<int>(0, (sum, l) => sum + s.outstanding(l));
    final owe = app.loans
        .where((l) => !l.lent)
        .fold<int>(0, (sum, l) => sum + s.outstanding(l));
    final breakdown = <int?, int>{};
    for (final e in entries.where((e) => e.kind == EntryKind.expense)) {
      final category = s.category(e.categoryId);
      final root = category?.parentId ?? category?.id;
      breakdown[root] = (breakdown[root] ?? 0) + e.amount;
    }
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return PageBody(
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Wallet balance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => push(context, TransferForm(app: app)),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          money(s.balance(w), w.currency),
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: Mocha.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              onPressed: () =>
                  setState(() => month = DateTime(month.year, month.month - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () =>
                  setState(() => month = DateTime(month.year, month.month + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Stats(
          children: [
            Stat('Income', money(income, w.currency), color: Mocha.green),
            Stat('Spending', money(expenses, w.currency), color: Mocha.red),
            Stat('Net income', money(income - expenses, w.currency)),
          ],
        ),
        const SectionTitle('Lending balances'),
        Stats(
          children: [
            Stat('Owed to you', money(owed, w.currency), color: Mocha.green),
            Stat('You owe', money(owe, w.currency), color: Mocha.peach),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Loan movements and transfers affect wallet cash, and are excluded from income and spending.',
            style: TextStyle(color: Mocha.muted),
          ),
        ),
        const SectionTitle('Spending by category'),
        if (sorted.isEmpty)
          const Text(
            'No spending recorded for this month.',
            style: TextStyle(color: Mocha.muted),
          ),
        for (final item in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      iconFor(s.category(item.key)?.icon ?? 'wallet'),
                      size: 20,
                      color: Mocha.muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.category(item.key)?.name ?? 'Uncategorised',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        money(item.value, w.currency),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: item.value / expenses,
                    minHeight: 6,
                    backgroundColor: Mocha.surface,
                    color: Mocha.mauve,
                  ),
                ),
              ],
            ),
          ),
        const SectionTitle('Recent activity'),
        if (app.entries.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Your ledger starts here',
            detail: 'Record your first expense or income in ${w.name}.',
            action: 'New transaction',
            onAction: () => push(context, TransactionForm(app: app)),
          ),
        for (final e in app.entries.take(5))
          EntryTile(
            app: app,
            entry: e,
            onTap: () => push(context, EntryDetail(app: app, entryId: e.id)),
          ),
      ],
    );
  }
}

class TransactionsPage extends StatefulWidget {
  final AppController app;
  const TransactionsPage({super.key, required this.app});
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String query = '';
  EntryKind? kind;
  int? categoryId, groupId;
  DateTimeRange? range;
  @override
  Widget build(BuildContext context) {
    final app = widget.app, w = widget.app.wallet!;
    final categoryValue = app.categories.any((c) => c.id == categoryId)
        ? categoryId
        : null;
    final groupValue = app.groups.any((g) => g.id == groupId) ? groupId : null;
    final entries = app.entries.where((e) {
      final category = app.data.category(e.categoryId);
      final text =
          '${e.note} ${app.data.categoryName(e.categoryId)} ${app.data.group(e.groupId)?.name ?? ''} ${app.data.loan(e.loanId)?.person ?? ''} ${e.kind.label} ${money(e.amount, w.currency)} ${moneyInput(e.amount)}'
              .toLowerCase();
      return text.contains(query.toLowerCase()) &&
          (kind == null || e.kind == kind) &&
          (categoryValue == null ||
              e.categoryId == categoryValue ||
              category?.parentId == categoryValue) &&
          (groupValue == null || e.groupId == groupValue) &&
          (range == null ||
              e.date.compareTo(dayKey(range!.start)) >= 0 &&
                  e.date.compareTo(dayKey(range!.end)) <= 0);
    }).toList();
    return PageBody(
      children: [
        Text('Transactions', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search notes, categories, people…',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<EntryKind>(
          initialValue: kind,
          decoration: const InputDecoration(labelText: 'Type'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<EntryKind>(
              value: null,
              child: Text('All cash movements'),
            ),
            ...EntryKind.values.map(
              (k) => DropdownMenuItem(value: k, child: Text(k.label)),
            ),
          ],
          onChanged: (v) => setState(() => kind = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('filter-category-$categoryValue'),
          initialValue: categoryValue,
          decoration: const InputDecoration(labelText: 'Category'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('All categories'),
            ),
            ...app.categories.map(
              (c) => DropdownMenuItem(
                value: c.id,
                child: Text(
                  app.data.categoryName(c.id),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (v) => setState(() => categoryId = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey('filter-group-$groupValue'),
          initialValue: groupValue,
          decoration: const InputDecoration(labelText: 'Group'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('All groups')),
            ...app.groups.map(
              (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
            ),
          ],
          onChanged: (v) => setState(() => groupId = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(
                range == null
                    ? 'All dates'
                    : '${DateFormat('d MMM').format(range!.start)} – ${DateFormat('d MMM yyyy').format(range!.end)}',
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
          '${entries.length} ${entries.length == 1 ? 'transaction' : 'transactions'}',
        ),
        if (entries.isEmpty)
          const EmptyState(
            icon: Icons.search_off_outlined,
            title: 'No matching transactions',
            detail: 'Try different filters or add a transaction.',
          ),
        for (final e in entries) ...[
          EntryTile(
            app: app,
            entry: e,
            onTap: () => push(context, EntryDetail(app: app, entryId: e.id)),
          ),
          const Divider(),
        ],
      ],
    );
  }
}

class GroupsPage extends StatefulWidget {
  final AppController app;
  const GroupsPage({super.key, required this.app});
  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool archived = false;
  @override
  Widget build(BuildContext context) {
    final app = widget.app, w = widget.app.wallet!;
    final groups = app.groups.where((g) => g.archived == archived).toList();
    return PageBody(
      children: [
        Text('Groups', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        const Text(
          'Individual ledgers for a trip, project, person, or anything you want to keep together.',
          style: TextStyle(color: Mocha.muted),
        ),
        const SizedBox(height: 20),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Active')),
            ButtonSegment(value: true, label: Text('Archived')),
          ],
          selected: {archived},
          onSelectionChanged: (v) => setState(() => archived = v.first),
        ),
        if (groups.isEmpty)
          EmptyState(
            icon: Icons.folder_open_outlined,
            title: archived
                ? 'No archived groups'
                : 'Keep related entries together',
            detail: archived
                ? 'Archived ledgers will appear here.'
                : 'Create a group, then add transactions to its ledger.',
            action: archived ? null : 'Create group',
            onAction: archived
                ? null
                : () => push(context, GroupForm(app: app)),
          ),
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(iconFor(g.icon), color: Mocha.mauve),
              title: Text(g.name),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${app.entries.where((e) => e.groupId == g.id).length} entries · Net ${money(app.entries.where((e) => e.groupId == g.id).fold<int>(0, (sum, e) => sum + e.signed), w.currency)}',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(context, GroupDetail(app: app, groupId: g.id)),
            ),
          ),
          const Divider(),
        ],
      ],
    );
  }
}

class LendingPage extends StatefulWidget {
  final AppController app;
  const LendingPage({super.key, required this.app});
  @override
  State<LendingPage> createState() => _LendingPageState();
}

class _LendingPageState extends State<LendingPage> {
  String direction = 'lent', query = '';
  String status = 'open';
  @override
  Widget build(BuildContext context) {
    final app = widget.app, w = widget.app.wallet!;
    final loans = app.loans
        .where(
          (l) =>
              l.direction == direction &&
              l.person.toLowerCase().contains(query.toLowerCase()) &&
              (status == 'archived'
                  ? l.archived
                  : !l.archived &&
                        (status == 'settled'
                            ? app.data.outstanding(l) == 0
                            : app.data.outstanding(l) > 0)),
        )
        .toList();
    return PageBody(
      children: [
        Text('Lending', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        const Text(
          'Track what is owed, one repayment at a time.',
          style: TextStyle(color: Mocha.muted),
        ),
        const SizedBox(height: 20),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'lent', label: Text('Lent')),
            ButtonSegment(value: 'borrowed', label: Text('Borrowed')),
          ],
          selected: {direction},
          onSelectionChanged: (v) => setState(() => direction = v.first),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search people',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: ['open', 'settled', 'archived']
              .map(
                (s) => ChoiceChip(
                  label: Text(s[0].toUpperCase() + s.substring(1)),
                  selected: status == s,
                  onSelected: (_) => setState(() => status = s),
                ),
              )
              .toList(),
        ),
        if (loans.isEmpty)
          EmptyState(
            icon: Icons.handshake_outlined,
            title: status == 'open'
                ? 'No outstanding loans here'
                : 'No $status loans',
            detail: 'Record money you lent or borrowed to start a repayment ledger.',
            action: 'New loan',
            onAction: () => push(context, LoanForm(app: app)),
          ),
        for (final l in loans) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline, color: Mocha.mauve),
              title: Text(l.person),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${l.lent ? 'Owes you' : 'You owe'} ${money(app.data.outstanding(l), w.currency)}${l.due == null ? '' : '\nDue ${prettyDay(l.due!)}'}',
                  style: TextStyle(
                    color:
                        l.due != null &&
                            l.due!.compareTo(dayKey(DateTime.now())) < 0 &&
                            app.data.outstanding(l) > 0
                        ? Mocha.peach
                        : Mocha.muted,
                  ),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(context, LoanDetail(app: app, loanId: l.id)),
            ),
          ),
          const Divider(),
        ],
      ],
    );
  }
}
