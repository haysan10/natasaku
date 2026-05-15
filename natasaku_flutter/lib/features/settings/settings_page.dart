import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/services/backup_service.dart';
import '../../shared/widgets/main_shell.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BackupService _backupService = BackupService();
  String? _status;

  void _onNavigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.transactions);
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.reports);
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.savings);
      case 4:
        break;
    }
  }

  Future<void> _exportBackup() async {
    final file = await _backupService.exportBackup();
    if (!mounted) return;
    setState(() => _status = 'Cadangan data dibuat di ${file.path}');
  }

  Future<void> _restoreBackup() async {
    final restored = await _backupService.restoreLatestBackup();
    if (!mounted) return;
    setState(() {
      _status = restored
          ? 'Cadangan terbaru berhasil dipulihkan.'
          : 'Belum ada file cadangan yang bisa dipulihkan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainShell(
      index: 4,
      onNavigate: _onNavigate,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            Text(
              'Pengaturan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Atur hal penting NataSaku di sini.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Atur Periode'),
                subtitle: const Text(
                  'Ubah tanggal periode, dana fleksibel awal, dan mode budget.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, AppRouter.setup),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Pengingat Harian'),
                subtitle: const Text(
                  'Atur waktu pengingat untuk cek pengeluaran dan tutup hari.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.notifications),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Cadangkan Data'),
                subtitle: const Text(
                  'Simpan salinan data NataSaku agar tetap aman.',
                ),
                trailing: const Icon(Icons.download_rounded),
                onTap: _exportBackup,
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Pulihkan Cadangan'),
                subtitle: const Text(
                  'Muat kembali cadangan data NataSaku yang terakhir.',
                ),
                trailing: const Icon(Icons.restore_rounded),
                onTap: _restoreBackup,
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Status'),
                  subtitle: Text(_status!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
