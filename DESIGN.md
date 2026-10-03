---
name: Manavalan Finance
description: A light wallet workspace with violet actions, labeled navigation, and clear category hierarchy.
colors:
  base: "#faf9fc"
  mantle: "#ffffff"
  surface: "#eeecf1"
  overlay: "#c5c0cf"
  text: "#383044"
  muted: "#5e5269"
  accent: "#8054b5"
  green: "#16764d"
  red: "#be3d47"
  peach: "#a75d16"
  yellow: "#867016"
  violet: "#7854ad"
  lavender: "#d9c9f6"
  blush: "#f4c7e4"
  wash-pink: "#f9d8e9"
  wash-violet: "#e9ddfa"
  wash-light: "#fdfbff"
typography:
  amount:
    fontFamily: "Roboto"
    fontSize: "46px"
    fontWeight: 500
    letterSpacing: "-1.2px"
  balance:
    fontFamily: "Roboto"
    fontSize: "38px"
    fontWeight: 600
    letterSpacing: "-1.2px"
  headline:
    fontFamily: "Roboto"
    fontSize: "28px"
    fontWeight: 600
    letterSpacing: "-0.6px"
  title:
    fontFamily: "Roboto"
    fontSize: "20px"
    fontWeight: 600
    letterSpacing: "-0.4px"
  entry-title:
    fontFamily: "Roboto"
    fontSize: "15px"
    fontWeight: 600
  body:
    fontFamily: "Roboto"
    fontSize: "14px"
  button:
    fontFamily: "Roboto"
    fontSize: "16px"
    fontWeight: 600
rounded:
  row: "12px"
  badge: "14px"
  field: "18px"
  navigation-indicator: "16px"
  selection: "18px"
  category: "20px"
  list-surface: "22px"
  panel: "24px"
  balance: "26px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  field-gap: "10px"
  lg: "16px"
  panel: "18px"
  page: "24px"
  section: "24px"
  section-top: "28px"
components:
  button-primary:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.mantle}"
    typography: "{typography.button}"
    rounded: "{rounded.field}"
    height: "54px"
  button-outlined:
    textColor: "{colors.accent}"
    rounded: "{rounded.pill}"
    height: "48px"
  button-destructive:
    backgroundColor: "{colors.red}"
    textColor: "{colors.mantle}"
    rounded: "{rounded.field}"
    height: "54px"
  field:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    rounded: "{rounded.field}"
    padding: "18px"
  amount-field:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    typography: "{typography.amount}"
    padding: "12px 4px"
  surface-panel:
    backgroundColor: "{colors.mantle}"
    rounded: "{rounded.panel}"
    padding: "18px"
  choice-selected:
    backgroundColor: "{colors.lavender}"
    textColor: "{colors.muted}"
    rounded: "{rounded.pill}"
  navigation-mobile:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.muted}"
    height: "76px"
  flow-tab-selected:
    textColor: "{colors.accent}"
    height: "50px"
    padding: "14px 8px"
  icon-badge:
    rounded: "{rounded.badge}"
    size: "42px"
  balance-panel:
    textColor: "{colors.text}"
    typography: "{typography.balance}"
    rounded: "{rounded.balance}"
    padding: "24px"
  selection-row:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    rounded: "{rounded.selection}"
    padding: "18px 16px"
---

# Design System: Manavalan Finance

## Overview

**Creative North Star: "The Wallet Workspace"**

The Wallet Workspace is a light interface for local personal finance on Android and iOS. A neutral canvas and white rounded surfaces support soft pink-to-violet balance panels, violet primary actions, and prominent amounts. Short labels and recognizable category icons keep everyday entry quiet and direct.

Flutter Material 3 supplies native interaction, focus, validation, and navigation behavior. The original wallet-and-bars identity uses matching violet and pink. This record follows the implemented lib/ui system and the user’s 3 October 2026 reference, which supersedes the earlier blue direction.

**Key Characteristics:**

- Light neutral canvas, white surfaces, and soft gradient financial focal points.
- Large exact amounts and compact supporting metadata.
- Full-width labeled white navigation, lavender selection, and contextual page actions.
- Explicit category hierarchy, recognizable icons, and adaptive selection layouts.

