# Rebuild milestones

1. Modern Flutter Android/iOS baseline, precise local ledger, categories, transfers, groups and loan rules; domain tests.
2. Complete Catppuccin app: wallet switching, transaction management, category hierarchy, groups, lending, overview and original launcher icon.
3. Backup/restore and CSV export, integration checks, native builds and documentation.

Commit only after each major milestone is validated. The rebuild uses a new `manavalan.db` database; the old `finance.db` file is not deleted or imported automatically. The user authorized a fresh start.

## Accounting

Wallet balance = opening amount + all signed cash movements. Income/expense summaries include only ordinary income and expenses. Transfers and loan movements change cash but not those summaries. Loan outstanding = opening outstanding + advances - repayments. An ordinary group's net = income - expenses.

## Scope

Android and iOS. All persistence is local. No automatic network requests. Backups and exports are written only to user-selected destinations. Budgets, scheduled entries, receipt storage, interest calculations and exchange rates are future work.

## Completed

- Milestone 1: modern mobile templates, precise ledger and 13 initial domain tests (`ed05028`).
- Milestone 2: complete app, original icons, local backup/export, Swift Package Manager migration and release builds (`df5ef0d`).
- Final milestone: native splash assets, reproducible icon tooling, setup/accounting documentation and recorded validation. Current suite: 24 tests.

All independent design review material findings are resolved; disposition: ship. See `docs/VALIDATION.md` for check results and device-verification limits.
