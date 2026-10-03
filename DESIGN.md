---
name: Manavalan Finance
description: A neutral wallet workspace with glass navigation, semantic color, and localized pink-violet light.
colors:
  base: "#f6f6f6"
  mantle: "#ffffff"
  surface: "#eeeeee"
  overlay: "#cecece"
  text: "#171717"
  muted: "#686868"
  accent: "#171717"
  green: "#16764d"
  red: "#be3d47"
  peach: "#a75d16"
  category-food: "#a86438"
  category-transport: "#427b9b"
  category-home: "#4f7c64"
  category-shopping: "#a3517c"
  category-entertainment: "#805ca7"
  category-education: "#927222"
  category-travel: "#367c80"
  category-personal: "#a05576"
  category-other: "#7b64a0"
  blush: "#f69dcc"
  lavender: "#b392ef"
typography:
  amount:
    fontFamily: "Roboto"
    fontSize: "46px"
    fontWeight: 500
    letterSpacing: "-1.2px"
  balance:
    fontFamily: "Roboto"
    fontSize: "42px"
    fontWeight: 500
    letterSpacing: "-1.3px"
  headline:
    fontFamily: "Roboto"
    fontSize: "24px"
    fontWeight: 400
    letterSpacing: "-0.6px"
  title:
    fontFamily: "Roboto"
    fontSize: "20px"
    fontWeight: 400
    letterSpacing: "-0.4px"
  row:
    fontFamily: "Roboto"
    fontSize: "15px"
    fontWeight: 400
  body:
    fontFamily: "Roboto"
    fontSize: "14px"
  label:
    fontFamily: "Roboto"
    fontSize: "12px"
  button:
    fontFamily: "Roboto"
    fontSize: "16px"
    fontWeight: 400
rounded:
  row: "12px"
  field: "18px"
  glow: "20px"
  panel: "24px"
  navigation: "38px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  panel: "18px"
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
  surface-panel:
    backgroundColor: "{colors.mantle}"
    rounded: "{rounded.panel}"
    padding: "18px"
  chip-selected:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.muted}"
    rounded: "{rounded.pill}"
  navigation:
    rounded: "{rounded.navigation}"
    height: "68px"
  navigation-selected:
    backgroundColor: "{colors.text}"
    textColor: "{colors.mantle}"
    rounded: "{rounded.pill}"
    size: "52px"
  balance-panel:
    backgroundColor: "{colors.mantle}"
    rounded: "{rounded.panel}"
    padding: "12px"
  selection-row:
    backgroundColor: "{colors.mantle}"
    textColor: "{colors.text}"
    rounded: "{rounded.field}"
    padding: "18px 16px"
---

# Design System: Manavalan Finance

## Overview

**Creative North Star: "The Wallet Workspace"**

The Wallet Workspace uses a light neutral canvas, white rounded surfaces, black text and controls, and thin outline icons. Pink and violet light concentrate in the upper balance inset; everyday lists and forms retain neutral surfaces, with green/red cash values and soft category-family gradients. Translucent navigation and short directional transitions add depth and continuity. The reference image supplied on 3 October 2026 supersedes the earlier violet-wide direction, including its prohibitions against black primary buttons and circular navigation selection.

This record is extracted from the Flutter implementation in lib/ui/theme.dart, reference_surfaces.dart, shared.dart, navigation.dart, app.dart, ledger_pages.dart, forms.dart, category_picker.dart, details.dart, and settings.dart. Native Material behavior supplies focus, touch feedback, and validation. Routes use platform transitions and respect Reduce Motion.

**Key Characteristics:**
- Neutral chrome with white cards and black interaction anchors.
- Localized pink-violet glow and immersive patterned onboarding.
- Regular headings, prominent exact amounts, and compact metadata.
- Consistent Lucide 300 outline icons and adaptive glass navigation.
- Semantic cash colors, soft category tints, and state-preserving motion.

## Colors

The palette is neutral first, with pink-violet atmosphere and restrained financial status colors.

