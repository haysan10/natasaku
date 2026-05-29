import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/services/backup_service.dart';
import '../../shared/widgets/global_feature_tour.dart';
import '../../core/dev/mock_data_seeder.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../security/pin_lock_page.dart';
import '../security/providers/security_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final BackupService _backupService = BackupService();
  String? _status;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool(AppConstants.soundEnabledKey) ?? true;
    });
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.soundEnabledKey, value);
    setState(() {
      _soundEnabled = value;
    });
  }

  Future<void> _exportBackup() async {
    final file = await _backupService.exportBackup();
    if (!mounted) return;
    setState(() => _status = 'Cadangan data dibuat di ${file.path}');
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pulihkan cadangan?'),
        content: const Text(
          'Data lokal akan diganti dengan cadangan terbaru yang ditemukan di perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final restored = await _backupService.restoreLatestBackup();
    if (!mounted) return;
    setState(() {
      _status = restored
          ? 'Cadangan terbaru berhasil dipulihkan.'
          : 'Belum ada file cadangan yang bisa dipulihkan.';
    });
  }

  Future<void> _loadMockData() async {
    if (kReleaseMode) {
      setState(() => _status = 'Fitur data tes tidak tersedia di APK release.');
      return;
    }
    setState(() => _status = 'Sedang memuat data tes...');
    try {
      await MockDataSeeder.seed();
      await ref.read(dashboardProvider.notifier).loadData();
      if (!mounted) return;
      setState(() => _status = 'Sukses memuat data tes (UMR Jakarta)! Semua halaman kini aktif.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Gagal memuat data tes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
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
                title: const Text('Tagihan & Anggaran Tetap'),
                subtitle: const Text(
                  'Catat pengeluaran pasti bulan ini (Kos, Cicilan, Listrik) untuk mengatur jatah harian lebih akurat.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.bills),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Transaksi Berulang'),
                subtitle: const Text(
                  'Atur pengeluaran/pemasukan otomatis yang berulang setiap hari, minggu, atau bulan.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.recurringTransactions),
              ),
            ),
            Card(
              key: TourKeys.debtsMenu,
              child: ListTile(
                title: const Text('Mode Utang'),
                subtitle: const Text(
                  'Catat dan lacak utang piutang dengan mudah agar tidak terlupakan.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.debts),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Atur Periode'),
                subtitle: const Text(
                  'Ubah tanggal periode, dana fleksibel awal, dan mode budget.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.setup),
              ),
            ),
            if (!kReleaseMode)
              Card(
                color: Colors.purple.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.purple.withValues(alpha: 0.3), width: 1),
                ),
                child: ListTile(
                  title: const Text(
                    '🧪 Muat Data Tes (UMR Jakarta)',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Mengisi transaksi, budget periode, dan tabungan untuk pengujian visual interaktif.',
                  ),
                  trailing: const Icon(Icons.science_outlined, color: Colors.purple),
                  onTap: _loadMockData,
                ),
              ),
            Card(
              child: ListTile(
                title: const Text('Pengingat Harian'),
                subtitle: const Text(
                  'Atur waktu pengingat untuk cek pengeluaran dan tutup hari.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.notifications),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Keamanan Aplikasi (PIN)'),
                subtitle: const Text(
                  'Kunci NataSaku dengan PIN 4-digit agar data keuanganmu tetap privat.',
                ),
                trailing: Switch(
                  value: ref.watch(securityProvider).hasPin,
                  onChanged: (val) {
                    if (val) {
                      // Enable PIN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinLockPage(mode: PinMode.setup),
                        ),
                      );
                    } else {
                      // Disable PIN
                      ref.read(securityProvider.notifier).removePin();
                    }
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Efek Suara NataSaku 🔊'),
                subtitle: const Text(
                  'Mainkan nada bel yang ramah pada saat mencatat transaksi atau mencapai target.',
                ),
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tema',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih tampilan terang, gelap, atau ikuti perangkat.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Terang'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Gelap'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistem'),
                          icon: Icon(Icons.settings_suggest_outlined),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (selection) {
                        final selectedMode = selection.first;
                        ref
                            .read(themeModeProvider.notifier)
                            .updateThemeMode(selectedMode);
                      },
                    ),
                  ],
                ),
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
