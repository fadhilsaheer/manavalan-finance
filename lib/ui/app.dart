import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import 'forms.dart';
import 'ledger_pages.dart';
import 'settings.dart';
import 'shared.dart';
import 'theme.dart';

class FinanceApp extends StatelessWidget {
  final AppController controller;
  const FinanceApp({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Manavalan Finance',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: AppShell(app: controller),
  );
}

class AppShell extends StatefulWidget {
  final AppController app;
  const AppShell({super.key, required this.app});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  static const labels = ['Overview', 'Transactions', 'Groups', 'Lending'];
  static const icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.folder_outlined,
    Icons.handshake_outlined,
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app, wallet = widget.app.wallet;
      final expanded = MediaQuery.sizeOf(context).width >= 760;
      final body = wallet == null
          ? PageBody(
              children: [
                const SizedBox(height: 48),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BrandMark(size: 96),
                ),
                const SizedBox(height: 28),
                Text(
                  'Make room for your money.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Every wallet. Every expense. Just on your device.',
                  style: TextStyle(color: AppTheme.muted),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => push(context, WalletForm(app: app)),
                  icon: const Icon(Icons.add),
                  label: const Text('Create your first wallet'),
                ),
                if (app.data.wallets.any((w) => w.archived))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton(
                      onPressed: () => push(context, WalletsPage(app: app)),
                      child: const Text('Manage archived wallets'),
                    ),
                  ),
              ],
            )
          : KeyedSubtree(
              key: ValueKey(wallet.id),
              child: IndexedStack(
                index: tab,
                children: [
                  OverviewPage(app: app),
                  TransactionsPage(app: app),
                  GroupsPage(app: app),
                  LendingPage(app: app),
                ],
              ),
            );
      return Scaffold(
        appBar: AppBar(
          title: wallet == null
              ? const Text('Manavalan Finance')
              : PopupMenuButton<int>(
                  tooltip: 'Switch wallet',
                  onSelected: (id) async {
                    if (id == -1) {
                      await push(context, WalletForm(app: app));
                    } else if (id == -2) {
                      await push(context, WalletsPage(app: app));
                    } else {
                      try {
                        await app.select(id);
                      } catch (_) {
                        if (context.mounted) {
                          message(
                            context,
                            'Wait for the current save to finish.',
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    for (final w in app.data.wallets.where((w) => !w.archived))
                      PopupMenuItem(
                        value: w.id,
                        child: Row(
                          children: [
                            Icon(iconFor(w.icon), color: walletColor(w.color)),
                            const SizedBox(width: 12),
                            Expanded(child: Text('${w.name} · ${w.currency}')),
                            if (w.id == wallet.id)
                              const Icon(Icons.check, color: AppTheme.accent),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: -1,
                      child: Text('Create wallet'),
                    ),
                    const PopupMenuItem(
                      value: -2,
                      child: Text('Manage wallets'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          iconFor(wallet.icon),
                          color: walletColor(wallet.color),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            wallet.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                  ),
                ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () => push(context, SettingsPage(app: app)),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (app.busy) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: Row(
                  children: [
                    if (expanded && wallet != null)
                      NavigationRail(
                        selectedIndex: tab,
                        onDestinationSelected: (v) => setState(() => tab = v),
                        labelType: NavigationRailLabelType.all,
                        destinations: List.generate(
                          4,
                          (i) => NavigationRailDestination(
                            icon: Icon(icons[i]),
                            label: Text(labels[i]),
                          ),
                        ),
                      ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: !expanded && wallet != null
            ? DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.surface)),
                ),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    indicatorColor: AppTheme.lavender.withValues(alpha: .45),
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    iconTheme: WidgetStateProperty.resolveWith(
                      (states) => IconThemeData(
                        color: states.contains(WidgetState.selected)
                            ? AppTheme.accent
                            : AppTheme.muted,
                        size: 23,
                      ),
                    ),
                    labelTextStyle: WidgetStateProperty.resolveWith(
                      (states) => TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        fontWeight: states.contains(WidgetState.selected)
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: states.contains(WidgetState.selected)
                            ? AppTheme.accent
                            : AppTheme.muted,
                      ),
                    ),
                    height: 76,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                  ),
                  child: NavigationBar(
                    selectedIndex: tab,
                    onDestinationSelected: (v) => setState(() => tab = v),
                    destinations: List.generate(
                      4,
                      (i) => NavigationDestination(
                        icon: Icon(icons[i]),
                        label: labels[i],
                        tooltip: labels[i],
                      ),
                    ),
                  ),
                ),
              )
            : null,
      );
    },
  );
}
