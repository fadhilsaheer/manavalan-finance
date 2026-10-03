# Rebuild and redesign verification

Checked with Flutter 3.47.5 / Dart 3.13.4 on 28 September 2026.

## Automated checks

- `flutter analyze`: clean.
- `flutter test`: 24 tests across domain, database, UI workflows and CSV handling.
- Android debug APK and iOS simulator debug app: built successfully.
- Android release APK: built successfully, using the template debug key for local installation.
- iOS device release app: built successfully with code signing disabled.
- iOS dependencies migrated from CocoaPods to Swift Package Manager.

## Original rebuild review

The independent Impeccable finish reviewer returned **ship** after the correction batch:

| Finding | Final verdict |
| --- | --- |
| Removed filters could hide retained transactions | Resolved: validated IDs drive both selection and filtering; regression test passes. |
| Loan entries lacked explicit cash meaning | Resolved: lent, borrowed, received and paid labels plus form cash effects. |
| Negative running balance split its sign from its amount | Resolved: amount stays together across the row width. |

Mocha direction, phone navigation, tablet rail, group ledgers, repayment detail, entry forms and illustrative QA screenshots were reviewed. The mechanical UI detector reported no findings. All screenshot data comes from isolated test databases and is not included in a new user's ledger.

## Light-theme redesign — 28 September 2026

- Replaced Mocha with a light gray canvas, white rounded panels, blue balance card, compact dark mobile navigation and separate add action.
- Added prominent amount fields, a fixed save action, collapsible notes/icon choices, and on-demand transaction filters.
- Recolored original vector artwork and regenerated native icon/splash assets.
- `flutter analyze`: clean. The full 24-test suite passed; all 9 UI tests passed again after the final chip-label correction.
- Native release builds passed: Android APK (53.5 MB, local debug signing), iOS device app (17.9 MB, unsigned).
- Captures cover 390×844 phone, 1100×900 tablet, forms, groups and loan ledgers. Existing 320×740 at 2× text-scale checks pass.
- Navigation tests now target accessible tooltips and fail on missed taps. Group-filter retention regression remains covered.
- The visual detector reported no findings. Screenshot balances are isolated test data.

The independent finish reviewer returned **ship** for the redesign:

| Material fix | Result |
| --- | --- |
| Lending chip labels | Resolved: Open, Settled and Archived render legibly. |
| Design documentation | Resolved: DESIGN.md and the sidecar describe the implemented light/blue direction. |

## Practical limits

Native file-picker interaction, VoiceOver/TalkBack, real-device keyboard/back gestures and long-running device use still need hardware verification. The iOS release build needs signing for installation. Store publishing requires final app identifiers and production signing. There is no old-database migration because the user explicitly requested a fresh start; the old database file is left untouched.


## Category UX and violet redesign — 3 October 2026

- Replaced flat category selection with searchable parent icon grids, explicit subcategory browsing, recent shortcuts, cancellation/clearing semantics, and inline category creation. Archived and income/expense choices remain scoped correctly.
- Added a group selector, searchable icon library, semantic icons for existing seeded subcategories, and expandable category management.
- Revised transaction, group, loan, wallet, settings and form hierarchy using grouped surfaces. Fixed the clipped extended add button. Matched original native launcher artwork to violet and pink.
- Full regression suite: 28 tests pass (15 domain/database, 13 UI/CSV). Coverage includes category drill-down, search, cancellation, clearing, archived filtering, type isolation, grouped management and 320×740 at 2× text.
- Screenshot coverage includes phone/tablet category pickers, category search and subcategories, management, icon library, forms, all tabs, transaction detail, wallets, settings and ledgers. Data is isolated test data.
- A narrow-screen transfer action now wraps rather than overflowing with wide text. Interactive grouped panels use Material so taps and ink remain visible.
- Detector: no findings. Independent review matched visual fidelity; documentation synchronization was the only material finding.
- Final native builds: Android release APK (53.7 MB, local debug signing) and iOS device release app (18.0 MB, unsigned). Static analysis is clean.

Final independent review: **ship**.

| Finding | Status |
| --- | --- |
| Persist the implemented design | Resolved: DESIGN.md and the sidecar match the violet/pink balances, black actions, white navigation and category hierarchy. |
