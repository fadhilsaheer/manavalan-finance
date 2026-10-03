import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'forms.dart';
import 'shared.dart';
import 'theme.dart';
import 'details.dart';
import 'category_picker.dart';
import 'settings.dart';

class OverviewPage extends StatefulWidget {
  final AppController app;
  final VoidCallback? onTransactions;
  const OverviewPage({super.key, required this.app, this.onTransactions});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool hidden = false;
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
        BalancePanel(
          label: 'Wallet balance',
          value: hidden ? '••••••' : money(s.balance(w), w.currency),
          trailing: IconButton(
            tooltip: hidden ? 'Show balance' : 'Hide balance',
            icon: Icon(
              hidden ? LucideIcons.eye300 : LucideIcons.eyeOff300,
              size: 18,
            ),
            onPressed: () => setState(() => hidden = !hidden),
          ),
          footer: Row(
            children: [
              _QuickAction(
                'Expense',
                LucideIcons.banknoteArrowUp300,
                () => push(context, TransactionForm(app: app)),
              ),
              _QuickAction(
                'Income',
                LucideIcons.banknoteArrowDown300,
                () => push(
                  context,
                  TransactionForm(app: app, initialKind: EntryKind.income),
                ),
              ),
              _QuickAction(
                'Transfer',
                LucideIcons.arrowRightLeft300,
                () => push(context, TransferForm(app: app)),
              ),
              _QuickAction(
                'Lend',
                LucideIcons.plus300,
                () => push(context, LoanForm(app: app)),
              ),
            ],
          ),
        ),
        SectionTitle(
          'My wallets',
          trailing: TextButton(
            onPressed: () => push(context, WalletsPage(app: app)),
            child: const Text('View all'),
          ),
        ),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 182 : 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: app.data.wallets
                .where((wallet) => !wallet.archived)
                .length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final wallet = app.data.wallets
                  .where((wallet) => !wallet.archived)
                  .elementAt(index);
              return SizedBox(
                width: 160,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      try {
                        await app.select(wallet.id);
                      } catch (_) {
                        if (context.mounted) {
                          message(
                            context,
                            'Wait for the current save to finish.',
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(iconFor(wallet.icon), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  wallet.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              hidden
                                  ? '••••'
                                  : money(s.balance(wallet), wallet.currency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            wallet.currency,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SectionTitle(
          'Transactions',
          trailing: TextButton(
            onPressed: widget.onTransactions,
            child: const Text('View all'),
          ),
        ),
        if (app.entries.isEmpty)
          const EmptyState(
            icon: LucideIcons.receiptText300,
            title: 'Your ledger starts here',
            detail: 'Your transactions will appear here.',
          )
        else ...[
          Text(
            prettyDay(app.entries.first.date),
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final entry in app.entries.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SurfacePanel(
                padding: EdgeInsets.zero,
                child: EntryTile(
                  app: app,
                  entry: entry,
                  onTap: () =>
                      push(context, EntryDetail(app: app, entryId: entry.id)),
                ),
              ),
            ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              onPressed: () =>
                  setState(() => month = DateTime(month.year, month.month - 1)),
              icon: const Icon(LucideIcons.chevronLeft300),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () =>
                  setState(() => month = DateTime(month.year, month.month + 1)),
              icon: const Icon(LucideIcons.chevronRight300),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final items = [
              _MonthlyTotal(
                'Income',
                money(income, w.currency),
                LucideIcons.arrowDownLeft300,
                AppTheme.green,
              ),
              _MonthlyTotal(
                'Spending',
                money(expenses, w.currency),
                LucideIcons.arrowUpRight300,
                AppTheme.red,
              ),
            ];
            return compact
                ? Column(
                    children: [items[0], const SizedBox(height: 12), items[1]],
                  )
                : Row(
                    children: [
                      Expanded(child: items[0]),
                      const SizedBox(width: 12),
                      Expanded(child: items[1]),
                    ],
                  );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            'Net income  ${money(income - expenses, w.currency)}',
            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
        ),
        const SectionTitle('Lending'),
        Stats(
          children: [
            Stat('Owed to you', money(owed, w.currency), color: AppTheme.green),
            Stat('You owe', money(owe, w.currency), color: AppTheme.peach),
          ],
        ),
        const SectionTitle('Spending by category'),
        if (sorted.isEmpty)
          const Text(
            'No spending recorded for this month.',
            style: TextStyle(color: AppTheme.muted),
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
                      color: AppTheme.muted,
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
                    backgroundColor: AppTheme.surface,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
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
  bool showFilters = false;
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
        PageHeader(
          'Transactions',
          action: 'New transaction',
          onAction: () => push(context, TransactionForm(app: app)),
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search transactions',
            prefixIcon: Icon(LucideIcons.search300),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => showFilters = !showFilters),
            icon: const Icon(LucideIcons.slidersHorizontal300, size: 19),
            label: Text(
              'Filters${[kind, categoryValue, groupValue, range].where((v) => v != null).isEmpty ? '' : ' · ${[kind, categoryValue, groupValue, range].where((v) => v != null).length}'}',
            ),
          ),
        ),
        if (showFilters) ...[
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
          SelectionRow(
            label: 'Category',
            value: categoryValue == null
                ? 'All categories'
                : app.data.categoryName(categoryValue),
            icon: categoryIcon(app.data.category(categoryValue), app.data),
            onTap: () async {
              final choice = await push<CategoryChoice>(
                context,
                CategoryPicker(app: app, selected: categoryValue, filter: true),
              );
              if (choice != null && mounted) {
                setState(() => categoryId = choice.id);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('filter-group-$groupValue'),
            initialValue: groupValue,
            decoration: const InputDecoration(labelText: 'Group'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('All groups'),
              ),
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
                icon: const Icon(LucideIcons.calendarRange300),
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
        ],
        SectionTitle(
          '${entries.length} ${entries.length == 1 ? 'transaction' : 'transactions'}',
        ),
        if (entries.isEmpty)
          const EmptyState(
            icon: LucideIcons.searchX300,
            title: 'No matching transactions',
            detail: 'Try different filters or add a transaction.',
          ),
        for (final date in entries.map((e) => e.date).toSet()) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Text(
              prettyDay(date),
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SurfacePanel(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final e in entries.where((e) => e.date == date))
                  EntryTile(
                    app: app,
                    entry: e,
                    onTap: () =>
                        push(context, EntryDetail(app: app, entryId: e.id)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
        PageHeader(
          'Groups',
          action: 'New group',
          onAction: app.groups.isEmpty
              ? null
              : () => push(context, GroupForm(app: app)),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${groups.length} ${groups.length == 1 ? 'ledger' : 'ledgers'}',
                style: const TextStyle(color: AppTheme.muted),
              ),
            ),
            PopupMenuButton<bool>(
              tooltip: 'Group view',
              onSelected: (v) => setState(() => archived = v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: false, child: Text('Active')),
                const PopupMenuItem(value: true, child: Text('Archived')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      archived ? 'Archived' : 'Active',
                      style: const TextStyle(color: AppTheme.accent),
                    ),
                    const Icon(
                      LucideIcons.chevronDown300,
                      color: AppTheme.accent,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (groups.isEmpty)
          EmptyState(
            icon: LucideIcons.folderOpen300,
            title: archived ? 'No archived groups' : 'Your first group',
            detail: archived ? 'Archived ledgers will appear here.' : 'A trip, a project, or shared expenses. Keep related transactions in one place.',
            action: archived ? null : 'Create group',
            onAction: archived
                ? null
                : () => push(context, GroupForm(app: app)),
          ),
        for (final g in groups)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: SurfacePanel(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () =>
                    push(context, GroupDetail(app: app, groupId: g.id)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon: iconFor(g.icon)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              g.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronRight300,
                            color: AppTheme.muted,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        money(
                          app.entries
                              .where((e) => e.groupId == g.id)
                              .fold<int>(0, (sum, e) => sum + e.signed),
                          w.currency,
                        ),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Net balance · ${app.entries.where((e) => e.groupId == g.id).length} entries',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
  String direction = 'lent', query = '', status = 'open';
  bool searching = false;
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
    void add() =>
        push(context, LoanForm(app: app, initialDirection: direction));
    return PageBody(
      children: [
        PageHeader(
          'Lending',
          action: 'New loan',
          onAction: loans.isEmpty && status == 'open' && query.isEmpty
              ? null
              : add,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              for (final type in ['lent', 'borrowed'])
                _DebtChoice(
                  label: type == 'lent' ? 'Owed to you' : 'You owe',
                  value: money(
                    app.loans
                        .where((l) => l.direction == type)
                        .fold<int>(
                          0,
                          (sum, l) => sum + app.data.outstanding(l),
                        ),
                    w.currency,
                  ),
                  selected: direction == type,
                  rose: type == 'borrowed',
                  onTap: () => setState(() => direction = type),
                ),
            ];
            return MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? Column(
                    children: [cards[0], const SizedBox(height: 12), cards[1]],
                  )
                : Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  );
          },
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                direction == 'lent' ? 'Lent to' : 'Borrowed from',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Search people',
              onPressed: () => setState(() {
                searching = !searching;
                if (!searching) query = '';
              }),
              icon: const Icon(LucideIcons.search300, size: 20),
            ),
            PopupMenuButton<String>(
              tooltip: 'Loan status',
              onSelected: (v) => setState(() => status = v),
              itemBuilder: (_) => [
                for (final v in ['open', 'settled', 'archived'])
                  PopupMenuItem(
                    value: v,
                    child: Text(v[0].toUpperCase() + v.substring(1)),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.accent,
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronDown300,
                      size: 18,
                      color: AppTheme.accent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (searching)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search people',
                prefixIcon: Icon(LucideIcons.search300),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
        if (loans.isEmpty)
          EmptyState(
            icon: LucideIcons.users300,
            title: query.isNotEmpty
                ? 'No matching people'
                : status == 'settled'
                ? 'No settled loans'
                : status == 'archived'
                ? 'No archived loans'
                : direction == 'lent'
                ? 'Keep track of money lent'
                : 'Keep track of money borrowed',
            detail: query.isNotEmpty
                ? 'Try another name.'
                : 'Record an amount and track repayments as they happen.',
            action: query.isNotEmpty || status != 'open'
                ? null
                : direction == 'lent'
                ? 'Lend money'
                : 'Add borrowed money',
            onAction: query.isNotEmpty || status != 'open' ? null : add,
          ),
        for (final l in loans)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SurfacePanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                leading: CircleAvatar(
                  backgroundColor: direction == 'lent'
                      ? AppTheme.lavender.withValues(alpha: .4)
                      : AppTheme.blush.withValues(alpha: .4),
                  child: Text(
                    l.person.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                title: Text(l.person),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        money(app.data.outstanding(l), w.currency),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.text,
                        ),
                      ),
                      if (l.due != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Due ${prettyDay(l.due!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  l.due!.compareTo(dayKey(DateTime.now())) <
                                          0 &&
                                      app.data.outstanding(l) > 0
                                  ? AppTheme.peach
                                  : AppTheme.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: const Icon(LucideIcons.chevronRight300),
                onTap: () => push(context, LoanDetail(app: app, loanId: l.id)),
              ),
            ),
          ),
      ],
    );
  }
}

class _DebtChoice extends StatelessWidget {
  final String label, value;
  final bool selected, rose;
  final VoidCallback onTap;
  const _DebtChoice({
    required this.label,
    required this.value,
    required this.selected,
    required this.rose,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected ? const Color(0xfff0f0f0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: selected ? const Color(0xffb5b5b5) : AppTheme.surface,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                rose
                    ? LucideIcons.arrowUpRight300
                    : LucideIcons.arrowDownLeft300,
                color: AppTheme.text,
                size: 22,
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MonthlyTotal extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MonthlyTotal(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 18),
        Text(
          label,
          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.base,
            foregroundColor: AppTheme.text,
            minimumSize: const Size(48, 48),
          ),
          icon: Icon(icon, size: 21),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
        ),
      ],
    ),
  );
}
