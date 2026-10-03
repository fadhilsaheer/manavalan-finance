import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import 'forms.dart';
import 'ledger_pages.dart';
import 'settings.dart';
import 'shared.dart';
import 'theme.dart';
import 'reference_surfaces.dart';
import 'navigation.dart';

import 'package:intl/intl.dart';

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
    LucideIcons.house300,
    LucideIcons.receiptText300,
    LucideIcons.folder300,
    LucideIcons.handCoins300,
  ];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app, wallet = widget.app.wallet;
      final expanded = MediaQuery.sizeOf(context).width >= 760;
      final body = wallet == null
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: BalanceGlow(
                      immersive: true,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: constraints.maxHeight * .55),
                            DefaultTextStyle(
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: AppTheme.text,
                                fontSize: 40,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -1.2,
                                height: 1.25,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 12,
                                    children: [
                                      const Text('Personal'),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.overlay,
                                          ),
                                        ),
                                        child: const Icon(
                                          LucideIcons.wallet300,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text('Finance, all\nin one place.'),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Get started',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                IconButton.filled(
                                  tooltip: 'Create your first wallet',
                                  onPressed: () =>
                                      push(context, WalletForm(app: app)),
                                  icon: const Icon(LucideIcons.arrowRight300),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(52, 52),
                                  ),
                                ),
                              ],
                            ),
                            if (app.data.wallets.any((w) => w.archived))
                              TextButton(
                                onPressed: () =>
                                    push(context, WalletsPage(app: app)),
                                child: const Text('Manage archived wallets'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : KeyedSubtree(
              key: ValueKey(wallet.id),
              child: AnimatedTabDeck(
                index: tab,
                children: [
                  OverviewPage(
                    app: app,
                    onTransactions: () => setState(() => tab = 1),
                  ),
                  TransactionsPage(app: app),
                  GroupsPage(app: app),
                  LendingPage(app: app),
                ],
              ),
            );
      return Scaffold(
        extendBody: !expanded && wallet != null,
        appBar: wallet == null
            ? null
            : AppBar(
                toolbarHeight: 84,
                title: PopupMenuButton<int>(
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
                              const Icon(
                                LucideIcons.check300,
                                color: AppTheme.accent,
                              ),
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
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('EEEE, d MMMM')
                                    .format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.chevronDown300),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Manage wallets',
                    onPressed: () => push(context, WalletsPage(app: app)),
                    icon: const Icon(LucideIcons.wallet300),
                  ),
                ],
              ),
        body: SafeArea(
          top: false,
          bottom: expanded || wallet == null,
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
                        trailing: IconButton(
                          tooltip: 'Settings',
                          onPressed: () =>
                              push(context, SettingsPage(app: app)),
                          icon: const Icon(LucideIcons.menu300),
                        ),
                        destinations: List.generate(
                          4,
                          (i) => NavigationRailDestination(
                            icon: Icon(icons[i]),
                            selectedIcon: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: AppTheme.text,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icons[i],
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
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
            ? SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(28, 6, 28, 12),
                child: FrostedNavigation(
                  index: tab,
                  icons: [...icons, LucideIcons.menu300],
                  labels: [...labels, 'Settings'],
                  onSelected: (v) => v == 4
                      ? push(context, SettingsPage(app: app))
                      : setState(() => tab = v),
                ),
              )
            : null,
      );
    },
  );
}
