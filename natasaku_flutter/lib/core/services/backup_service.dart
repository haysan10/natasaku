import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/repositories/budget_repository.dart';

import '../../core/utils/nominal_input_validator.dart';

class BackupService {
  BackupService({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository(LocalStorage());

  final BudgetRepository _repository;

  Future<File> exportBackup() async {
    final raw = await _repository.exportRawData();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/natasaku_backup_$timestamp.json');

    final payload = <String, dynamic>{
      'app': 'NataSaku',
      'version': 1,
      'schemaVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'raw': raw,
    };

    await file.writeAsString(jsonEncode(payload));
    return file;
  }

  Future<List<File>> listBackups() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) =>
            f.path.contains('natasaku_backup_') && f.path.endsWith('.json'))
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<bool> restoreLatestBackup() async {
    final files = await listBackups();
    if (files.isEmpty) return false;

    final content = await files.first.readAsString();
    final validation = NominalInputValidator.validateRestore(content, files.first.path);
    if (validation['status'] == 'error') {
      return false;
    }
    final raw = validation['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    await _repository.importRawData(raw);
    return true;
  }
}
