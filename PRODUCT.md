# Manavalan Finance

<!-- impeccable:product-schema 1 -->

## Platform
adaptive

## Users
An individual recording personal finances, related transaction ledgers, and money lent or borrowed.

## Product Purpose
Quick manual finance tracking with independent wallet workspaces and accurate, understandable balances.

## Capabilities and Constraints
- Android and iOS. Flutter with SQLite on the device.
- Multiple wallets; editable main categories and subcategories; transactions; groups; loans with partial repayments.
- Groups can be removed while retaining transactions or deleted with their transactions.
- Everything stays local. No accounts, analytics, backend, or automatic cloud sync.
- User has authorized replacing the old app entirely and committing major milestones.
- Currency defaults to INR, with a supported currency chosen per wallet.
- Backup/restore, export, and same-currency transfers are included practical additions from the accepted plan.

## Brand Commitments
The latest user request explicitly requires matching the supplied three-screen reference, overriding the previous violet-wide redesign. Use neutral #f6f6f6 canvas, white rounded cards, black text, thin Lucide outline icons, and pink/violet light localized to the upper balance surface. The overview follows the reference order: wallet/date header, inset glow with balance, four circular actions, compact wallet cards, individual transaction rows. Mobile navigation uses a small black selected circle in a quiet white bar; broad black split tabs remain excluded. Onboarding uses the reference's pink-violet gradient, fading diamond geometry and oversized regular type. Other screens inherit the neutral hierarchy and icons, keeping copy short. Preserve actual wallet/ledger semantics rather than copying banking claims, fake balances or unsupported actions. The original wallet icon uses the same pink-to-violet colors. Preserve the name Manavalan Finance.

## Product Principles
- Wallet context is visible wherever money is entered.
- A cash movement is recorded once; loan principal and repayments are excluded from ordinary income/spending.
- Money uses integer minor units and related changes are atomic.
- Destructive actions explain their effects before execution.
