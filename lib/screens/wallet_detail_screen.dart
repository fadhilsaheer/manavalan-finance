import 'package:flutter/material.dart';
import 'package:manavalan_finance/models/wallet.dart';

class WalletDetailScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  _WalletDetailScreenState createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          // TransactionsTab(wallet: widget.wallet),
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
        onPressed: () {
          if (_currentIndex == 0) {
            // Navigate to add transaction screen
          } else if (_currentIndex == 1) {
            // Show dialog to add category
          }
        },
      ),
    );
  }
}