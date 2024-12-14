import 'package:flutter/material.dart';
import 'package:manavalan_finance/models/wallet.dart';
import 'package:manavalan_finance/models/category.dart';
import 'package:manavalan_finance/database/database_helper.dart';

class CategoriesTab extends StatefulWidget {
  final Wallet wallet;
  final ValueNotifier<bool> refreshNotifier;

  CategoriesTab({
    required this.wallet,
    required this.refreshNotifier,
  });

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Listen to refresh notifications
    widget.refreshNotifier.addListener(_loadCategories);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_loadCategories);
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesFuture = DatabaseHelper.instance.getCategoriesByWallet(
        widget.wallet.id!,
      );
    });
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                return;
              }

              final category = Category(
                walletId: widget.wallet.id!,
                name: nameController.text.trim(),
              );

              await DatabaseHelper.instance.insertCategory(category);
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      widget.refreshNotifier.value = !widget.refreshNotifier.value;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await DatabaseHelper.instance.deleteCategory(category.id!);
      widget.refreshNotifier.value = !widget.refreshNotifier.value;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
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
                    'Error loading categories',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add categories to organize your transactions',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _addCategory,
                          icon: Icon(Icons.add),
                          label: Text('Add Category'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      category.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () => _deleteCategory(category),
                    color: Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
