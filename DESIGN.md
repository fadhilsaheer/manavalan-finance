---
name: Manavalan Finance
description: A Catppuccin Mocha workspace for operating local personal ledgers.
colors:
  base: "#1e1e2e"
  mantle: "#181825"
  surface: "#313244"
  overlay: "#585b70"
  text: "#cdd6f4"
  muted: "#a6adc8"
  mauve: "#cba6f7"
  green: "#a6e3a1"
  red: "#f38ba8"
  peach: "#fab387"
  blue: "#89b4fa"
  yellow: "#f9e2af"
typography:
  display:
    fontSize: "36px"
    fontWeight: 400
    lineHeight: 1.22
    letterSpacing: "0px"
  balance:
    fontSize: "36px"
    fontWeight: 600
    lineHeight: 1.22
    letterSpacing: "0px"
  headline:
    fontSize: "32px"
    fontWeight: 400
    lineHeight: 1.25
    letterSpacing: "0px"
  title:
    fontSize: "22px"
    fontWeight: 400
    lineHeight: 1.27
    letterSpacing: "0px"
  entry-title:
    fontSize: "16px"
    fontWeight: 500
    lineHeight: 1.5
    letterSpacing: "0.15px"
  body:
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.43
    letterSpacing: "0.25px"
  detail:
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.33
    letterSpacing: "0.4px"
  label:
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.43
    letterSpacing: "0.1px"
rounded:
  control: "12px"
  choice: "8px"
  bar: "3px"
spacing:
  tight: "4px"
  compact: "8px"
  related: "12px"
  standard: "16px"
  page: "20px"
  group: "24px"
  section: "28px"
components:
  button-primary:
    backgroundColor: "{colors.mauve}"
    textColor: "{colors.mantle}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    height: "50px"
  button-outlined:
    textColor: "{colors.mauve}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    height: "48px"
  button-destructive:
    backgroundColor: "{colors.red}"
    textColor: "{colors.mantle}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    height: "50px"
  field:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    rounded: "{rounded.control}"
    padding: "16px 16px"
  navigation-mobile:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    height: "76px"
  choice-selected:
    backgroundColor: "{colors.blue}"
    textColor: "{colors.mantle}"
    rounded: "{rounded.choice}"
  ledger-row:
    textColor: "{colors.text}"
    typography: "{typography.entry-title}"
    rounded: "{rounded.control}"
    padding: "14px 4px"
  spending-bar:
    backgroundColor: "{colors.mauve}"
    rounded: "{rounded.bar}"
    height: "6px"
---

# Design System: Manavalan Finance

## Overview

**Creative North Star: "The Wallet Workspace"**

The Wallet Workspace describes the built app: an operational space for manual finance entries, wallet balances, group ledgers, and lending. Catppuccin Mocha gives the dark canvas a quiet character; labels, exact amounts, and native controls carry the information. The selected wallet is persistent context, and cash direction stays explicit.

The implementation is Flutter Material 3 for Android and iOS. Open sections and divided ledger rows establish the main spatial grammar. Navigation, date pickers, dialogs, focus feedback, and route transitions retain their native behavior. The original geometric wallet and rising bars supply the identity. There is no approved external comp or quality board; this record follows the finished source and supplied QA captures.

**Key Characteristics:**
- Dark tonal surfaces with mauve actions and semantic cash colors.
- Open financial sections, labelled statistics, and divided ledger rows.
- Four mobile destinations, adapting to a labelled rail on wider screens.
- System typography, text scaling, and platform navigation behavior.
- Original wallet and bar-chart identity; no illustrative stock artwork.

## Colors

Catppuccin Mocha combines dark indigo neutrals with soft mauve actions and functional cash colors. The frontmatter is the normative palette; these roles describe where the existing tokens apply.

### Primary

- **Mauve:** filled actions, text actions, wallet context in forms, spending-bar fill, and group/category emphasis. Navigation selection uses mauve at 18% opacity.

### Secondary

- **Blue:** the secondary scheme color; inherited Material selected segments and choice chips resolve to blue. It also appears in wallet choices and the icon's upper fold.
- **Green:** incoming cash entries, income, repayments received, and amounts owed to the user. Repayment-ledger status icons also use green; read them as repayment status rather than an additional cash entry.
- **Red:** outgoing cash entries, spending, errors, and destructive actions.

### Tertiary

- **Peach:** amounts the user owes, due/archived explanatory emphasis where used, wallet selection choices, and the icon's clasp.
- **Yellow:** an optional wallet identity accent in the existing accent picker; it has no income or expense meaning.

