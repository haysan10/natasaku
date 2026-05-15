import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/budget_repository.dart';
import '../../shared/widgets/main_shell.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());

  bool _loading = true;
  double _balance = 0;
  List<Map<String, dynamic>> _history = <Map<String, dynamic>>[];
  UserSettings _settings = const UserSettings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repo.loadUserSettings();
    final balance = await _repo.loadSavingBalance();
    final history = await _repo.loadSavingAllocations();
    history
        .sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    if (!mounted) return;
    setState(() {
      _settings = settings;
      _balance = balance;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _toggleAutoSaving(bool enabled) async {
    final updated = UserSettings(
      dailyReminderEnabled: _settings.dailyReminderEnabled,
      dailyReminderTime: _settings.dailyReminderTime,
      quickToolsNotificationEnabled: _settings.quickToolsNotificationEnabled,
      autoSavingEnabled: enabled,
      budgetMode: _settings.budgetMode,
      usageStyle: _settings.usageStyle,
    );
    await _repo.saveUserSettings(updated);
    if (!mounted) return;
    setState(() => _settings = updated);
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.transactions);
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.reports);
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRouter.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainShell(
      index: 3,
      onNavigate: _onNavigate,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text('Celengan',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      title: const Text('Saldo Auto-Celengan'),
                      subtitle: Text(
                        CurrencyService.formatRupiah(_balance),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Card(
                    child: SwitchListTile(
                      value: _settings.autoSavingEnabled,
                      onChanged: _toggleAutoSaving,
                      title: const Text('Auto-Celengan dari sisa jatah'),
                      subtitle: const Text(
                        'Saat Tutup Hari, sisa jatah positif otomatis masuk celengan.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Riwayat Alokasi',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('Belum ada alokasi tabungan otomatis'),
                        subtitle: Text(
                            'Mulai Tutup Hari untuk mengisi Auto-Celengan.'),
                      ),
                    ),
                  for (final item in _history)
                    Card(
                      child: ListTile(
                        title: Text(
                          CurrencyService.formatRupiah(
                              (item['amount'] as num).toDouble()),
                        ),
                        subtitle: Text(
                          (item['date'] as String).split('T').first,
                        ),
                        trailing: Text((item['source'] as String?) ?? 'auto'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
