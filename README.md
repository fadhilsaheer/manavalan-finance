# Manavalan Finance

A private Flutter finance tracker for Android and iOS, rebuilt on Flutter **3.47.5 / Dart 3.13.4**. All records stay on the device. No login, backend, telemetry, remote fonts, or automatic sync.

## Features

- Independent wallet workspaces with a persistent switcher, currency, starting balance, editable icon/colour, and archive controls.
- Income and expenses with editable dates, notes, searchable history, date/category/group/type filters, and exact balances.
- Editable main categories and subcategories, starter categories, icons, sibling reordering, archive and delete controls.
- Group ledgers with money in, spending, net and running balances. Create/select groups from transaction entry. Remove the group while retaining transactions, or delete its transactions too.
- Lent/borrowed ledgers with partial returns, additional advances, due dates, editable movements, and settled/archived views. Existing outstanding debts can be entered without inventing a cash movement.
- Same-currency transfers with linked entries, monthly summaries and category spending.
- Full JSON backup/restore with a private safety copy before replacement. CSV wallet/group exports and loan cash-movement exports.
- Catppuccin Mocha, original vector launcher art, native splash screens, compact navigation and tablet rail, system text scaling.

## Run

Use Flutter 3.47.5 (pinned in `.fvmrc`) or FVM with that version. Android requires Java 17 and the Android SDK; iOS requires macOS and Xcode. iOS plugins use Swift Package Manager; CocoaPods is not required.

```sh
flutter pub get
flutter run
```

Create a wallet on first launch. Starter categories are created independently for every wallet. Manage wallets and categories in Settings. Record loans in Lending; they are also visible as cash movements in Transactions.

## Accounting and data

Money is stored as integer minor units, with at most two input decimal places. Supported currencies: INR, USD, EUR, GBP, AED. Each wallet has one currency; its currency cannot change once entries or loans exist. Opening balances may be negative. Entries may create a negative cash balance.

Wallet balance is opening balance plus signed cash movements. Income/spending reports include only ordinary income and expenses. Transfers, lent principal, borrowed principal, and repayments affect cash but are excluded from those reports. Group net means income minus spending, rather than a debt owed. Loan outstanding is opening outstanding plus advances minus repayments. Overpayments and edits/deletions that invalidate a later repayment roll back atomically.

The new database is `manavalan.db` inside Application Support. Android app backups are disabled; the iOS support directory is excluded from iCloud backup. Exported files go to the destination the user selects. Keep a full backup before uninstalling or moving devices. CSV is a readable export, not a restorable backup; loan CSV contains cash movements, while JSON preserves opening debts and all relationships.

This is a fresh start, as requested. The old `finance.db` is not imported or deleted. Backups are schema-versioned and validated inside one SQLite transaction; invalid replacements leave current data intact. After a successful restore, Settings offers **Restore safety copy** to recover the previous data.

## Verification

```sh
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release --no-codesign
```

Tests cover decimal handling, backdated edits, wallet isolation, categories, both group-removal choices, partial repayments, loan corrections, transfers, rollback, backup restore, CSV escaping, onboarding, wallet switching and large text/small screen layouts.

For screenshots using synthetic test records and SDK-bundled fonts:

```sh
CAPTURE_QA=1 flutter test test/app_flow_test.dart
```

Images are written to `build/qa/`. Tests never populate the production database. Manual device checks should cover the native file picker, keyboard/back gestures, airplane mode and restart persistence.

## Launcher artwork

The original artwork lives in `assets/icon/app-icon.svg` and `BrandPainter`. To regenerate PNG and native sizes, install Pillow in your build tooling, then run:

```sh
flutter test tool/render_icon_test.dart
python3 tool/generate_icons.py
```

The iOS icons are opaque RGB. Android includes adaptive foreground/background assets.

## Structure

`lib/core` contains the money/domain types and app state. `lib/data` owns SQLite constraints, atomic ledger operations, starter categories and file exports. `lib/ui` contains the theme, shared controls, forms, primary pages, ledger details and settings. See `PRODUCT.md`, `DESIGN.md` and `IMPLEMENTATION.md` for the product and rebuild decisions.

## Distribution

Android release APKs currently use the template's debug signing key for local installation. Configure your own release keystore and final application ID before Play Store distribution. The verified iOS device build is unsigned; choose your signing team and provisioning before installing on hardware or submitting to the App Store.

Budgets, recurring entries, interest, receipt attachments, exchange rates and bank imports are outside this release.