### Neutral

- **Base:** scaffold and app-bar reading canvas.
- **Mantle:** bottom navigation, rail, filled fields, and dark foreground on accent buttons.
- **Surface:** one-pixel dividers, enabled field borders, spending tracks, and snackbar backgrounds.
- **Overlay:** outlines on native secondary controls.
- **Text:** primary labels and financial figures.
- **Muted:** supporting explanations, metadata, and non-semantic icons.

**The Cash Direction Rule.** For cash entries, green means cash entering the wallet and red means cash leaving it. Keep the signed amount and the movement description visible together; loan advances and repayments use their actual wallet direction.

## Typography

**Display and Body Font:** Flutter's platform typography: Roboto on Android and the Apple system family on iOS. No bundled font is declared. The frontmatter records the inherited Material 3 English-like type geometry in logical pixels; it does not impose a cross-platform font-family override.

**Character:** A functional native sans hierarchy. The wallet balance is the strongest figure, top-level page headings identify the workspace, and section titles keep financial summaries scanable. Text remains sentence case.

### Hierarchy

- **Display:** inherited `displaySmall`, used for loan outstanding amounts.
- **Balance:** `displaySmall` with the implemented semibold override, used for the overview wallet balance.
- **Headline:** `headlineLarge`, used for top-level pages and signed entry-detail amounts.
- **Title:** `titleLarge`, used for sections, statistics, month headings, and native app-bar titles.
- **Entry title:** `titleMedium`, used for transaction names and cash-entry amounts.
- **Body:** `bodyMedium`, used for explanations and ordinary supporting content.
- **Detail:** `bodySmall`, used for transaction metadata and running balances.
- **Label:** `labelLarge`, inherited by action controls.

**The Exact Amount Rule.** Keep currency, sign, and amount together. Format the wallet currency to two decimal places. A cash entry has an explicit plus or minus; a balance uses its actual sign. Avoid abbreviation or truncation of financial values.

The native text scaler remains active. Ledger amounts use a scale-down fit only when needed to preserve the whole number. Supporting labels wrap. The ledger moves its amount below the main row when available width is below 360 logical pixels or the text scaler exceeds 1.3. Running-balance text is kept in one fitted unit, including the sign.

## Layout

All dimensions in source are Flutter logical pixels. The portable frontmatter uses `px` as their equivalent, not physical screenshot pixels.

The shared PageBody is a vertically scrolling, top-aligned region centered within a maximum width of 820. Its insets are 20 horizontally, 16 above, and 110 below to provide space around the floating action. SectionTitle adds 28 above and 12 below. Form fields have 20 below each field; wallet context has 24 below it. The smaller repeated gaps separate label/value pairs and closely related controls.

The shell has four destinations in a fixed order: Overview, Transactions, Groups, Lending. Below a width of 760 it uses the bottom navigation bar; at 760 and above it uses a labelled left rail. Content stays centered beside that rail. Indexed tabs retain their state, while wallet identity keys the workspace. The app bar exposes the active wallet switcher and a settings action.

Statistics use a wrapping grid with 20 horizontal spacing and 24 run spacing. They have three columns only above a content width of 520 and below a text scale of 1.4; otherwise they use two. This adaptation applies to both overview and detail summaries.

Full-page forms scroll using the shared body and Flutter's keyboard resizing. Save follows the fields. The scaffold preserves safe insets; navigation, dialogs, menus, and pickers retain native tap-target behavior. Filled controls have a minimum width of 48 and height of 50; outlined actions have a minimum width and height of 48.

## Elevation & Depth

Tonal layers carry the resting workspace. The app bar removes surface tint. Ledger rows and statistics have no enclosing cards or custom shadows. The extended floating action has elevation zero at rest, increasing to one for focus, hover, or press. Native Material menus, dialogs, pickers, and snackbars retain their framework elevation; the project defines no custom shadow vocabulary or motion duration.

**The Tonal Workspace Rule.** Use base for the reading canvas, mantle for navigation and filled fields, and surface for dividers and tracks. Keep the principal ledger layout open; use native popup elevation when an interaction requires it.

Route transitions come from MaterialPageRoute and the platform theme, including native Back and iOS swipe-back. Use inherited Material interaction feedback rather than adding decorative animation or claiming a project-specific easing curve.

## Shapes

Fields, filled buttons, outlined buttons, and ledger hit surfaces share the control radius. Native choice chips use the smaller choice radius; segmented selectors and navigation indicators retain Material's pill geometry. Spending tracks have the small bar radius. Dividers are thin, quiet rules.

