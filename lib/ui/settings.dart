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
                        style: TextStyle(color: Mocha.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SectionTitle('Manage'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Wallets'),
              subtitle: const Text('Create, edit, archive, or switch'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(context, WalletsPage(app: app)),
            ),
            if (app.wallet != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categories'),
                subtitle: Text('For ${app.wallet!.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => push(context, CategoriesPage(app: app)),
              ),
            const SectionTitle('Backup & export'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.save_alt),
              title: const Text('Save full backup'),
              subtitle: const Text(
                'All wallets, groups, loans, and settings · JSON',
              ),
              enabled: !working,
              onTap: () => fileAction(() async {
                final saved = await FileService.save(
                  'manavalan-${dayKey(DateTime.now())}.json',
                  await app.store.backup(),
                  'json',
                );
                if (context.mounted && saved) message(context, 'Backup saved');
              }),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
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
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.undo),
                title: const Text('Restore safety copy'),
                subtitle: const Text(
                  'Recover the data from before your last restore',
                ),
                enabled: !working,
                onTap: () => fileAction(() async {
                  await restore(await File(safetyPath!).readAsString());
                }),
              ),
            if (app.wallet != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
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
                  if (context.mounted && saved) message(context, 'CSV saved');
                }),
              ),
            const SectionTitle('Local privacy'),
            const Text(
              'Everything is stored locally. There is no account, server, analytics, or automatic sync. Keep a backup before changing devices or uninstalling the app. Files go only to the destination you choose.',
              style: TextStyle(color: Mocha.muted),
            ),
            const SizedBox(height: 20),
            const Text(
              'Catppuccin Mocha · Version 2.0.0',
              style: TextStyle(color: Mocha.muted),
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
              contentPadding: EdgeInsets.zero,
              leading: Icon(iconFor(w.icon), color: walletColor(w.color)),
              title: Text('${w.name}${w.archived ? ' · Archived' : ''}'),
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
                      style: TextStyle(color: Mocha.red),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
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
      Widget tile(Category c, {bool child = false}) => Padding(
        padding: EdgeInsets.only(left: child ? 28 : 0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            iconFor(c.icon),
            color: child ? Mocha.muted : Mocha.mauve,
          ),
          title: Text(c.name),
          subtitle: child ? null : const Text('Main category'),
          onTap: () => push(context, CategoryForm(app: app, existing: c)),
          trailing: PopupMenuButton<String>(
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
                const PopupMenuItem(
                  value: 'child',
                  child: Text('Add subcategory'),
                ),
              const PopupMenuItem(value: 'up', child: Text('Move up')),
              const PopupMenuItem(value: 'down', child: Text('Move down')),
              PopupMenuItem(
                value: 'archive',
                child: Text(
                  c.archived ? 'Restore category' : 'Archive category',
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete category',
                  style: TextStyle(color: Mocha.red),
                ),
              ),
            ],
          ),
        ),
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
            Text(
              app.wallet?.name ?? '',
              style: const TextStyle(color: Mocha.mauve),
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
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show archived'),
              value: showArchived,
              onChanged: (v) => setState(() => showArchived = v),
            ),
            if (roots.isEmpty)
              const EmptyState(
                icon: Icons.category_outlined,
                title: 'No categories here',
                detail: 'Create a main category, then add subcategories.',
              ),
            for (final c in roots) ...[
              tile(c),
              for (final sub in app.categories.where(
                (sub) => sub.parentId == c.id && sub.archived == showArchived,
              ))
                tile(sub, child: true),
              const Divider(),
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
