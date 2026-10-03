---
name: Manavalan Finance
description: A light wallet workspace with soft violet-pink balances and clear category hierarchy.
colors:
  base: "#f7f6f8"
  mantle: "#ffffff"
  surface: "#eeecf1"
  overlay: "#c5c0cf"
  text: "#201d25"
  muted: "#706a78"
  accent: "#7850b8"
  green: "#16764d"
  red: "#be3d47"
  peach: "#a75d16"
  yellow: "#867016"
  violet: "#7854ad"
  lavender: "#d9c9f6"
  wash-pink: "#f6d6e9"
  wash-violet: "#e3d7f9"
  wash-light: "#faf8fc"
typography:
  amount:
    fontFamily: "Roboto"
    fontSize: "40px"
    fontWeight: 600
    letterSpacing: "-1px"
  balance:
    fontFamily: "Roboto"
    fontSize: "38px"
    fontWeight: 600
    letterSpacing: "-1.2px"
  headline:
    fontFamily: "Roboto"
    fontSize: "30px"
    fontWeight: 600
    letterSpacing: "-0.8px"
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
  selection: "20px"
  list-surface: "22px"
  panel: "24px"
  balance: "26px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  field-gap: "14px"
  lg: "16px"
  panel: "18px"
  page: "20px"
  section: "24px"
  section-top: "28px"
components:
  button-primary:
    backgroundColor: "{colors.text}"
    textColor: "{colors.mantle}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    height: "54px"
  button-outlined:
    textColor: "{colors.accent}"
    rounded: "{rounded.pill}"
    height: "48px"
  button-destructive:
    backgroundColor: "{colors.red}"
    textColor: "{colors.mantle}"
    rounded: "{rounded.pill}"
    height: "54px"
  field:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    rounded: "{rounded.field}"
    padding: "18px"
  amount-field:
    backgroundColor: "{colors.base}"
    textColor: "{colors.text}"
    typography: "{typography.amount}"
    padding: "26px 12px"
  surface-panel:
    backgroundColor: "{colors.mantle}"
    rounded: "{rounded.panel}"
    padding: "18px"
  choice-selected:
    backgroundColor: "{colors.text}"
    textColor: "{colors.mantle}"
    rounded: "{rounded.pill}"
  navigation-mobile:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.muted}"
    height: "66px"
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
    padding: "9px 16px"
---

# Design System: Manavalan Finance

## Overview

**Creative North Star: "The Wallet Workspace"**

The Wallet Workspace is a light interface for local personal finance on Android and iOS. A neutral canvas and white rounded surfaces support soft pink-to-violet balance panels, near-black primary actions, and prominent amounts. Short labels and recognizable category icons keep everyday entry quiet and direct.

Flutter Material 3 supplies native interaction, focus, validation, and navigation behavior. The original wallet-and-bars identity uses matching violet and pink. This record follows the implemented lib/ui system and the user’s 3 October 2026 reference, which supersedes the earlier blue direction.

**Key Characteristics:**

- Light neutral canvas, white surfaces, and soft gradient financial focal points.
- Large exact amounts and compact supporting metadata.
- White mobile navigation with a dark selected circle and separate dark add action.
- Explicit category hierarchy, recognizable icons, and adaptive selection layouts.

## Colors

### Primary

Near-black **text** fills primary buttons, the add action, and selected controls. **Accent violet** marks focus, secondary actions, and category recognition; the legacy `blue` name in AppTheme aliases this same violet. The recurring balance wash runs from **wash-pink** through **wash-violet** to **wash-light**, with dark text. **Lavender** highlights the selected icon in the library.

### Secondary

**Green** and **red** express cash direction. **Peach** supports amounts owed and archived notices. Yellow and violet remain selectable wallet/category accents. Category families share a color; child icons distinguish specific categories within that family.

### Neutral

**Base** is the reading canvas; **mantle** is white panel, field, and mobile-navigation fill. **Surface** supplies quiet borders and tracks; **overlay** supplies stronger outlines. **Text** is dark ink and **muted** is supporting text and inactive navigation icons.

**The Cash Direction Rule.** Cash entering the wallet uses green; cash leaving uses red. Keep the signed amount and explicit loan movement description together, so color never carries the meaning alone.

## Typography

Roboto is explicitly set on both platforms. Semibold amounts and titles sit above regular body text. The shared ramp runs from 40px centered amount entry and 38px balance values through 30px headlines, 20px section titles, 15px row titles, and 14px body text. App bars use 19px semibold; subtitles use 13px. Labels use sentence case. Unspecified styles inherit Flutter Material 3.

BalancePanel scales its amount down to preserve the complete value. Use its dark value treatment consistently on overview, transaction, group, and loan detail surfaces.

**The Exact Amount Rule.** Keep currency, sign, and amount together without abbreviation or ellipsis. Use the shared money formatter and move row amounts below the text when space or text scaling requires it.

## Layout

Dimensions are Flutter logical pixels. PageBody centers a scrollable column inside a maximum width of 820, with padding 20 left/right, 16 top, and 100 bottom. Section titles have 28 top and 12 bottom spacing. Forms separate fields by 14 and keep Save below the scrollable content in a safe area, with maximum width 780.

