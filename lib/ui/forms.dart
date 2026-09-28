import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../core/models.dart';
import 'shared.dart';
import 'theme.dart';

String? nameValidator(String? value) {
  try {
    requireName(value ?? '');
    return null;
  } on LedgerError catch (e) {
    return e.message;
  }
}

String? amountValidator(
  String? value, {
  bool signed = false,
  bool zero = false,
}) {
  try {
    parseMoney(value ?? '', signed: signed, allowZero: zero);
    return null;
  } on LedgerError catch (e) {
    return e.message;
  }
}

TextFormField nameField(
  TextEditingController controller, {
  String label = 'Name',
}) => TextFormField(
  controller: controller,
  decoration: InputDecoration(labelText: label),
  textCapitalization: TextCapitalization.words,
  maxLength: 80,
  buildCounter: (
    _, {
    required currentLength,
    required isFocused,
    required maxLength,
  }) => null,
  validator: nameValidator,
);
TextFormField amountField(
  TextEditingController controller,
  String currency, {
  String label = 'Amount',
  bool signed = false,
  bool zero = false,
}) => TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: '$label ($currency)',
    hintText: '0.00',
    hintStyle: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      color: AppTheme.muted,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    fillColor: AppTheme.base,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
  ),
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: signed),
  validator: (value) => amountValidator(value, signed: signed, zero: zero),
);
Widget noteField(TextEditingController controller) => ExpansionTile(
  initiallyExpanded: controller.text.isNotEmpty,
  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const Border(),
  collapsedShape: const Border(),
  leading: const Icon(Icons.notes_rounded, size: 20),
  title: const Text('Note', style: TextStyle(fontSize: 14)),
  children: [
    TextFormField(
      controller: controller,
      decoration: const InputDecoration(hintText: 'Add a note'),
      maxLines: 3,
      maxLength: 1000,
    ),
  ],
);

class FormScreen extends StatelessWidget {
  final AppController app;
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final VoidCallback onSave;
  final bool saving;
  const FormScreen({
    super.key,
    required this.app,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.onSave,
    this.saving = false,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (app.wallet != null)
            Text(
              app.wallet!.name,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
        ],
      ),
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: PageBody(
                children: [
                  for (final field in fields)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: field,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: 780,
              child: FilledButton(
                onPressed: saving ? null : onSave,
                child: saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class WalletForm extends StatefulWidget {
  final AppController app;
  final Wallet? existing;
  const WalletForm({super.key, required this.app, this.existing});
  @override
  State<WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends State<WalletForm> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late final opening = TextEditingController(
    text: moneyInput(widget.existing?.opening ?? 0),
  );
  late String currency = widget.existing?.currency ?? 'INR';
  late String icon = widget.existing?.icon ?? 'wallet';
  late int color = widget.existing?.color ?? 0;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    opening.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    int? id;
    final ok = await perform(context, widget.app, () async {
      id = await widget.app.store.saveWallet(
        id: widget.existing?.id,
        name: name.text,
        currency: currency,
        opening: parseMoney(opening.text, signed: true, allowZero: true),
        icon: icon,
        color: color,
      );
      if (widget.existing == null) widget.app.walletId = id;
    }, success: 'Wallet saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: widget.existing == null ? 'Create wallet' : 'Edit wallet',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      nameField(name, label: 'Wallet name'),
      DropdownButtonFormField<String>(
        initialValue: currency,
        decoration: const InputDecoration(labelText: 'Currency'),
        items: currencies
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => currency = v!),
      ),
      amountField(
        opening,
        currency,
        label: 'Opening balance',
        signed: true,
        zero: true,
      ),
      const Text(
        'Starting balance before your first entry.',
        style: TextStyle(color: AppTheme.muted),
      ),
      IconPicker(value: icon, onChanged: (v) => setState(() => icon = v)),
      Wrap(
        spacing: 8,
        children: List.generate(
          AppTheme.accents.length,
          (i) => IconButton(
            tooltip: 'Wallet colour ${i + 1}',
            onPressed: () => setState(() => color = i),
            icon: Icon(
              color == i ? Icons.check_circle : Icons.circle,
              color: AppTheme.accents[i],
              size: 32,
            ),
          ),
        ),
      ),
    ],
  );
}

class CategoryForm extends StatefulWidget {
  final AppController app;
  final Category? existing;
  final int? parentId;
  final String kind;
  const CategoryForm({
    super.key,
    required this.app,
    this.existing,
    this.parentId,
    this.kind = 'expense',
  });
  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late String kind = widget.existing?.kind ?? widget.kind;
  late String icon = widget.existing?.icon ?? 'bag';
  late int? parent = widget.existing?.parentId ?? widget.parentId;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    int? id;
    final ok = await perform(context, widget.app, () async {
      id = await widget.app.store.saveCategory(
        id: widget.existing?.id,
        walletId: widget.app.walletId!,
        parentId: parent,
        name: name.text,
        kind: kind,
        icon: icon,
        position: widget.existing?.position ?? widget.app.categories.length,
      );
    }, success: 'Category saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: widget.existing == null ? 'Create category' : 'Edit category',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      nameField(name, label: 'Category name'),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'expense', label: Text('Expense')),
          ButtonSegment(value: 'income', label: Text('Income')),
        ],
        selected: {kind},
        onSelectionChanged: (v) => setState(() {
          kind = v.first;
          parent = null;
        }),
      ),
      DropdownButtonFormField<int>(
        key: ValueKey('$kind-$parent'),
        initialValue: parent,
        decoration: const InputDecoration(labelText: 'Main category'),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Text('None — make a main category'),
          ),
          ...widget.app.categories
              .where(
                (c) =>
                    c.parentId == null &&
                    c.kind == kind &&
                    !c.archived &&
                    c.id != widget.existing?.id,
              )
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
        ],
        isExpanded: true,
        onChanged: (v) => setState(() => parent = v),
      ),
      IconPicker(value: icon, onChanged: (v) => setState(() => icon = v)),
    ],
  );
}

