import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'forms.dart';
import 'shared.dart';
import 'theme.dart';

/// A result object distinguishes clearing a category from dismissing the route.
class CategoryChoice {
  final int? id;
  const CategoryChoice(this.id);
}

class CategoryPicker extends StatefulWidget {
  final AppController app;
  final String? kind;
  final int? selected;
  final bool filter;
  const CategoryPicker({
    super.key,
    required this.app,
    this.kind,
    this.selected,
    this.filter = false,
  });
  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  final search = TextEditingController();
  int? parent;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void choose(int? id) => Navigator.pop(context, CategoryChoice(id));
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) {
      final app = widget.app;
      final categories = app.categories
          .where(
            (c) =>
                (widget.kind == null || c.kind == widget.kind) &&
                (widget.filter || !c.archived || c.id == widget.selected) &&
                (widget.filter ||
                    app.data.category(c.parentId)?.archived != true),
          )
          .toList();
      final current = categories.where((c) => c.id == parent).firstOrNull;
      final query = search.text.trim().toLowerCase();
      final roots = categories.where((c) => c.parentId == null).toList();
      final matches = categories
          .where(
            (c) => app.data.categoryName(c.id).toLowerCase().contains(query),
          )
          .toList();
      final recent = <Category>[];
      for (final e in app.entries) {
        final c = categories.where((c) => c.id == e.categoryId).firstOrNull;
        if (c != null && !recent.any((r) => r.id == c.id)) recent.add(c);
        if (recent.length == 4) break;
      }
      Widget tile(Category c, {bool browse = false}) => CategoryOption(
        category: c,
        app: app,
        selected: widget.selected == c.id,
        onTap: () {
          if (browse && categories.any((s) => s.parentId == c.id)) {
            setState(() {
              parent = c.id;
              search.clear();
            });
          } else {
            choose(c.id);
          }
        },
        trailing: browse && categories.any((s) => s.parentId == c.id)
            ? LucideIcons.chevronRight300
            : null,
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(current?.name ?? 'Choose category'),
          leading: current == null
              ? null
              : IconButton(
                  tooltip: 'All categories',
                  icon: const Icon(LucideIcons.arrowLeft300),
                  onPressed: () => setState(() {
                    parent = null;
                    search.clear();
                  }),
                ),
          actions: [
            IconButton(
              tooltip: 'Close categories',
              icon: const Icon(LucideIcons.x300),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: PageBody(
            children: [
              TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search categories',
                  prefixIcon: Icon(LucideIcons.search300),
                ),
              ),
              const SizedBox(height: 18),
              if (query.isNotEmpty) ...[
                if (matches.isEmpty)
                  const EmptyState(
                    icon: LucideIcons.searchX300,
                    title: 'No categories found',
                    detail: 'Try another name or create a category.',
                  ),
                for (final c in matches)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: tile(c),
                  ),
              ] else if (current != null) ...[
                SelectionRow(
                  primaryLabel: true,
                  label: widget.filter
                      ? 'All ${current.name}'
                      : 'Use ${current.name}',
                  value: widget.filter
                      ? 'Includes subcategories'
                      : 'Without a subcategory',
                  icon: categoryIcon(current, app.data),
                  color: categoryColor(current, app.data),
                  onTap: () => choose(current.id),
                ),
                const SectionTitle('Subcategories'),
                for (final c in categories.where((c) => c.parentId == parent))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: tile(c),
                  ),
              ] else ...[
                SelectionRow(
                  primaryLabel: true,
                  label: widget.filter ? 'All categories' : 'Uncategorised',
                  value: '',
                  icon: LucideIcons.shapes300,
                  onTap: () => choose(null),
                ),
                if (recent.isNotEmpty && !widget.filter) ...[
                  const SectionTitle('Recent'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in recent.take(3))
                        ActionChip(
                          avatar: Icon(
                            categoryIcon(c, app.data),
                            size: 18,
                            color: categoryColor(c, app.data),
                          ),
                          label: Text(c.name),
                          onPressed: () => choose(c.id),
                        ),
                    ],
                  ),
                ],
                const SectionTitle('All categories'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final largeText =
                        MediaQuery.textScalerOf(context).scale(1) > 1.3;
                    if (largeText) {
                      return Column(
                        children: [
                          for (final c in roots)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: tile(c, browse: true),
                            ),
                        ],
                      );
                    }
                    final columns = constraints.maxWidth > 600 ? 4 : 3;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 10) / columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final c in roots)
                          SizedBox(
                            width: width,
                            child: Material(
                              color: AppTheme.mantle,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (categories.any(
                                    (s) => s.parentId == c.id,
                                  )) {
                                    setState(() => parent = c.id);
                                  } else {
                                    choose(c.id);
                                  }
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: softTint(
                                      categoryColor(c, app.data),
                                      strength: .12,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 18,
                                  ),
                                  child: Column(
                                    children: [
                                      IconBadge(
                                        icon: categoryIcon(c, app.data),
                                        color: categoryColor(c, app.data),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        c.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${categories.where((s) => s.parentId == c.id).length} options',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              if (!widget.filter)
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.plus300),
                  label: Text(
                    current == null ? 'New category' : 'New subcategory',
                  ),
                  onPressed: () async {
                    final id = await push<int>(
                      context,
                      CategoryForm(
                        app: app,
                        kind: current?.kind ?? widget.kind ?? 'expense',
                        parentId: current?.id,
                      ),
                    );
                    if (id != null && context.mounted) choose(id);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class CategoryOption extends StatelessWidget {
  final Category category;
  final AppController app;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailing;
  const CategoryOption({
    super.key,
    required this.category,
    required this.app,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => SelectionRow(
    primaryLabel: true,
    label: category.name,
    value:
        app.data.category(category.parentId)?.name ??
        (category.kind == 'income' ? 'Income' : 'Expense'),
    icon: categoryIcon(category, app.data),
    color: categoryColor(category, app.data),
    trailing: selected
        ? LucideIcons.circleCheck300
        : trailing ?? LucideIcons.chevronRight300,
    onTap: onTap,
  );
}

class GroupChoice {
  final int? id;
  const GroupChoice(this.id);
}

class GroupPicker extends StatelessWidget {
  final AppController app;
  final int? selected;
  const GroupPicker({super.key, required this.app, this.selected});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose group')),
    body: PageBody(
      children: [
        SelectionRow(
          primaryLabel: true,
          label: 'No group',
          value: 'Keep this transaction on its own',
          icon: LucideIcons.receiptText300,
          onTap: () => Navigator.pop(context, const GroupChoice(null)),
        ),
        const SectionTitle('Your groups'),
        for (final g in app.groups.where(
          (g) => !g.archived || g.id == selected,
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionRow(
              primaryLabel: true,
              label: g.name,
              value:
                  '${app.entries.where((e) => e.groupId == g.id).length} transactions',
              icon: iconFor(g.icon),
              trailing: selected == g.id
                  ? LucideIcons.circleCheck300
                  : LucideIcons.chevronRight300,
              onTap: () => Navigator.pop(context, GroupChoice(g.id)),
            ),
          ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            final id = await push<int>(context, GroupForm(app: app));
            if (id != null && context.mounted) {
              Navigator.pop(context, GroupChoice(id));
            }
          },
          icon: const Icon(LucideIcons.plus300),
          label: const Text('New group'),
        ),
      ],
    ),
  );
}
