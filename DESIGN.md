# Manavalan Finance design

The user selected Catppuccin Mocha. Native Material navigation and platform route transitions carry an app for operating personal ledgers. The wallet name stays visible above every top-level view. Compact screens use a four-destination navigation bar; wide screens use a navigation rail.

## Tokens

Base #1e1e2e; mantle #181825; surface #313244; text #cdd6f4; muted text #a6adc8. Mauve #cba6f7 drives actions, green #a6e3a1 denotes incoming cash, red #f38ba8 outgoing cash. Amounts include signs and explicit descriptions. Blue and peach are secondary category/wallet accents.

## Structure

Use open sections and divided transaction rows rather than stacks of dashboard cards. Finance amounts are prominent but labelled by meaning. Expense breakdowns are horizontal labelled bars with amounts. Settings use native list rows. Full-page forms keep their save action above keyboard-safe insets. Icons come from the consistent Material outlined family; the original wallet/bar-chart launcher icon is authored geometry.

## States and accessibility

Empty wallets invite the first entry without fabricated data. Saved data stays on screen while changes commit. Invalid input is inline; domain errors explain recovery in a snackbar. Destructive actions preview effects. Touch controls meet 48 dp, text follows system scaling, layouts wrap large values, and all navigation preserves system Back and iOS swipe-back.
