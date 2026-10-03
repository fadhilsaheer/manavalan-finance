# Category interaction research — 3 October 2026

Reviewed official product help rather than inferring behavior from promotional images:

- [Wallet: Categories and subcategories](https://support.budgetbakers.com/hc/en-us/articles/7077082048146-All-about-Categories-and-Subcategories): main-category selection reveals subcategories; used categories become shortcuts; icons and colors support recognition.
- [Spendee: Custom categories](https://help.spendee.com/article/227-how-to-create-a-custom-category): separate expense/income categories with editable names, icons, and colors.
- [Pocket Clear: Manage categories](https://pocketclear.app/help/manage-categories.html): expandable subcategory management, icon search, and category/subcategory labels keep hierarchy explicit.

## Applied decisions

- Replace the long flat transaction dropdown with a dedicated, dismissible category route. Three-column parent icon grid on phones, four on wide layouts; accessible rows at large text scales.
- Recent wallet-specific categories are shortcuts. Search matches parent and child names. A parent opens subcategories; an explicit parent action records without a subcategory. Search results show parent context.
- Dismissing preserves the selection; Uncategorised explicitly clears it. Expense/income modes stay isolated. Archived categories are excluded from new entries; filters can find historical categories.
- Create categories and subcategories inside selection and return the created selection. Groups also have a dedicated selector with inline creation.
- Management shows expandable parent cards, distinct child icons, contextual edit/reorder/archive/delete actions, and an archive filter.
- Icon colors are derived from category families; custom icon choices remain persisted. Existing seeded children that share their parent's icon gain semantic child symbols in presentation without database changes.
- Keep exact money, local storage, existing transactions and user-edited categories intact.
