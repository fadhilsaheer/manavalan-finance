import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import '../data/file_service.dart';
import 'theme.dart';

void message(BuildContext context, String text) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> perform(
  BuildContext context,
  AppController app,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await app.change(action);
    if (context.mounted && success != null) message(context, success);
    return true;
  } catch (e) {
    if (context.mounted) {
      message(
        context,
        e is LedgerError
            ? e.message
            : 'Could not save. Your data is unchanged. Please try again.',
      );
    }
    return false;
  }
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  String action = 'Delete',
  bool destructive = true,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: AppTheme.red)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: children,
      ),
    ),
  );
}

class SelectionRow extends StatelessWidget {
  final String label, value;
  final IconData icon, trailing;
  final Color color;
  final VoidCallback? onTap;
  const SelectionRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.color = AppTheme.accent,
    this.trailing = Icons.chevron_right_rounded,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.mantle,
    borderRadius: BorderRadius.circular(20),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      leading: IconBadge(icon: icon, color: color),
      title: Text(label),
      subtitle: value.isEmpty ? null : Text(value),
      trailing: onTap == null
          ? null
          : Icon(trailing, size: 20, color: AppTheme.muted),
      onTap: onTap,
    ),
  );
}

class BalancePanel extends StatelessWidget {
  final String label, value;
  final Widget? footer;
  const BalancePanel({
    super.key,
    required this.label,
    required this.value,
    this.footer,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppTheme.wash,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.2,
            ),
          ),
        ),
        if (footer != null) ...[const SizedBox(height: 18), footer!],
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  final String? action;
  final VoidCallback? onAction;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 52, color: AppTheme.muted),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          style: const TextStyle(color: AppTheme.muted),
          textAlign: TextAlign.center,
        ),
        if (onAction != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: FilledButton(onPressed: onAction, child: Text(action!)),
          ),
      ],
    ),
  );
}

class SurfacePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.mantle,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppTheme.accent,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, size: 21, color: color),
  );
}

class Stat extends StatelessWidget {
  final String label, value;
  final Color? color;
  const Stat(this.label, this.value, {super.key, this.color});
  @override
  Widget build(BuildContext context) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.muted)),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          softWrap: true,
        ),
      ],
    ),
  );
}

class Stats extends StatelessWidget {
  final List<Widget> children;
  const Stats({super.key, required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(1) >= 1.4
          ? 1
          : constraints.maxWidth > 520 &&
                MediaQuery.textScalerOf(context).scale(1) < 1.4
          ? 3
          : 2;
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 24,
        children: children
            .map((w) => SizedBox(width: width, child: w))
            .toList(),
      );
    },
  );
}

class EntryTile extends StatelessWidget {
  final AppController app;
  final Entry entry;
  final VoidCallback? onTap;
  final int? running;
  const EntryTile({
    super.key,
    required this.app,
    required this.entry,
    this.onTap,
    this.running,
  });
  @override
  Widget build(BuildContext context) {
    final s = app.data;
    final wallet = s.wallets.firstWhere((w) => w.id == entry.walletId);
    final category = s.category(entry.categoryId);
    final loan = s.loan(entry.loanId);
    final title = loan != null
        ? loan.person
        : entry.kind.ordinary
        ? (category?.name ?? 'Uncategorised')
        : entry.kind.label;
    final movement = loan == null
        ? null
        : entry.kind == EntryKind.loanAdvance
        ? (loan.lent ? 'Lent' : 'Borrowed')
        : (loan.lent ? 'Repayment received' : 'Repayment paid');
    final subtitle = [
      ?movement,
      prettyDay(entry.date),
      if (entry.groupId != null) s.group(entry.groupId)?.name ?? '',
    ].join(' · ');
    final amount = Text(
      '${entry.sign > 0 ? '+' : '−'}${money(entry.amount, wallet.currency)}',
      textAlign: TextAlign.end,
      softWrap: false,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: entry.sign > 0 ? AppTheme.green : AppTheme.red),
    );
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconBadge(
                          icon: loan != null
                              ? Icons.handshake_outlined
                              : entry.kind.ordinary
                              ? categoryIcon(category, s)
                              : Icons.swap_horiz_rounded,
                          color: entry.kind.ordinary
                              ? categoryColor(category, s)
                              : AppTheme.accent,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      if (!stacked) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: amount,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (stacked)
                    Padding(
                      padding: const EdgeInsets.only(left: 54, top: 8),
                      child: FittedBox(fit: BoxFit.scaleDown, child: amount),
                    ),
                  if (running != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 54, top: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Running balance ${money(running!, wallet.currency)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class DateField extends StatelessWidget {
  final DateTime? value;
  final String label;
  final ValueChanged<DateTime?> onChanged;
  final bool optional;
  const DateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Date',
    this.optional = false,
  });
  Future<void> pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date != null) onChanged(date);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SelectionRow(
        label: label,
        value: value == null ? 'Not set' : prettyDay(dayKey(value!)),
        icon: Icons.calendar_today_outlined,
        onTap: () => pick(context),
      ),
      if (optional && value != null)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => onChanged(null),
            child: const Text('Clear date'),
          ),
        ),
    ],
  );
}

class IconPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const IconPicker({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SelectionRow(
    label: 'Icon',
    value: value[0].toUpperCase() + value.substring(1),
    icon: iconFor(value),
    onTap: () async {
      final selected = await push<String>(
        context,
        _IconLibrary(selected: value),
      );
      if (selected != null) onChanged(selected);
    },
  );
}

class _IconLibrary extends StatefulWidget {
  final String selected;
  const _IconLibrary({required this.selected});
  @override
  State<_IconLibrary> createState() => _IconLibraryState();
}

class _IconLibraryState extends State<_IconLibrary> {
  String query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose icon')),
    body: PageBody(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search icons',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v.toLowerCase()),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? 2
                : constraints.maxWidth > 600
                ? 6
                : 4;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in appIcons.entries.where(
                  (e) => e.key.contains(query),
                ))
                  SizedBox(
                    width: (constraints.maxWidth - (columns - 1) * 8) / columns,
                    child: Material(
                      color: widget.selected == e.key
                          ? AppTheme.lavender
                          : AppTheme.mantle,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(context, e.key),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 4,
                          ),
                          child: Column(
                            children: [
                              Icon(e.value, color: AppTheme.accent),
                              const SizedBox(height: 8),
                              Text(
                                e.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
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
    ),
  );
}

Future<void> exportLedger(
  BuildContext context,
  AppController app,
  Iterable<Entry> entries,
  String name,
) async {
  try {
    final saved = await FileService.save(
      '$name-${dayKey(DateTime.now())}.csv',
      FileService.csv(app.data, entries),
      'csv',
    );
    if (context.mounted && saved) message(context, 'Ledger CSV saved');
  } catch (_) {
    if (context.mounted) {
      message(context, 'Could not export this ledger. Please try again.');
    }
  }
}
