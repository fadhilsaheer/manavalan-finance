import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manavalan_finance/models/wallet.dart';
import 'package:manavalan_finance/models/transaction.dart';
import 'package:manavalan_finance/database/database_helper.dart';
import 'package:manavalan_finance/screens/transaction_detail_screen.dart';

class TransactionsTab extends StatefulWidget {
  final Wallet wallet;
  final ValueNotifier<bool> refreshNotifier;

  TransactionsTab({
    required this.wallet,
    required this.refreshNotifier,
  });

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  late Future<List<FinanceTransaction>> _transactionsFuture;
  late Wallet _currentWallet;

  @override
  void initState() {
    super.initState();
    _currentWallet = widget.wallet;
    _loadTransactions();

    // Listen to refresh notifications
    widget.refreshNotifier.addListener(_loadTransactions);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_loadTransactions);
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    // Refresh wallet data first
    final updatedWallet =
        await DatabaseHelper.instance.getWallet(widget.wallet.id!);
    if (updatedWallet != null) {
      setState(() {
        _currentWallet = updatedWallet;
        _transactionsFuture =
            DatabaseHelper.instance.getTransactionsByWallet(widget.wallet.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: WalletSummaryCard(wallet: _currentWallet),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: TransactionsList(
              walletId: widget.wallet.id!,
              transactionsFuture: _transactionsFuture,
            ),
          ),
        ],
      ),
    );
  }
}

class WalletSummaryCard extends StatelessWidget {
  final Wallet wallet;

  WalletSummaryCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '\$${wallet.balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: wallet.balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Opening Balance',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${wallet.openingBalance.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Net Change',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${(wallet.balance - wallet.openingBalance).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: wallet.balance >= wallet.openingBalance
                                ? Colors.green
                                : Colors.red,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  final int walletId;
  final Future<List<FinanceTransaction>> transactionsFuture;

  TransactionsList({
    required this.walletId,
    required this.transactionsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FinanceTransaction>>(
      future: transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error loading transactions')),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Add your first transaction using the + button',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final transaction = transactions[index];
              return TransactionListItem(
                transaction: transaction,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailScreen(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              );
            },
            childCount: transactions.length,
          ),
        );
      },
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final FinanceTransaction transaction;
  final VoidCallback onTap;

  TransactionListItem({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.type == 'credit' ? Colors.green : Colors.red,
          child: Icon(
            transaction.type == 'credit' ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.note ?? 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == 'credit' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(transaction.date)),
            Text(
              timeFormat.format(transaction.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