### Primary
- **Ink** (`accent`, `text`): text, primary actions, selected navigation circles, neutral selected tab underlines, and focused borders.

### Secondary
- **Pink light** (`blush`) and **Violet light** (`lavender`): wallet identity and localized financial highlights. The balance painter uses radial pink and violet sources above the inset's top edge, fading to transparent over white; it is not an all-over linear gradient.
- Onboarding has a separate immersive painter: blue in the upper left, saturated pink on the right, violet on the left, and a fade to white below.

### Tertiary
- **Green** (`green`) and **Red** (`red`): incoming and outgoing cash values, including transaction lists and entry detail amounts. Transfers use muted gray. Income/expense tabs and quick actions repeat these semantic colors; signs and labels continue to carry direction. Red also marks errors and destructive actions. **Warm amber** (`peach`) remains a contextual financial status color.
- **Category families** (`category-*`): food uses warm brown, transport blue, home green, shopping rose, entertainment violet, education ochre, travel teal, personal care mauve, and other categories muted purple. Health uses red; income categories use green. Subcategories inherit their parent family.
- Shared soft tints run diagonally from a white/color blend to a near-white 2.5% blend: category tiles start at 12%, icon badges at 20%, quick actions at 15%, and selected flow tabs at 10%. Keep readable solid text and icon colors above these quiet backgrounds.

### Neutral
- **Canvas** (`base`): page background and circular icon grounds.
- **White** (`mantle`): cards and fields; translucent white forms the navigation glass.
- **Soft gray** (`surface`): borders and selected chips; **Outline gray** (`overlay`): native outlines.
- **Muted gray** (`muted`): secondary labels and metadata.

**The Localized Light Rule.** Keep balance color inside the upper inset, fading into white before the white action row with softly tinted action circles. Reserve immersive color and diamond geometry for onboarding.

## Typography

**Display Font:** Roboto. **Body Font:** Roboto. Local font assets provide regular (400), medium (500), and bold (700), declared in pubspec.yaml. Headings are regular rather than uniformly bold.

### Hierarchy
- **Amount:** the largest input role, with medium weight and tight tracking.
- **Balance:** a prominent medium-weight amount; scales down within its container when needed.
- **Headline / title:** regular page and section hierarchy.
- **Row / body / label:** compact labels and metadata; use muted color for secondary information.
- The onboarding composition uses three lines at 40px, regular weight, 1.25 line height, and -1.2px tracking, with an inline wallet motif. This is a surface-specific composition, not the default heading style.

**The Exact Amount Rule.** Keep currency, sign, and amount together without abbreviation or ellipsis. Use the shared money formatter and move row amounts below their labels when space or text scaling requires it.

## Layout

PageBody centers content within 820 logical pixels, with 18px side gutters, 12px top padding, and 96px bottom clearance. On mobile, the scaffold extends the body beneath navigation and disables the body’s bottom safe-area inset so scroll content remains visible through the glass. Repeated gaps use the frontmatter spacing scale. At 760px the shell switches from bottom navigation to a rail with visible labels and a separate Settings action.

The overview has a wallet/date header, a white balance-and-action shell, a compact horizontal wallet strip, and individual white transaction rows. Wallet cards are 160px wide with 12px gaps; the strip is 124px tall and expands to 182px for larger text. Forms, detail pages, category pickers, groups, lending, and settings reuse the neutral containers and row hierarchy. Narrow layouts and enlarged text stack statistics and transaction amounts rather than clipping them.

## Elevation & Depth

Permanent cards are flat. White surfaces separate from the neutral canvas without decorative shadows. Balance depth comes from radial light behind the amount. Onboarding adds overlapping rounded diamonds that shrink and fade downward. Navigation adds real backdrop blur (14px) inside rounded clipping, a diagonal translucent-white gradient (72% to 40%), and a 65% white border. High Contrast raises the gradient opacity to 96% to 90%. Material transient overlays retain native behavior.

