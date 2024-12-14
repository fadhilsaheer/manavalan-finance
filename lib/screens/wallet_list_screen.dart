import 'package:flutter/material.dart';
import 'package:manavalan_finance/database/database_helper.dart';
import 'package:manavalan_finance/models/wallet.dart';
import 'package:manavalan_finance/screens/wallet_detail_screen.dart';

class WalletListScreen extends StatefulWidget {
  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  late Future<List<Wallet>> _walletsFuture;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _walletsFuture = DatabaseHelper.instance.getWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wallets'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadWallets,
        child: FutureBuilder<List<Wallet>>(
          future: _walletsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading wallets',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadWallets,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final wallets = snapshot.data ?? [];

            if (wallets.isEmpty) {
              // We still want pull-to-refresh to work with empty state
              return CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No wallets yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first wallet to start tracking',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              itemCount: wallets.length,
              padding: EdgeInsets.all(8),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        wallet.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    title: Text(wallet.name),
                    subtitle: Text(
                      'Balance: \$${wallet.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: wallet.balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WalletDetailScreen(wallet: wallet),
                        ),
                      ).then((_) =>
                          _loadWallets()); // Refresh after returning from detail screen
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddWalletDialog(context);
        },
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Wallet Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16),
            TextField(
              controller: balanceController,
              decoration: InputDecoration(
                labelText: 'Opening Balance',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  balanceController.text.isEmpty) {
                return;
              }

              final wallet = Wallet(
                name: nameController.text,
                openingBalance: double.parse(balanceController.text),
                balance: double.parse(balanceController.text),
              );

              await DatabaseHelper.instance.insertWallet(wallet);
              Navigator.pop(context);
              // Refresh the wallet list
              _loadWallets();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Wallet created successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