class GroupForm extends StatefulWidget {
  final AppController app;
  final LedgerGroup? existing;
  const GroupForm({super.key, required this.app, this.existing});
  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final key = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.existing?.name ?? '');
  late final note = TextEditingController(text: widget.existing?.note ?? '');
  late String icon = widget.existing?.icon ?? 'group';
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    int? id;
    final ok = await perform(context, widget.app, () async {
      id = await widget.app.store.saveGroup(
        id: widget.existing?.id,
        walletId: widget.app.walletId!,
        name: name.text,
        note: note.text,
        icon: icon,
      );
    }, success: 'Group saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: widget.existing == null ? 'Create group' : 'Edit group',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      nameField(name, label: 'Group name'),
      noteField(note),
      IconPicker(value: icon, onChanged: (v) => setState(() => icon = v)),
    ],
  );
}

class TransactionForm extends StatefulWidget {
  final AppController app;
  final Entry? existing;
  final int? groupId;
  const TransactionForm({
    super.key,
    required this.app,
    this.existing,
    this.groupId,
  });
  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final key = GlobalKey<FormState>();
  late final amount = TextEditingController(
    text: widget.existing == null ? '' : moneyInput(widget.existing!.amount),
  );
  late final note = TextEditingController(text: widget.existing?.note ?? '');
  late EntryKind kind = widget.existing?.kind ?? EntryKind.expense;
  late DateTime date = widget.existing == null
      ? DateTime.now()
      : DateTime.parse(widget.existing!.date);
  late int? category = widget.existing?.categoryId;
  late int? group = widget.existing?.groupId ?? widget.groupId;
  bool saving = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    final ok = await perform(context, widget.app, () async {
      await widget.app.store.saveEntry(
        id: widget.existing?.id,
        walletId: widget.app.walletId!,
        amount: parseMoney(amount.text),
        kind: kind,
        date: dayKey(date),
        note: note.text,
        categoryId: category,
        groupId: group,
      );
    }, success: 'Transaction saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.app,
    builder: (context, _) => FormScreen(
      app: widget.app,
      title: widget.existing == null ? 'New transaction' : 'Edit transaction',
      formKey: key,
      onSave: save,
      saving: saving,
      fields: [
        amountField(amount, widget.app.wallet!.currency),
        SegmentedButton<EntryKind>(
          segments: const [
            ButtonSegment(
              value: EntryKind.expense,
              icon: Icon(Icons.arrow_upward),
              label: Text('Expense'),
            ),
            ButtonSegment(
              value: EntryKind.income,
              icon: Icon(Icons.arrow_downward),
              label: Text('Income'),
            ),
          ],
          selected: {kind},
          onSelectionChanged: (v) => setState(() {
            kind = v.first;
            category = null;
          }),
        ),
        DateField(value: date, onChanged: (v) => setState(() => date = v!)),
        DropdownButtonFormField<int>(
          key: ValueKey('category-$category-${kind.name}'),
          initialValue: category,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Uncategorised'),
            ),
            ...widget.app.categories
                .where(
                  (c) =>
                      c.kind == kind.name && (!c.archived || c.id == category),
                )
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      widget.app.data.categoryName(c.id),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
          ],
          onChanged: (v) => setState(() => category = v),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New category'),
            onPressed: () async {
              final id = await push<int>(
                context,
                CategoryForm(app: widget.app, kind: kind.name),
              );
              if (id != null && mounted) setState(() => category = id);
            },
          ),
        ),
        DropdownButtonFormField<int>(
          key: ValueKey('group-$group'),
          initialValue: group,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Group (optional)'),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('No group')),
            ...widget.app.groups
                .where((g) => !g.archived || g.id == group)
                .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
          ],
          onChanged: (v) => setState(() => group = v),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New group'),
            onPressed: () async {
              final id = await push<int>(context, GroupForm(app: widget.app));
              if (id != null && mounted) setState(() => group = id);
            },
          ),
        ),
        noteField(note),
      ],
    ),
  );
}

