import 'dart:io';

import 'package:flutter/services.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:manavalan_finance/core/app_controller.dart';
import 'package:manavalan_finance/core/models.dart';
import 'package:manavalan_finance/data/file_service.dart';
import 'package:manavalan_finance/data/ledger_store.dart';
import 'package:manavalan_finance/ui/app.dart';
import 'package:manavalan_finance/ui/navigation.dart';
import 'package:manavalan_finance/ui/ledger_pages.dart';
import 'package:manavalan_finance/ui/details.dart';
import 'package:manavalan_finance/ui/forms.dart';
import 'package:manavalan_finance/ui/settings.dart';
import 'package:manavalan_finance/ui/theme.dart';
import 'package:manavalan_finance/ui/shared.dart';
import 'package:manavalan_finance/ui/category_picker.dart';

void main() {
  late LedgerStore store;
  late AppController app;
  final capture = Platform.environment['CAPTURE_QA'] == '1';
  final boundaryKey = GlobalKey();
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  setUpAll(() async {
    sqfliteFfiInit();
    if (capture) {
      final loader = FontLoader('Roboto');
      for (final weight in ['Regular', 'Medium', 'Bold']) {
        loader.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
      }
      await loader.load();
      final lines = FontLoader('packages/lucide_icons_flutter/Lucide300')
        ..addFont(
          rootBundle.load(
            'packages/lucide_icons_flutter/assets/build_font/LucideVariable-w300.ttf',
          ),
        );
      await lines.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });
  setUp(() async {
    store = await LedgerStore.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    app = AppController(store);
    await app.init();
  });
  tearDown(() async {
    app.dispose();
    await store.db.close();
  });

  Future<void> show(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    Widget? page,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: page == null
            ? FinanceApp(controller: app)
            : MaterialApp(
                theme: AppTheme.theme,
                home: page,
                debugShowCheckedModeBanner: false,
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    if (!capture) return;
    await tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/qa').create(recursive: true);
      await File('build/qa/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final wallet = await store.saveWallet(
        name: 'Personal',
        currency: 'INR',
        opening: 1250000,
      );
      app.walletId = wallet;
      final category = (await store.snapshot()).categories.firstWhere(
        (c) => c.name == 'Groceries',
      );
      final group = await store.saveGroup(
        walletId: wallet,
        name: 'Goa trip',
        note: 'Test ledger for a weekend away.',
      );
      final today = dayKey(DateTime.now());
      await store.saveEntry(
        walletId: wallet,
        amount: 2800000,
        kind: EntryKind.income,
        date: today,
        note: 'Monthly salary',
      );
      await store.saveEntry(
        walletId: wallet,
        amount: 185050,
        kind: EntryKind.expense,
        date: today,
        categoryId: category.id,
        note: 'Weekly groceries',
      );
      await store.saveEntry(
        walletId: wallet,
        amount: 350000,
        kind: EntryKind.expense,
        date: today,
        groupId: group,
        note: 'Accommodation',
      );
      final loan = await store.createLoan(
        walletId: wallet,
        person: 'Arjun',
        direction: 'lent',
        amount: 500000,
        date: today,
      );
      await store.loanMovement(
        loan,
        amount: 150000,
        repayment: true,
        date: today,
        note: 'First partial return',
      );
      await store.saveWallet(
        name: 'Savings',
        currency: 'INR',
        opening: 5000000,
        icon: 'bank',
        color: 1,
      );
      await app.reload();
    });
  }

  testWidgets('first wallet can be created through onboarding', (tester) async {
    await show(tester);
    await screenshot(tester, 'onboarding');
    await tester.tap(find.byTooltip('Create your first wallet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Personal');
    await tester.ensureVisible(find.text('Save'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pumpAndSettle();
    expect(app.wallet?.name, 'Personal');
    expect(find.text('Wallet balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('wallet switch isolates ledger and survives reload', (
    tester,
  ) async {
    await seed(tester);
    await show(tester);
    await screenshot(tester, 'overview-mobile');
    await tester.tap(find.byTooltip('Switch wallet'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Savings · INR'));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pumpAndSettle();
    expect(app.wallet?.name, 'Savings');
    expect(app.entries, isEmpty);
    await tester.runAsync(() => app.init());
    expect(app.wallet?.name, 'Savings');
    expect(tester.takeException(), isNull);
  });
  testWidgets('overview actions preserve income intent and open history', (
    tester,
  ) async {
    await seed(tester);
    await show(tester);
    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pumpAndSettle();
    expect(find.text('••••••'), findsOneWidget);
    await tester.tap(find.byTooltip('Income'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FlowTabs<EntryKind>>(find.byType(FlowTabs<EntryKind>))
          .selected,
      {EntryKind.income},
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(TextButton, 'View all').last,
    );
    await tester.tap(find.widgetWithText(TextButton, 'View all').last);
    await tester.pumpAndSettle();
    expect(find.byTooltip('New transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'tab motion is visible, preserves filters, and respects reduced motion',
    (tester) async {
      await seed(tester);
      await show(tester);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).first).extendBody,
        isTrue,
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -260));
      await tester.pumpAndSettle();
      await screenshot(tester, 'navigation-glass');
      final indicator = find.byKey(const ValueKey('navigation-indicator'));
      final start = tester.getTopLeft(indicator).dx;
      await tester.tap(find.byTooltip('Transactions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final middle = tester.getTopLeft(indicator).dx;
      expect(middle, greaterThan(start));
      expect(
        find.descendant(
          of: find.byType(AnimatedTabDeck),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity > 0 && w.opacity < 1,
          ),
        ),
        findsWidgets,
      );
      await screenshot(tester, 'tab-transition');
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(indicator).dx, greaterThan(middle));
      await tester.enterText(find.byType(TextField).first, 'Groceries');
      await tester.tap(find.byTooltip('Groups'));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byTooltip('Lending'));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.byTooltip('Transactions'));
      await tester.pumpAndSettle();
      final search = find.descendant(
        of: find.byType(TransactionsPage),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(search).controller.text, 'Groceries');
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Groups'));
      await tester.pump();
      expect(
        tester.widget<AnimatedPositioned>(indicator).duration,
        Duration.zero,
      );
      expect(
        find.descendant(
          of: find.byType(AnimatedTabDeck),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity > 0 && w.opacity < 1,
          ),
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('transaction form validates amount and saves linked group', (
    tester,
  ) async {
    await seed(tester);
    final group = app.groups.first;
    await show(
      tester,
      page: TransactionForm(app: app, groupId: group.id),
    );
    await screenshot(tester, 'new-transaction');
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Enter an amount greater than zero and within the supported limit.',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField).first, '125.50');
    await tester.ensureVisible(find.text('Save'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pumpAndSettle();
    expect(app.entries.first.amount, 12550);
    expect(app.entries.first.groupId, group.id);
    expect(tester.takeException(), isNull);
  });
  testWidgets('ledger detail pages render repayment and group totals', (
    tester,
  ) async {
    await seed(tester);
    await show(
      tester,
      page: GroupDetail(app: app, groupId: app.groups.first.id),
    );
    await screenshot(tester, 'group-ledger');
    expect(find.text('Net balance'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await show(
      tester,
      page: LoanDetail(app: app, loanId: app.loans.first.id),
    );
    await screenshot(tester, 'loan-ledger');
    expect(find.text('Record repayment'), findsOneWidget);
    expect(find.text('₹3,500.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('tablet navigation and small-screen large text stay usable', (
    tester,
  ) async {
    await seed(tester);
    await show(tester, size: const Size(1100, 900));
    await screenshot(tester, 'overview-tablet');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
    await show(tester, size: const Size(320, 740), textScale: 2);
    expect(tester.takeException(), isNull);
    await show(
      tester,
      size: const Size(320, 740),
      textScale: 2,
      page: SettingsPage(app: app),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('all primary destinations render without errors', (tester) async {
    await seed(tester);
    await show(tester);
    for (final title in ['Transactions', 'Groups', 'Lending']) {
      await tester.tap(find.byTooltip(title));
      await tester.pumpAndSettle();
      await screenshot(tester, title.toLowerCase());
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('removed group filter no longer hides surviving transactions', (
    tester,
  ) async {
    await seed(tester);
    await show(tester);
    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    final groupFilter = find.byType(DropdownButtonFormField<int>).last;
    await tester.ensureVisible(groupFilter);
    await tester.tap(groupFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goa trip').last);
    await tester.pumpAndSettle();
    expect(find.text('1 transaction'), findsOneWidget);
    await tester.runAsync(
      () => app.change(
        () => store.dissolveGroup(app.groups.first.id, deleteEntries: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('5 transactions'), findsOneWidget);
    await tester.ensureVisible(find.text('5 transactions'));
    await screenshot(tester, 'filtered-group-removed');
    expect(tester.takeException(), isNull);
  });

  testWidgets('repayment form explains the cash direction', (tester) async {
    await seed(tester);
    await show(
      tester,
      page: LoanMovementForm(app: app, loan: app.loans.first),
    );
    expect(
      find.text('Repayment received · wallet cash increases.'),
      findsOneWidget,
    );
    await screenshot(tester, 'repayment-received');
    expect(tester.takeException(), isNull);
  });
  testWidgets('category picker drills down, searches, cancels and clears', (
    tester,
  ) async {
    await seed(tester);
    await show(tester, page: TransactionForm(app: app));
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await screenshot(tester, 'category-picker');
    await tester.ensureVisible(find.text('Food & drink').last);
    await tester.tap(find.text('Food & drink').last);
    await tester.pumpAndSettle();
    await screenshot(tester, 'category-subcategories');
    expect(find.text('Restaurants'), findsOneWidget);
    await tester.tap(find.text('Restaurants'));
    await tester.pumpAndSettle();
    expect(find.text('Food & drink / Restaurants'), findsOneWidget);
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close categories'));
    await tester.pumpAndSettle();
    expect(find.text('Food & drink / Restaurants'), findsOneWidget);
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'fuel');
    await tester.pumpAndSettle();
    expect(find.text('Fuel'), findsOneWidget);
    await screenshot(tester, 'category-search');
    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();
    expect(find.text('Transport / Fuel'), findsOneWidget);
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uncategorised'));
    await tester.pumpAndSettle();
    expect(find.text('Uncategorised'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category picker isolates kind and archived categories', (
    tester,
  ) async {
    await seed(tester);
    final food = app.categories.firstWhere((c) => c.name == 'Food & drink');
    await tester.runAsync(
      () => app.change(() => store.archiveCategory(food.id, true)),
    );
    await show(
      tester,
      page: CategoryPicker(app: app, kind: 'expense'),
    );
    expect(find.text('Food & drink'), findsNothing);
    expect(find.text('Salary'), findsNothing);
    await tester.enterText(find.byType(TextField), 'groceries');
    await tester.pumpAndSettle();
    expect(find.text('No categories found'), findsOneWidget);
    await show(
      tester,
      page: CategoryPicker(key: UniqueKey(), app: app, kind: 'income'),
    );
    expect(find.text('Income'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'secondary screens and category management render with real hierarchy',
    (tester) async {
      await seed(tester);
      await show(tester, page: CategoriesPage(app: app));
      await screenshot(tester, 'categories');
      await tester.tap(find.text('Food & drink').last);
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsOneWidget);
      await screenshot(tester, 'categories-expanded');
      expect(
        tester.getSize(find.byType(FloatingActionButton)).width,
        greaterThan(120),
      );
      await show(tester, page: SettingsPage(app: app));
      await screenshot(tester, 'settings');
      await show(tester, page: WalletsPage(app: app));
      await screenshot(tester, 'wallets');
      await show(
        tester,
        page: EntryDetail(app: app, entryId: app.entries.first.id),
      );
      await screenshot(tester, 'transaction-detail');
      await show(tester, page: CategoryForm(app: app));
      await screenshot(tester, 'new-category');
      await tester.tap(find.text('Icon'));
      await tester.pumpAndSettle();
      await screenshot(tester, 'icon-library');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pickers and forms support small phones with large text', (
    tester,
  ) async {
    await seed(tester);
    for (final page in <Widget>[
      CategoryPicker(app: app, kind: 'expense'),
      CategoriesPage(app: app),
      TransactionForm(app: app),
      LoanForm(app: app),
    ]) {
      await show(tester, size: const Size(320, 740), textScale: 2, page: page);
      expect(tester.takeException(), isNull);
    }
    await show(
      tester,
      size: const Size(1100, 900),
      page: CategoryPicker(app: app, kind: 'expense'),
    );
    await screenshot(tester, 'category-picker-tablet');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'empty groups and lending offer contextual actions without dark split controls',
    (tester) async {
      await tester.runAsync(() async {
        app.walletId = await store.saveWallet(
          name: 'Personal',
          currency: 'INR',
          opening: 0,
        );
        await app.reload();
      });
      await show(tester);
      await tester.tap(find.byTooltip('Groups'));
      await tester.pumpAndSettle();
      await screenshot(tester, 'groups-empty');
      expect(find.byType(SegmentedButton<bool>), findsNothing);
      expect(find.text('Create group'), findsOneWidget);
      await tester.tap(find.byTooltip('Lending'));
      await tester.pumpAndSettle();
      await screenshot(tester, 'lending-empty');
      await tester.tap(find.text('You owe'));
      await tester.pumpAndSettle();
      await screenshot(tester, 'lending-borrowed-empty');
      await tester.ensureVisible(find.text('Add borrowed money'));
      await tester.tap(find.text('Add borrowed money'));
      await tester.pumpAndSettle();
      final tabs = tester.widget<FlowTabs<String>>(
        find.byType(FlowTabs<String>),
      );
      expect(tabs.selected, {'borrowed'});
      await screenshot(tester, 'new-borrowed-loan');
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await show(tester, size: const Size(320, 740), textScale: 2);
      await tester.tap(find.byTooltip('Groups'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Lending'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  test('CSV correctly escapes and neutralises spreadsheet formulas', () {
    final data = LedgerSnapshot(
      wallets: const [
        Wallet({'id': 1, 'name': 'Personal', 'currency': 'INR'}),
      ],
      entries: const [
        Entry({
          'id': 1,
          'wallet_id': 1,
          'amount': 1234,
          'sign': -1,
          'kind': 'expense',
          'date': '2026-09-28',
          'note': '=SUM(A1,A2) "quoted"\nsecond line',
        }),
      ],
    );
    final csv = FileService.csv(data, data.entries);
    expect(csv, contains('"12.34"'));
    expect(csv, contains('"\'=SUM(A1,A2) ""quoted""\nsecond line"'));
  });
}
