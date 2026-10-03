import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'core/app_controller.dart';
import 'data/ledger_store.dart';
import 'ui/app.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/fonts/Roboto_LICENSE.txt',
    );
    yield LicenseEntryWithLineBreaks(['Roboto'], license);
  });
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  AppController? app;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => failed = false);
    LedgerStore? store;
    try {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      if (Platform.isIOS) {
        await const MethodChannel('manavalan/privacy')
            .invokeMethod<void>('excludeFromBackup', {'path': directory.path});
      }
      store = await LedgerStore.open(
        path: p.join(directory.path, 'manavalan.db'),
      );
      final controller = AppController(store);
      await controller.init();
      if (mounted) {
        setState(() => app = controller);
      } else {
        controller.dispose();
        await store.db.close();
      }
    } catch (_) {
      await store?.db.close();
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    app?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (app != null) return FinanceApp(controller: app!);
    return MaterialApp(
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 88),
                  const SizedBox(height: 24),
                  if (!failed)
                    const CircularProgressIndicator()
                  else ...[
                    const Text(
                      'Could not open your local ledger. Your saved data has not been removed.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: load,
                      child: const Text('Try again'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
