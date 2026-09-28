import 'package:flutter/material.dart';

import 'data/ledger_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LedgerStore.open();
  final snapshot = await store.snapshot();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Manavalan Finance · ${snapshot.wallets.length} wallets'),
        ),
      ),
    ),
  );
}