## Colors

### Primary

**Accent violet** fills primary actions and marks focus, selected navigation, tabs, and category recognition; the legacy `blue` name in AppTheme aliases this same violet. **Blush**, **lavender**, and white form the recurring BalancePanel gradient, with plum text. The lighter **wash-pink**, **wash-violet**, and **wash-light** gradient belongs to empty-state icons. **Lavender** also highlights selected chips and library icons.

### Secondary

**Green** and **red** express cash direction. **Peach** supports amounts owed and archived notices. Yellow and violet remain selectable wallet/category accents. Category families share a color; child icons distinguish specific categories within that family.

### Neutral

**Base** is the reading canvas; **mantle** is white panel, field, and mobile-navigation fill. **Surface** supplies quiet borders and tracks; **overlay** supplies stronger outlines. **Text** is plum ink and **muted** is supporting text and inactive navigation icons. Keep supporting text at its full theme color so it remains readable on white and gradient surfaces.

**The Cash Direction Rule.** Cash entering the wallet uses green; cash leaving uses red. Keep the signed amount and explicit loan movement description together, so color never carries the meaning alone.

## Typography

Roboto is explicitly set on both platforms and bundled locally in regular (400), medium (500), and bold (700) assets; browser QA uses the same assets. Code requests medium amount entry and semibold balance values and titles. The shared ramp runs from 46px centered amount entry and 38px balance values through 28px headlines, 20px section titles, 15px row titles, and 14px body text. App bars use 19px semibold; subtitles use 13px; navigation labels use 11px. Labels use sentence case. Unspecified styles inherit Flutter Material 3.

BalancePanel scales its amount down to preserve the complete value. Use its dark value treatment consistently on overview, transaction, group, and loan detail surfaces.

**The Exact Amount Rule.** Keep currency, sign, and amount together without abbreviation or ellipsis. Use the shared money formatter and move row amounts below the text when space or text scaling requires it.

## Layout

Dimensions are Flutter logical pixels. PageBody centers a scrollable column inside a maximum width of 820, with padding 24 left/right, 12 top, and 96 bottom. Section titles have 28 top and 12 bottom spacing. Forms separate fields by 10 and keep Save below the scrollable content in a safe area, with maximum width 780.

At viewport width 760 and above, four destinations become a labelled white navigation rail. Below that, a full-width white NavigationBar is 76 high before platform bottom insets, with all four labels always visible and a quiet top border. Page-level actions live in the header, balance panel, or empty-state card. Forms use a white canvas, centered title with wallet subtitle, and sticky Save padding of 20 left/right, 12 top, and 16 bottom.

Stats uses one column below content width 340 or at text scale 1.4 and above; three above width 520 when scale is below 1.4; otherwise two. Column gaps are 20 and row gaps 24. Ledger amounts stack below content width 300 or above text scale 1.3.

Category selection uses three columns, four above content width 600, and readable rows above text scale 1.3. Grid gaps are 10. The icon library uses four columns, six above content width 600, or two above text scale 1.3, with gaps of 8. These are content-width decisions, not device categories.

## Elevation & Depth

**The Flat Surface Rule.** Use contrast between the neutral canvas and white panels to organize content. Keep permanent surfaces and page actions free of decorative shadows.

Balance gradients add tonal depth without shadows. There are no custom shadow or motion tokens. Native dialogs, menus, routes, expansion, and interaction feedback retain framework behavior. Contextual actions use Material state feedback rather than custom shadow effects.

## Shapes

Panels have generous rounded corners; grouped lists and lending balance cards are slightly tighter. Selection rows and filled buttons use radius 18; category cards use 20; lending choices use 22. Balance panels use radius 26 and padding 24. Outlined buttons and chips retain pill shapes. IconBadge places a 21px native icon in a 42-square surface tinted with 8% of its semantic color. Mobile navigation spans the screen, with a rounded-16 lavender selected indicator.

## Components