class LoanForm extends StatefulWidget {
  final AppController app;
  final Loan? existing;
  const LoanForm({super.key, required this.app, this.existing});
  @override
  State<LoanForm> createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final key = GlobalKey<FormState>();
  late final person = TextEditingController(
    text: widget.existing?.person ?? '',
  );
  final amount = TextEditingController();
  late final note = TextEditingController(text: widget.existing?.note ?? '');
  String direction = 'lent';
  DateTime date = DateTime.now();
  late DateTime? due = widget.existing?.due == null
      ? null
      : DateTime.parse(widget.existing!.due!);
  bool openingOnly = false, saving = false;
  @override
  void dispose() {
    person.dispose();
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    final ok = await perform(context, widget.app, () async {
      if (widget.existing != null) {
        await widget.app.store.updateLoan(
          widget.existing!.id,
          person: person.text,
          due: due == null ? null : dayKey(due!),
          note: note.text,
        );
      } else {
        await widget.app.store.createLoan(
          walletId: widget.app.walletId!,
          person: person.text,
          direction: direction,
          amount: parseMoney(amount.text),
          date: dayKey(date),
          due: due == null ? null : dayKey(due!),
          note: note.text,
          openingOnly: openingOnly,
        );
      }
    }, success: 'Loan saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: widget.existing == null ? 'New loan' : 'Edit loan details',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      nameField(person, label: 'Person'),
      if (widget.existing == null) ...[
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'lent', label: Text('I lent')),
            ButtonSegment(value: 'borrowed', label: Text('I borrowed')),
          ],
          selected: {direction},
          onSelectionChanged: (v) => setState(() => direction = v.first),
        ),
        amountField(amount, widget.app.wallet!.currency),
        DateField(value: date, onChanged: (v) => setState(() => date = v!)),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Already outstanding'),
          subtitle: const Text(
            'Track an existing debt without changing wallet cash.',
          ),
          value: openingOnly,
          onChanged: (v) => setState(() => openingOnly = v),
        ),
        Text(
          openingOnly
              ? 'Only the amount owed will change.'
              : direction == 'lent'
              ? 'Wallet cash decreases. This is excluded from spending.'
              : 'Wallet cash increases. This is excluded from income.',
          style: const TextStyle(color: AppTheme.muted),
        ),
      ],
      DateField(
        value: due,
        optional: true,
        label: 'Due date (optional)',
        onChanged: (v) => setState(() => due = v),
      ),
      noteField(note),
    ],
  );
}

