---
name: Manavalan Finance
description: A clear, light wallet workspace with prominent amounts and compact controls.
colors:
  base: "#f6f7f9"
  mantle: "#ffffff"
  surface: "#e9ecf1"
  overlay: "#b9c1ce"
  text: "#191c22"
  muted: "#68717e"
  accent: "#2866d8"
  green: "#16764d"
  red: "#be3d47"
  peach: "#a75d16"
  yellow: "#867016"
  violet: "#7854ad"
typography:
  amount:
    fontFamily: "Roboto"
    fontSize: "40px"
    fontWeight: 600
    letterSpacing: "-1px"
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
  list-surface: "22px"
  panel: "24px"
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
    backgroundColor: "{colors.accent}"
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
    backgroundColor: "{colors.text}"
    textColor: "{colors.overlay}"
    height: "66px"
  icon-badge:
    rounded: "{rounded.badge}"
    size: "42px"
---

# Design System: Manavalan Finance

## Overview

**Creative North Star: "The Wallet Workspace"**

The Wallet Workspace is a clean, light interface for local personal finance on Android and iOS. The user’s supplied references establish a gray canvas, white rounded surfaces, a saturated blue balance area, compact dark navigation, and prominent amounts. Short labels and familiar controls keep the interface quiet.

Flutter Material 3 supplies native interaction, focus, validation, and navigation behavior. The original wallet-and-bars identity remains, recolored in blue and white. This record describes the implemented light redesign in lib/ui; it supersedes the earlier dark direction.

**Key Characteristics:**

- Light gray canvas with flat white surfaces and a blue financial focal point.
- Large amounts, compact metadata, and restrained explanatory copy.
- Dark mobile navigation pill with a separate blue add action.
- Adaptive layouts preserve wallet context and readable financial values.

## Colors

### Primary

**Accent blue** anchors the balance area, primary actions, focused inputs, and add action. `blue` in AppTheme aliases the same value; it is not a second accent.

### Secondary

**Green** and **red** express actual cash direction. **Peach** supports amounts owed and archived notices. Yellow and violet remain selectable wallet/category accents, not additional surface themes.

### Neutral

**Base** is the light gray reading canvas; **mantle** is white panel and field fill. **Surface** supplies quiet borders and tracks; **overlay** supplies stronger outlines and inactive mobile navigation icons. **Text** is both dark ink and the compact navigation/selected-control fill. **Muted** is supporting text.

**The Cash Direction Rule.** Cash entering the wallet uses green; cash leaving uses red. Keep the signed amount and explicit loan movement description together, so color never carries the meaning alone.

## Typography

Roboto is explicitly set for the app on both platforms. Semibold titles and amounts sit above regular body text; there is no separate editorial display face. The frontmatter records shared overrides. Other sizes retain Flutter Material 3 defaults, including displaySmall on group and loan totals and bodySmall for ledger metadata.

The overview balance is a local focal treatment (42px, weight 600, tracking −1.2px, white). Money-entry fields reuse the centered amount role. App bars use 19px semibold; list subtitles use 13px. Keep these subordinate to the financial value, with sentence-case labels.

**The Exact Amount Rule.** Keep currency, sign, and amount together without abbreviation or ellipsis. Use the shared money formatter and move row amounts below the text when space or text scaling requires it.

## Layout

All dimensions are Flutter logical pixels. PageBody centers a scrollable column inside a maximum width of 820, with padding 20 left/right, 16 top, and 32 bottom. Section titles have 28 top and 12 bottom spacing. Forms separate fields by 14 and keep Save below the scrollable content in a safe area, with a maximum width of 780.

At viewport width 760 and above, four destinations become a labelled navigation rail; below that, a centered mobile navigation pill has maximum width 330, alongside a separate 62-square add action and a 12 gap. The bottom safe-area minimum inset is 20 left/right, 8 top, 12 bottom.

Stats uses one column when available content width is below 340 or text scale is at least 1.4; three when width is above 520 and scale below 1.4; otherwise two. Column gaps are 20 and row gaps 24. Ledger amounts stack when their inner content width is below 300 or text scale exceeds 1.3; the overview summary follows the same threshold. These are content-width decisions, not device categories.

## Elevation & Depth

**The Flat Surface Rule.** Use contrast between the gray canvas and white panels to organize content. Keep permanent surfaces and the add action free of decorative shadows.


There are no custom shadow or motion tokens. Native dialogs, menus, routes, and interaction feedback retain framework behavior. The circular add action has zero elevation in rest, focus, hover, and pressed states.

## Shapes

Panels have generous rounded corners; grouped list surfaces are slightly tighter. Inputs are softly rounded, while buttons, filter chips, and direction selectors use pill forms. IconBadge places a 21px native icon in a 42-square tinted surface using 8% of its semantic color. The mobile navigation clips at radius 40 and uses a white circular selection indicator. The overview balance uses its own larger radius of 28 and padding of 24.

## Components

- **Buttons:** blue filled primary actions with white text and a minimum 48-by-54 target; outlined secondary actions are at least 48 high with a surface-colored border. Destructive confirmations use red. Flutter owns disabled and interaction states.
- **Fields:** white fill, surface border, and a 1.5px accent focus border. Amount entry removes the border, centers the large value on the page canvas, and retains an always-visible currency label. Notes expand only when requested or already populated.
- **Selection controls:** inactive chips are white with muted labels; selected lending status chips and direction segments use dark fill and white labels. Retain explicit labels for Expense/Income and Lent/Borrowed.
- **Panels and rows:** SurfacePanel groups related statistics/content. EntryTile combines a tinted IconBadge, semibold title, one-line muted metadata, and signed amount. Rows use 14 padding and radius-12 touch feedback; running balances remain visible beneath ledger entries. Group and loan lists use white rounded list surfaces.
- **Navigation:** mobile destinations are icon-only visually, with labels retained for semantics and tooltips. The selected icon is dark on a white circle. A separate blue plus creates a transaction, group, or loan according to the active destination. Wide layouts use the labelled rail.
- **Balance and summaries:** the blue balance area shows the current wallet amount and Transfer. White statistic panels and restrained spending bars support it. Group and loan detail totals remain plain prominent amounts above their shared statistics and ledgers.
- **Settings:** simple native list rows, short labels, and selective supporting text; the original wallet mark supplies the identity.

## Do's and Don'ts

### Do

- Do retain the selected wallet in the app shell and money-entry forms.
- Do reuse SurfacePanel, IconBadge, Stats, EntryTile, and PageBody for related screens.
- Do keep selected lending chips white on the dark selected background.
- Do use concise labels and reveal optional notes through the existing expansion control.
- Do preserve native keyboard, date-picker, Back, focus, and validation behavior.
- Do explain destructive effects in the confirmation dialog.

### Don't

- Don't restore the superseded dark palette or mauve actions.
- Don't use color alone to identify money direction or loan status.
- Don't add decorative charts, marketing copy, or extra cards without information that needs them.
- Don't abbreviate or ellipsize financial amounts.
- Don't turn loan advances, repayments, or transfers into ordinary income or spending.