**The Flat Surface Rule.** Separate permanent surfaces with neutral tone, whitespace, and rounded clipping. Do not add decorative shadows to cards, primary actions, or navigation.

## Shapes

Use rounded panels and fields with smaller row corners. IconBadge is a 42px circle containing a 20px outline icon in its supplied semantic or category color over a soft matching gradient. Quick actions use 48px circles and matching soft tints. The balance glow clips within a smaller rounded inset inside the panel. Broad black segmented blocks are excluded; the selected navigation circle is an intentional compact black shape.

## Components

### Buttons
Black primary buttons use white regular labels, a 54px minimum height, and field-radius corners. Outlined secondary buttons are pill-shaped with soft-gray borders and a 48px minimum height. Destructive confirmation buttons use red. Preserve native Material hover, focus, disabled, and press feedback.

### Chips
White or neutral-gray pills with soft borders and muted labels. Selection uses the neutral surface token. FlowTabs use a sliding 2px selected underline and softly tinted selected background. Income uses green, expense uses red, and other modes use ink. The selected label is medium-weight; inactive labels remain muted. Indicator and tint changes use 280ms motion with easeOutCubic; Reduce Motion removes the duration.

### Cards / Containers
SurfacePanel uses white, panel-radius corners, clipping, and 18px default padding. BalancePanel uses 12px padding around the glow; its neutral footer contains Expense, Income, Transfer, and Lend. Wallet cards use 16px padding. Transaction entries remain individual white rows rather than a large uninterrupted table.

### Inputs / Fields
White filled fields have field-radius corners, soft-gray borders, and 18px padding. Focus changes the border to ink at 1.5px. Amount fields use the amount role. SelectionRow combines a softly tinted circular icon, label/value hierarchy, and chevron; notes use the existing optional expansion control.

### Navigation
Mobile navigation is an inset translucent bar, 68px high with 38px rounded clipping and five destinations. FrostedNavigation uses the glass treatment in Elevation & Depth. The active destination has a 52px black circle that slides between destinations over 280ms with easeOutCubic; icon color animates to white. Labels are visually hidden on mobile but preserved as semantics and tooltips. The wider rail shows destination labels and a quiet gray selection indicator. Do not restore the previous lavender indicator.

AnimatedTabDeck keeps pages mounted so filters and scroll positions survive tab changes. Pages fade through over 280ms with short directional movement (5.5% of width for the arriving page, 3.5% for the departing page); rapid changes restart from the latest destination. Inactive pages are offstage after transition and excluded from interaction and semantics. Routes use Cupertino transitions on iOS/macOS and FadeUpwards on Android. Reduce Motion sets tab, navigation, flow-tab, and route transition durations to zero.

### Identity and iconography
Use Lucide's thin 300-weight outline set consistently; category symbols are recognizable pictograms, not text glyphs. The original wallet mark has a pink-to-violet body, black fold, white closure and ascending bars, on a light neutral ground. Onboarding embeds a wallet motif within the headline and keeps its start action at the bottom.

## Do's and Don'ts

### Do:
- **Do** use black primary buttons and the small black selected navigation circle.
- **Do** reuse BalancePanel, BalanceGlow, SurfacePanel, SelectionRow, IconBadge, EntryTile, and PageBody.
- **Do** retain thin Lucide 300 icons across navigation, categories, actions, and form rows.
- **Do** keep signed amounts and explanatory labels together so money direction never relies on color alone.
- **Do** preserve category parent context, native focus and validation, and larger-text reflow.
- **Do** preserve filters and scroll state across animated tabs and honor Reduce Motion.

### Don't:
- **Don't** restore purple-tinted page chrome, violet primary buttons, or broad black split tabs.
- **Don't** spread the balance glow across ordinary form, detail, or settings cards.
- **Don't** add fake banking actions, balances, or decorative charts to imitate the reference.
- **Don't** abbreviate or ellipsize financial amounts.
- **Don't** replace the category hierarchy with a long flat dropdown.
