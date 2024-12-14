import 'package:flutter/material.dart';
import 'package:manavalan_finance/database/database_helper.dart';
import 'package:manavalan_finance/models/category.dart';
import 'package:manavalan_finance/models/transaction.dart';
import 'package:manavalan_finance/models/wallet.dart';

class AddTransactionScreen extends StatefulWidget {
  final Wallet wallet;

  AddTransactionScreen({required this.wallet});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'debit';
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories =
        await DatabaseHelper.instance.getCategoriesByWallet(widget.wallet.id!);
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final currentBalance = widget.wallet.balance;
    final balanceAfter =
        _type == 'credit' ? currentBalance + amount : currentBalance - amount;

    final transaction = FinanceTransaction(
      walletId: widget.wallet.id!,
      categoryId: _selectedCategory?.id,
      amount: amount,
      type: _type,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      balanceBefore: currentBalance,
      balanceAfter: balanceAfter,
      date: DateTime.now(),
    );

    await DatabaseHelper.instance.insertTransaction(transaction);

    // Update wallet balance
    widget.wallet.balance = balanceAfter;
    // TODO: Update wallet balance in database

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Expense'),
                            value: 'debit',
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() => _type = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Income'),
                            value: 'credit',
                            groupValue: _type,
                            onChanged: (value) {
                              setState(() => _type = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<Category>(
                      decoration: InputDecoration(
                        labelText: 'Category (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (Category? value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saveTransaction,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Save Transaction'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
