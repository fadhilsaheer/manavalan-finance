import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import '../data/file_service.dart';
import 'forms.dart';
import 'shared.dart';
import 'theme.dart';

class SettingsPage extends StatefulWidget {
  final AppController app;
  const SettingsPage({super.key, required this.app});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool working = false;
  String? safetyPath;
  @override
  void initState() {
    super.initState();
    loadSafety();
  }

  Future<void> loadSafety() async {
    final path = await widget.app.store.setting('safety_backup_path');
    if (mounted) setState(() => safetyPath = path);
  }

  Future<void> fileAction(Future<void> Function() action) async {
    if (working) return;
    setState(() => working = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        message(
          context,
          e is LedgerError
              ? e.message
              : 'Could not complete the file operation. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> restore([String? content]) async {
    final json = content ?? await FileService.chooseBackup();
    if (json == null || !mounted) return;
    final yes = await confirm(
      context,
      title: 'Replace all local data?',
      body: 'All wallets and ledgers will be replaced by this backup. A private safety copy of your current data will be saved on this device first.',
      action: 'Restore backup',
    );
    if (!yes || !mounted) return;
    final ok = await perform(context, widget.app, () async {
      safetyPath = await FileService.restoreWithSafetyCopy(
        widget.app.store,
        json,
      );
    }, success: 'Backup restored');
    if (ok) await widget.app.init();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app;
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: PageBody(
          children: [
            if (working) const LinearProgressIndicator(),
            Row(
              children: [
                const BrandMark(size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manavalan Finance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your money. On your device.',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SectionTitle('Manage'),
            SurfacePanel(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    ListTile(
                      tileColor: AppTheme.mantle,
                      shape: const RoundedRectangleBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      title: const Text('Wallets'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => push(context, WalletsPage(app: app)),
                    ),
                    if (app.wallet != null)
                      ListTile(
                        tileColor: AppTheme.mantle,
                        shape: const RoundedRectangleBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: const Icon(Icons.category_outlined),
                        title: const Text('Categories'),
                        subtitle: Text('For ${app.wallet!.name}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => push(context, CategoriesPage(app: app)),
                      ),
                  ],
                ),
              ),
            ),
            const SectionTitle('Backup & export'),
            SurfacePanel(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    ListTile(
                      tileColor: AppTheme.mantle,
                      shape: const RoundedRectangleBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: const Icon(Icons.save_alt),
                      title: const Text('Save full backup'),
                      subtitle: const Text('All wallets · JSON'),
                      enabled: !working,
                      onTap: () => fileAction(() async {
                        final saved = await FileService.save(
                          'manavalan-${dayKey(DateTime.now())}.json',
                          await app.store.backup(),
                          'json',
                        );
                        if (context.mounted && saved) {
                          message(context, 'Backup saved');
                        }
                      }),
                    ),
                    ListTile(
                      tileColor: AppTheme.mantle,
                      shape: const RoundedRectangleBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: const Icon(Icons.restore),
                      title: const Text('Restore backup'),
                      subtitle: const Text(
                        'Replace local data from a saved JSON backup',
                      ),
                      enabled: !working,
                      onTap: () => fileAction(() => restore()),
                    ),
                    if (safetyPath != null)
                      ListTile(
                        tileColor: AppTheme.mantle,
                        shape: const RoundedRectangleBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: const Icon(Icons.undo),
                        title: const Text('Restore safety copy'),
                        subtitle: const Text('Before your last restore'),
                        enabled: !working,
                        onTap: () => fileAction(() async {
                          await restore(await File(safetyPath!).readAsString());
                        }),
                      ),
                    if (app.wallet != null)
                      ListTile(
                        tileColor: AppTheme.mantle,
                        shape: const RoundedRectangleBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: const Icon(Icons.table_chart_outlined),
                        title: const Text('Export wallet transactions'),
                        subtitle: Text('${app.wallet!.name} · CSV'),
                        enabled: !working,
                        onTap: () => fileAction(() async {
                          final saved = await FileService.save(
                            'manavalan-wallet-${app.walletId}-${dayKey(DateTime.now())}.csv',
                            FileService.csv(app.data, app.entries),
                            'csv',
                          );
                          if (context.mounted && saved) {
                            message(context, 'CSV saved');
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SectionTitle('Local privacy'),
            const Text(
              'Stored only on this device. Back up before uninstalling or changing phones.',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            const Text(
              'Version 2.0.0',
              style: TextStyle(color: AppTheme.muted),
            ),
          ],
        ),
      );
    },
  );
}

class WalletsPage extends StatelessWidget {
  final AppController app;
  const WalletsPage({super.key, required this.app});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => push(context, WalletForm(app: app)),
        icon: const Icon(Icons.add),
        label: const Text('Create wallet'),
      ),
      body: PageBody(
        children: [
          if (app.data.wallets.isEmpty)
            const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No wallets yet',
              detail: 'Create your first wallet to begin.',
            ),
          for (final w in app.data.wallets) ...[
            ListTile(
              tileColor: AppTheme.mantle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: IconBadge(
                icon: iconFor(w.icon),
                color: walletColor(w.color),
              ),
              title: Text(
                '${w.name}${w.archived
                    ? ' · Archived'
                    : w.id == app.walletId
                    ? ' · Active'
                    : ''}',
              ),
              subtitle: Text(
                '${w.currency} · ${money(app.data.balance(w), w.currency)}',
              ),
              onTap: w.archived
                  ? null
                  : () async {
                      await app.select(w.id);
                      if (context.mounted) {
                        message(context, 'Switched to ${w.name}');
                      }
                    },
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await push(context, WalletForm(app: app, existing: w));
                    return;
                  }
                  if (action == 'archive') {
                    await perform(
                      context,
                      app,
                      () => app.store.archiveWallet(w.id, !w.archived),
                      success: w.archived
                          ? 'Wallet restored'
                          : 'Wallet archived',
                    );
                    return;
                  }
                  final count = app.data.entries
                      .where((e) => e.walletId == w.id)
                      .length;
                  final yes = await confirm(
                    context,
                    title: 'Delete ${w.name}?',
                    body:
                        '$count transactions, all categories, groups, and loans in this wallet will be deleted. Wallets with transfers must have those transfers removed first.',
                  );
                  if (!yes || !context.mounted) return;
                  await perform(
                    context,
                    app,
                    () => app.store.deleteWallet(w.id),
                    success: 'Wallet deleted',
                  );
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit wallet'),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      w.archived ? 'Restore wallet' : 'Archive wallet',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete wallet',
                      style: TextStyle(color: AppTheme.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  );
}

class CategoriesPage extends StatefulWidget {
  final AppController app;
  const CategoriesPage({super.key, required this.app});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String kind = 'expense';
  bool showArchived = false;
  String query = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app;
      final roots = app.categories
          .where(
            (c) =>
                c.kind == kind &&
                c.parentId == null &&
                c.archived == showArchived,
          )
          .toList();
      Widget menu(Category c, {bool child = false}) => PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'edit') {
            await push(context, CategoryForm(app: app, existing: c));
            return;
          }
          if (action == 'child') {
            await push(
              context,
              CategoryForm(app: app, parentId: c.id, kind: c.kind),
            );
            return;
          }
          if (action == 'archive') {
            await perform(
              context,
              app,
              () => app.store.archiveCategory(c.id, !c.archived),
              success: 'Category updated',
            );
            return;
          }
          if (action == 'up' || action == 'down') {
            await perform(
              context,
              app,
              () => app.store.moveCategory(c.id, action == 'up' ? -1 : 1),
            );
            return;
          }
          final yes = await confirm(
            context,
            title: 'Delete ${c.name}?',
            body: child
                ? 'Transactions using this category will become uncategorised and remain in your wallet.'
                : 'This main category and its subcategories will be removed. Their transactions will become uncategorised and remain in your wallet.',
          );
          if (!yes || !context.mounted) return;
          await perform(
            context,
            app,
            () => app.store.deleteCategory(c.id),
            success: 'Category deleted',
          );
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit category')),
          if (!child && !c.archived)
            const PopupMenuItem(value: 'child', child: Text('Add subcategory')),
          const PopupMenuItem(value: 'up', child: Text('Move up')),
          const PopupMenuItem(value: 'down', child: Text('Move down')),
          PopupMenuItem(
            value: 'archive',
            child: Text(c.archived ? 'Restore category' : 'Archive category'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text(
              'Delete category',
              style: TextStyle(color: AppTheme.red),
            ),
          ),
        ],
      );

      Widget tile(Category c, {bool child = false}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: IconBadge(
          icon: categoryIcon(c, app.data),
          color: categoryColor(c, app.data),
        ),
        title: Text(c.name),
        trailing: menu(c, child: child),
        onTap: () => push(context, CategoryForm(app: app, existing: c)),
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => push(context, CategoryForm(app: app, kind: kind)),
          icon: const Icon(Icons.add),
          label: const Text('New category'),
        ),
        body: PageBody(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search categories',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase().trim()),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {kind},
              onSelectionChanged: (v) => setState(() => kind = v.first),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${roots.length} categories',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  FilterChip(
                    label: const Text('Archived'),
                    selected: showArchived,
                    labelStyle: TextStyle(
                      color: showArchived ? Colors.white : AppTheme.muted,
                    ),
                    onSelected: (v) => setState(() => showArchived = v),
                  ),
                ],
              ),
            ),
            if (roots.isEmpty)
              const EmptyState(
                icon: Icons.category_outlined,
                title: 'No categories here',
                detail: 'Create a main category, then add subcategories.',
              ),
            for (final c in roots.where(
              (c) =>
                  query.isEmpty ||
                  c.name.toLowerCase().contains(query) ||
                  app.categories.any(
                    (sub) =>
                        sub.parentId == c.id &&
                        sub.name.toLowerCase().contains(query),
                  ),
            )) ...[
              SurfacePanel(
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  key: ValueKey('${c.id}-$query'),
                  initiallyExpanded: query.isNotEmpty,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  leading: IconBadge(
                    icon: categoryIcon(c, app.data),
                    color: categoryColor(c, app.data),
                  ),
                  title: Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${app.categories.where((sub) => sub.parentId == c.id && sub.archived == showArchived).length} subcategories',
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.expand_more_rounded, size: 20),
                      menu(c),
                    ],
                  ),
                  children: [
                    const Divider(indent: 16, endIndent: 16),
                    for (final sub in app.categories.where(
                      (sub) =>
                          sub.parentId == c.id && sub.archived == showArchived,
                    ))
                      tile(sub, child: true),
                    if (!c.archived)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => push(
                            context,
                            CategoryForm(
                              app: app,
                              parentId: c.id,
                              kind: c.kind,
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add subcategory'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (showArchived)
              for (final c in app.categories.where(
                (c) =>
                    c.parentId != null &&
                    c.kind == kind &&
                    c.archived &&
                    app.data.category(c.parentId)?.archived == false,
              ))
                tile(c, child: true),
          ],
        ),
      );
    },
  );
}