- **Buttons:** violet filled primary actions with white text and a minimum 48-by-54 target. Outlined secondary actions are at least 48 high, with violet text and a surface-colored border. Destructive confirmations use red. Flutter owns disabled and interaction states.
- **Fields:** white fill, surface border, and a 1.5px violet focus border. Amount entry removes the border, centers its value on the white form canvas, and retains an always-visible currency label. Notes expand when requested or already populated.
- **Selection controls:** FlowTabs uses inline labels and a 2px violet underline for the selected option, against a 1px neutral underline elsewhere; each target is at least 50 high. Expense/Income and Lent/Borrowed remain explicit labels. Chips use lavender selection. SelectionRow normally puts a plain icon, muted label, and value in one line; its primaryLabel variant uses an icon badge and stacked name/context for category and group browsing. Text scaling above 1.3 also stacks the standard row.
- **Balance and summaries:** BalancePanel applies the same three-stop diagonal wash and dark value across overview and detail screens. White statistic panels and restrained spending bars support it. The overview places Transaction and Transfer actions inside the balance panel.
- **Panels and ledger rows:** SurfacePanel groups related content. EntryTile combines a category icon, semibold title, muted metadata, and signed amount. Rows use 14 padding and radius-12 touch feedback. Transaction browsing groups rows in white panels beneath date labels; group ledgers retain running balances.
- **Navigation:** every mobile destination shows an icon and label. The selected icon and label are violet with a lavender indicator at 45% opacity; other destinations use muted plum. Wide layouts use a white labelled rail with violet selected emphasis. Creation is contextual to each page.
- **Groups and lending:** Groups uses a compact Active/Archived popup beside the ledger count. Lending selects direction with “Owed to you” and “You owe” cards that display outstanding totals; selection adds a lavender or rose tint and a matching outline. The cards stack above text scale 1.3. A compact status menu and optional search support the current direction. Empty states use a white action card with a gradient icon, short explanation, and contextual create button.
- **Category picker:** a dedicated route offers up to three recent wallet-specific shortcuts, parent icon cards, and search across parent/child names. Browsing a parent with children reveals its subcategories and an explicit “Use [parent]” action; a parent without children selects directly. Search results show parent context. New category/subcategory creation returns the created selection. Expense/income choices stay isolated. Archived categories are excluded from new choices, while an existing selection may remain visible; filter mode includes historical categories and parent filters include children. Closing or Back preserves selection; Uncategorised explicitly clears it.
- **Group and icon pickers:** groups use a dedicated route with selection marks, an explicit No group choice, and inline creation. The searchable icon library returns a named icon, highlights the selected icon in lavender, and preserves the existing choice on dismissal.
- **Category management:** expandable parent panels expose child icons, subcategory counts, contextual edit/reorder/archive/delete actions, and inline subcategory creation. Search expands matching parent context; expense/income and archive controls keep scope explicit. Seeded children may receive semantic presentation icons without changing stored custom choices.
- **Settings and details:** related rows share a white rounded container. Settings keeps the wallet identity visible; transaction details present the balance panel followed by grouped wallet, date, category, relationship, and note information.

## Do's and Don'ts

### Do

- Do retain the selected wallet in the app shell and money-entry forms.
- Do reuse BalancePanel, SurfacePanel, SelectionRow, IconBadge, Stats, EntryTile, and PageBody for related screens.
- Do use labeled navigation, underline FlowTabs, and the meaningful lending balance choices in their established contexts.
- Do expose parent context for child categories and preserve the selection when a picker is dismissed.
- Do use concise labels and reveal optional notes through the existing expansion control.
- Do preserve native keyboard, date-picker, Back, focus, and validation behavior.
- Do explain destructive effects in the confirmation dialog.

### Don't

- Don't restore black split controls, black primary actions, floating navigation pills, or the superseded blue identity.
- Don't use color alone to identify money direction or loan status.
- Don't replace the hierarchical category route with a long flat dropdown.
- Don't add decorative charts, marketing copy, or extra cards without information that needs them.
- Don't abbreviate or ellipsize financial amounts.
- Don't turn loan advances, repayments, or transfers into ordinary income or spending.