class LoanMovementForm extends StatefulWidget {
  final AppController app;
  final Loan loan;
  final bool repayment;
  final Entry? existing;
  const LoanMovementForm({
    super.key,
    required this.app,
    required this.loan,
    this.repayment = true,
    this.existing,
  });
  @override
  State<LoanMovementForm> createState() => _LoanMovementFormState();
}

class _LoanMovementFormState extends State<LoanMovementForm> {
  final key = GlobalKey<FormState>();
  late final amount = TextEditingController(
    text: widget.existing == null ? '' : moneyInput(widget.existing!.amount),
  );
  late final note = TextEditingController(text: widget.existing?.note ?? '');
  late DateTime date = widget.existing == null
      ? DateTime.now()
      : DateTime.parse(widget.existing!.date);
  bool saving = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    final ok = await perform(context, widget.app, () async {
      await widget.app.store.loanMovement(
        widget.loan.id,
        amount: parseMoney(amount.text),
        repayment: widget.repayment,
        entryId: widget.existing?.id,
        date: dayKey(date),
        note: note.text,
      );
    }, success: 'Loan entry saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: widget.existing != null
        ? 'Edit loan entry'
        : widget.repayment
        ? 'Record repayment'
        : 'Add advance',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      Text(
        widget.loan.person,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        'Outstanding ${money(widget.app.data.outstanding(widget.loan), widget.app.wallet!.currency)}',
        style: const TextStyle(color: AppTheme.muted),
      ),
      Text(
        widget.repayment
            ? (widget.loan.lent
                  ? 'Repayment received · wallet cash increases.'
                  : 'Repayment paid · wallet cash decreases.')
            : (widget.loan.lent
                  ? 'Money lent · wallet cash decreases.'
                  : 'Money borrowed · wallet cash increases.'),
        style: const TextStyle(color: AppTheme.muted),
      ),
      amountField(amount, widget.app.wallet!.currency),
      DateField(value: date, onChanged: (v) => setState(() => date = v!)),
      noteField(note),
    ],
  );
}

class TransferForm extends StatefulWidget {
  final AppController app;
  const TransferForm({super.key, required this.app});
  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final key = GlobalKey<FormState>();
  final amount = TextEditingController(), note = TextEditingController();
  int? destination;
  DateTime date = DateTime.now();
  bool saving = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    final ok = await perform(context, widget.app, () async {
      await widget.app.store.transfer(
        from: widget.app.walletId!,
        to: destination!,
        amount: parseMoney(amount.text),
        date: dayKey(date),
        note: note.text,
      );
    }, success: 'Transfer saved');
    if (!mounted) return;
    setState(() => saving = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => FormScreen(
    app: widget.app,
    title: 'Transfer',
    formKey: key,
    onSave: save,
    saving: saving,
    fields: [
      const Text(
        'Between wallets in the same currency.',
        style: TextStyle(color: AppTheme.muted),
      ),
      DropdownButtonFormField<int>(
        initialValue: destination,
        decoration: const InputDecoration(labelText: 'Destination wallet'),
        isExpanded: true,
        items: widget.app.data.wallets
            .where(
              (w) =>
                  !w.archived &&
                  w.id != widget.app.walletId &&
                  w.currency == widget.app.wallet!.currency,
            )
            .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
            .toList(),
        validator: (v) =>
            v == null ? 'Choose another wallet with the same currency.' : null,
        onChanged: (v) => setState(() => destination = v),
      ),
      amountField(amount, widget.app.wallet!.currency),
      DateField(value: date, onChanged: (v) => setState(() => date = v!)),
      noteField(note),
    ],
  );
}