At viewport width 760 and above, four destinations become a labelled navigation rail. Below that, the centered mobile navigation pill has maximum width 330 and height 66, alongside a separate 62-square add action with a 12 gap. Bottom safe-area minimum insets are 20 left/right, 8 top, and 12 bottom.

Stats uses one column below content width 340 or at text scale 1.4 and above; three above width 520 when scale is below 1.4; otherwise two. Column gaps are 20 and row gaps 24. Ledger amounts stack below content width 300 or above text scale 1.3.

Category selection uses three columns, four above content width 600, and readable rows above text scale 1.3. Grid gaps are 10. The icon library uses four columns, six above content width 600, or two above text scale 1.3, with gaps of 8. These are content-width decisions, not device categories.

## Elevation & Depth

**The Flat Surface Rule.** Use contrast between the neutral canvas and white panels to organize content. Keep permanent surfaces and the add action free of decorative shadows.

Balance gradients add tonal depth without shadows. There are no custom shadow or motion tokens. Native dialogs, menus, routes, expansion, and interaction feedback retain framework behavior. The add action has zero elevation in rest, focus, hover, and pressed states.

## Shapes

Panels have generous rounded corners; grouped lists are slightly tighter. Selection rows and category cards share radius 20. Balance panels use radius 26 and padding 24. Inputs are softly rounded; buttons, chips, and direction selectors use pills. IconBadge places a 21px native icon in a 42-square surface tinted with 8% of its semantic color. Mobile navigation clips at radius 40 with a dark circular selection indicator.

## Components

- **Buttons:** near-black filled primary actions with white text and a minimum 48-by-54 target. Outlined secondary actions are at least 48 high, with violet text and a surface-colored border. Destructive confirmations use red. Flutter owns disabled and interaction states.
- **Fields:** white fill, surface border, and a 1.5px violet focus border. Amount entry removes the border, centers its value on the page canvas, and retains an always-visible currency label. Notes expand when requested or already populated.
- **Selection controls:** inactive chips are white with muted labels; selected lending status chips and direction segments use dark fill and white labels. Expense/Income and Lent/Borrowed remain explicit labels. SelectionRow combines an icon badge, label, optional supporting value, and contextual trailing icon.
- **Balance and summaries:** BalancePanel applies the same three-stop diagonal wash and dark value across overview and detail screens. White statistic panels and restrained spending bars support it. The overview Transfer action uses a translucent white pill.
- **Panels and ledger rows:** SurfacePanel groups related content. EntryTile combines a category icon, semibold title, muted metadata, and signed amount. Rows use 14 padding and radius-12 touch feedback. Transaction browsing groups rows in white panels beneath date labels; group ledgers retain running balances.
- **Navigation:** mobile destinations are visually icon-only, retaining semantic labels and tooltips. The selected white icon sits on a dark circle inside a white pill. A separate dark plus creates a transaction, group, or loan according to the active destination. Wide layouts use a white labelled rail with violet selected emphasis.
- **Category picker:** a dedicated route offers up to three recent wallet-specific shortcuts, parent icon cards, and search across parent/child names. Browsing a parent with children reveals its subcategories and an explicit “Use [parent]” action; a parent without children selects directly. Search results show parent context. New category/subcategory creation returns the created selection. Expense/income choices stay isolated. Archived categories are excluded from new choices, while an existing selection may remain visible; filter mode includes historical categories and parent filters include children. Closing or Back preserves selection; Uncategorised explicitly clears it.
- **Group and icon pickers:** groups use a dedicated route with selection marks, an explicit No group choice, and inline creation. The searchable icon library returns a named icon, highlights the selected icon in lavender, and preserves the existing choice on dismissal.
- **Category management:** expandable parent panels expose child icons, subcategory counts, contextual edit/reorder/archive/delete actions, and inline subcategory creation. Search expands matching parent context; expense/income and archive controls keep scope explicit. Seeded children may receive semantic presentation icons without changing stored custom choices.
- **Settings and details:** related rows share a white rounded container. Settings keeps the wallet identity visible; transaction details present the balance panel followed by grouped wallet, date, category, relationship, and note information.

## Do's and Don'ts

### Do

- Do retain the selected wallet in the app shell and money-entry forms.
- Do reuse BalancePanel, SurfacePanel, SelectionRow, IconBadge, Stats, EntryTile, and PageBody for related screens.
- Do keep selected lending chips white on the dark selected background.
- Do expose parent context for child categories and preserve the selection when a picker is dismissed.
- Do use concise labels and reveal optional notes through the existing expansion control.
- Do preserve native keyboard, date-picker, Back, focus, and validation behavior.
- Do explain destructive effects in the confirmation dialog.

### Don't

- Don't restore the superseded blue balance cards, blue primary actions, or dark mobile navigation.
- Don't use color alone to identify money direction or loan status.
- Don't replace the hierarchical category route with a long flat dropdown.
- Don't add decorative charts, marketing copy, or extra cards without information that needs them.
- Don't abbreviate or ellipsize financial amounts.
- Don't turn loan advances, repayments, or transfers into ordinary income or spending.
