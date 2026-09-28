# Rebuild verification

Checked with Flutter 3.47.5 / Dart 3.13.4 on 28 September 2026.

## Automated checks

- `flutter analyze`: clean.
- `flutter test`: 24 tests across domain, database, UI workflows and CSV handling.
- Android debug APK and iOS simulator debug app: built successfully.
- Android release APK: built successfully, using the template debug key for local installation.
- iOS device release app: built successfully with code signing disabled.
- iOS dependencies migrated from CocoaPods to Swift Package Manager.

## Design review

The independent Impeccable finish reviewer returned **ship** after the correction batch:

| Finding | Final verdict |
| --- | --- |
| Removed filters could hide retained transactions | Resolved: validated IDs drive both selection and filtering; regression test passes. |
| Loan entries lacked explicit cash meaning | Resolved: lent, borrowed, received and paid labels plus form cash effects. |
| Negative running balance split its sign from its amount | Resolved: amount stays together across the row width. |

Mocha direction, phone navigation, tablet rail, group ledgers, repayment detail, entry forms and illustrative QA screenshots were reviewed. The mechanical UI detector reported no findings. All screenshot data comes from isolated test databases and is not included in a new user's ledger.

## Practical limits

Native file-picker interaction, VoiceOver/TalkBack, real-device keyboard/back gestures and long-running device use still need hardware verification. The iOS release build needs signing for installation. Store publishing requires final app identifiers and production signing. There is no old-database migration because the user explicitly requested a fresh start; the old database file is left untouched.
