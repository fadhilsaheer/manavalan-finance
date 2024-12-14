import 'package:flutter/material.dart';
import 'package:manavalan_finance/models/wallet.dart';
import 'package:manavalan_finance/screens/add_transaction_screen.dart';
import 'package:manavalan_finance/screens/tabs/transactions_tab.dart';

class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  _WalletDetailScreenState createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  int _currentIndex = 0;

  final _refreshNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TransactionsTab(
            wallet: widget.wallet,
            refreshNotifier: _refreshNotifier,
          ),
          // CategoriesTab(wallet: widget.wallet),
          // ChartTab(wallet: widget.wallet),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Charts',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          if (_currentIndex == 0) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(
                  wallet: widget.wallet,
                ),
              ),
            );

            // If transaction was added successfully, notify the transactions tab to refresh
            if (result == true) {
              _refreshNotifier.value = !_refreshNotifier.value;
            }
          } else if (_currentIndex == 1) {
            // Show dialog to add category
          }
        },
      ),
    );
  }
}