The brand mark is original authored geometry: a dark rounded square, mauve wallet body, blue upper fold, dark clasp with a peach dot, and three ascending dark bars. The SVG and BrandPainter carry the same geometry. Preserve the mark as an identity asset; its individual coordinates are not a reusable layout scale.

## Components

### Buttons

Mauve filled controls commit an action, with a mantle foreground and the shared control shape. Save shows a native progress indicator while its mutation is pending and is disabled during that operation. Outlined controls use mauve text and inherited Material outlines for secondary actions such as additional lending or date-range selection. Text buttons serve light actions such as Transfer and related-record creation. Destructive confirmation buttons use red; delete actions can use red outlined or text treatments in context.

Hover, focus, press, disabled state, ripple, and text-scaling padding come from Material. They are not bespoke web effects. The main tab action is an extended plus-icon FAB: New transaction, New group, or New loan according to the current destination.

### Chips and segmented controls

Choice chips filter Open, Settled, or Archived lending records. Selected choices use the inherited blue secondary container with a dark foreground and checkmark; unselected choices are quiet outlined controls. Segmented selectors choose transaction direction, group archive status, category kind, or loan direction. They retain their native shared capsule, selected checkmark, focus feedback, and explicit text labels.

### Open sections and ledger rows

The shared SectionTitle and Stats patterns establish open summaries without a card wrapper. EntryTile puts a muted category, transfer, or handshake icon beside a title and metadata; its signed amount is green or red. Dividers separate full transaction and group lists; the compact recent-activity list omits per-row dividers. Metadata includes dates, relevant group, notes, and explicit loan movement labels. Tappable rows use the shared rounded InkWell hit surface.

Group ledgers add a neutral running-balance line. Loan ledgers pair advance/repayment descriptions with outstanding-after values and status icons; these are debt-history rows, not duplicate cash totals. Groups and people use native list rows with chevrons to open details.

### Inputs and fields

Text and dropdown fields are filled mantle surfaces with a surface outline, control corners, and 16 insets. Focus uses the native primary outline; error text and border use the error role. Persistent labels name the field and amount currency; hint text is supporting content. DateField uses the same decorator and opens the native date picker. Optional notes support multiple lines. Filters only display category/group IDs valid in the current wallet; invalid or removed references revert to the All state.

### Navigation

The bottom bar has a mantle background and the recorded height. The rail uses the same background and destination order. A mauve translucent indicator marks the selected destination. Outlined Material icons and text labels remain visible, including on the rail. Wallet switching stays in the app bar rather than becoming a fifth destination. Detail and form pages use native app bars and routes.

### Spending breakdown

Each category has a muted icon, a text label, an exact amount, and a slim mauve bar over a surface track. Bars compare a category's expense amount with the selected month's total spending. Labels and values carry the information; the graphic does not replace them.

### Empty, busy, error, and destructive states

EmptyState combines a muted native icon, a section-sized title, a centered explanation, and an optional filled action. A new wallet workspace offers the original mark and a first-wallet action without fabricated records. Saved content stays visible during controller changes; a thin native progress bar indicates work. Validation appears inline, recoverable domain failures use floating snackbars, and destructive confirmations explain which records change before execution.

## Do's and Don'ts

### Do:

- **Do** preserve the selected wallet context in the app bar and money-entry forms.
- **Do** use the shared page body, section title, statistics, and ledger-row patterns for new surfaces.
- **Do** show loan cash movements with explicit descriptions such as Lent, Borrowed, Repayment received, and Repayment paid.
- **Do** preserve the difference between cash balance, ordinary income/spending, and outstanding debt.
- **Do** retain native keyboard, date-picker, focus, Back, and iOS swipe-back behavior.
- **Do** allow labels and supporting text to wrap; move amounts below row text on narrow or enlarged-text layouts.
- **Do** explain destructive effects in a confirmation dialog and show inline validation or actionable snackbar errors.

### Don't:

- **Don't** replace the Catppuccin palette or original wallet/bar-chart identity with a new visual direction.
- **Don't** use color as the only indication of cash direction; retain signs and movement labels.
- **Don't** turn ordinary ledger content into a stack of dashboard cards.
- **Don't** abbreviate money, separate a negative sign onto another line, or ellipsize a cash amount.
- **Don't** treat loan principal, repayments, or transfers as ordinary income or spending.
- **Don't** introduce a custom display font, decorative motion, or web-style navigation into this native system.
