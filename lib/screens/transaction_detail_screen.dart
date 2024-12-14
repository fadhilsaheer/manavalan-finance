import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manavalan_finance/models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final FinanceTransaction transaction;

  TransactionDetailScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: transaction.type == 'credit'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  SizedBox(height: 24),
                  DetailRow(
                    label: 'Type',
                    value: transaction.type.toUpperCase(),
                  ),
                  DetailRow(
                    label: 'Date',
                    value: dateFormat.format(transaction.date),
                  ),
                  DetailRow(
                    label: 'Time',
                    value: timeFormat.format(transaction.date),
                  ),
                  if (transaction.note != null)
                    DetailRow(
                      label: 'Note',
                      value: transaction.note!,
                    ),
                  DetailRow(
                    label: 'Balance Before',
                    value: '\$${transaction.balanceBefore.toStringAsFixed(2)}',
                  ),
                  DetailRow(
                    label: 'Balance After',
                    value: '\$${transaction.balanceAfter.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
