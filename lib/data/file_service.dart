import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/models.dart';
import 'ledger_store.dart';

class FileService {
  static Future<bool> save(
    String name,
    String content,
    String extension,
  ) async {
    final destination = await FilePicker.saveFile(
      dialogTitle: 'Save $name',
      fileName: name,
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: extension == 'json' ? 'application/json' : 'text/csv',
    );
    return destination != null;
  }

  static Future<String?> chooseBackup() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    final size = await file.length();
    if (size != null && size > 20000000) {
      throw const LedgerError('Backup is too large (maximum 20 MB).');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > 20000000) {
      throw const LedgerError('Backup is too large (maximum 20 MB).');
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      throw const LedgerError('Backup must be a UTF-8 JSON file.');
    }
  }

  static Future<String> restoreWithSafetyCopy(
    LedgerStore store,
    String content,
  ) async {
    final directory = await getApplicationSupportDirectory();
    final path = p.join(
      directory.path,
      'before-restore-${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await File(path).writeAsString(await store.backup(), flush: true);
    await store.restore(content);
    await store.setSetting('safety_backup_path', path);
    return path;
  }

  static String csv(LedgerSnapshot data, Iterable<Entry> entries) {
    String cell(Object? value) {
      var text = value?.toString() ?? '';
      // Prevent user-authored notes/names becoming spreadsheet formulas.
      if (RegExp(r'^\s*[=+@-]').hasMatch(text)) text = "'$text";
      return '"${text.replaceAll('"', '""')}"';
    }

    final rows = <List<Object?>>[
      [
        'Date',
        'Wallet',
        'Currency',
        'Type',
        'Amount',
        'Cash direction',
        'Category',
        'Group',
        'Person',
        'Note',
      ],
      for (final e in entries)
        [
          e.date,
          data.wallets.firstWhere((w) => w.id == e.walletId).name,
          data.wallets.firstWhere((w) => w.id == e.walletId).currency,
          e.kind.label,
          moneyInput(e.amount),
          e.sign > 0 ? 'In' : 'Out',
          e.kind.ordinary ? data.categoryName(e.categoryId) : '',
          data.group(e.groupId)?.name ?? '',
          data.loan(e.loanId)?.person ?? '',
          e.note,
        ],
    ];
    return '\uFEFF${rows.map((row) => row.map(cell).join(',')).join('\r\n')}\r\n';
  }
}
