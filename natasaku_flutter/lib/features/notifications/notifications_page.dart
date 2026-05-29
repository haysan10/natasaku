import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';
import '../../core/services/android_widget_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/budget_repository.dart';
import 'notifications_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  final NotificationsService _service = NotificationsService();

  bool _loading = true;
  UserSettings _settings = const UserSettings();
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);

  // State Simulator Notifikasi Jatah Harian
  bool _simulatorHideBalance = false;
  String _simulatorState = 'aman';
  int _simulatorSisaJatah = 166667;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repo.loadUserSettings();
    final parts = settings.dailyReminderTime.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _time = TimeOfDay(hour: hour, minute: minute);
      _loading = false;
    });
  }

  Future<void> _saveSettings({
    required bool reminderEnabled,
    required TimeOfDay reminderTime,
    required bool quickToolsNotificationEnabled,
  }) async {
    final hh = reminderTime.hour.toString().padLeft(2, '0');
    final mm = reminderTime.minute.toString().padLeft(2, '0');
    final updated = _settings.copyWith(
      dailyReminderEnabled: reminderEnabled,
      dailyReminderTime: '$hh:$mm',
      quickToolsNotificationEnabled: quickToolsNotificationEnabled,
    );
    await _repo.saveUserSettings(updated);
    await _service.scheduleDailyReminder(
      enabled: reminderEnabled,
      timeHHmm: '$hh:$mm',
    );
    await AndroidWidgetService.setQuickToolsNotificationEnabled(
      quickToolsNotificationEnabled,
    );

    // Integrasikan ongoing notification: Tampilkan jika aktif, matikan jika tidak aktif
    if (quickToolsNotificationEnabled) {
      await _service.showDailyAllowanceNotification(
        sisaJatah: _simulatorSisaJatah,
        status: _simulatorState,
        hideBalance: _simulatorHideBalance,
      );
    } else {
      await _service.cancelPersistentNotification();
    }

    if (!mounted) return;
    setState(() {
      _settings = updated;
      _time = reminderTime;
    });
  }

  Widget _buildStateChip({
    required String label,
    required String stateValue,
    required int sisa,
  }) {
    final isSelected = _simulatorState == stateValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      onSelected: (selected) async {
        if (!selected) return;
        setState(() {
          _simulatorState = stateValue;
          _simulatorSisaJatah = sisa;
        });
        await _service.showDailyAllowanceNotification(
          sisaJatah: sisa,
          status: stateValue,
          hideBalance: _simulatorHideBalance,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat & Quick Tools')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifikasi Jatah Harian NataSaku',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silent & Tetap Tampil (Ongoing)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Notifikasi persisten yang stay di shade notifikasi untuk memantau sisa jatah harian secara real-time tanpa mengganggu kenyamananmu.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tombol Aksi Cepat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dilengkapi dengan 3 tombol interaktif (Catat Jajan, Amankan Sisa, Budget) untuk akses instan ke seluruh alur utama keuangan NataSaku.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: _settings.dailyReminderEnabled,
              onChanged: (value) => _saveSettings(
                reminderEnabled: value,
                reminderTime: _time,
                quickToolsNotificationEnabled:
                    _settings.quickToolsNotificationEnabled,
              ),
              title: const Text('Reminder Harian'),
              subtitle:
                  Text('Ingatkan saya setiap ${_settings.dailyReminderTime}.'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Waktu Reminder'),
              subtitle: Text(_settings.dailyReminderTime),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked == null) return;
                await _saveSettings(
                  reminderEnabled: _settings.dailyReminderEnabled,
                  reminderTime: picked,
                  quickToolsNotificationEnabled:
                      _settings.quickToolsNotificationEnabled,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: _settings.quickToolsNotificationEnabled,
              onChanged: (value) => _saveSettings(
                reminderEnabled: _settings.dailyReminderEnabled,
                reminderTime: _time,
                quickToolsNotificationEnabled: value,
              ),
              title: const Text('Aktifkan Notifikasi Jatah Harian'),
              subtitle: const Text(
                'Notifikasi persisten jatah harian tetap stay di notification bar Android.',
              ),
            ),
          ),
          
          if (kDebugMode && _settings.quickToolsNotificationEnabled) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.teal.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science_outlined, color: Colors.teal),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🧪 Simulator Jatah Harian NataSaku',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uji visual 6 state notifikasi (Aman, Waspada, Over, Loading, Error, Hide Balance) secara interaktif langsung pada notification tray perangkat Anda:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStateChip(label: 'Aman 💚', stateValue: 'aman', sisa: 166667),
                        _buildStateChip(label: 'Waspada ⚠️', stateValue: 'waspada', sisa: 35000),
                        _buildStateChip(label: 'Over 🚨', stateValue: 'over', sisa: 0),
                        _buildStateChip(label: 'Loading ⏳', stateValue: 'loading', sisa: 0),
                        _buildStateChip(label: 'Error ❌', stateValue: 'error', sisa: 0),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _simulatorHideBalance,
                      onChanged: (value) async {
                        setState(() => _simulatorHideBalance = value);
                        await _service.showDailyAllowanceNotification(
                          sisaJatah: _simulatorSisaJatah,
                          status: _simulatorState,
                          hideBalance: value,
                        );
                      },
                      title: const Text('Sembunyikan Nominal (Hide Balance)'),
                      subtitle: const Text('Tampilkan jatah harian sebagai Rp••••••'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Text('Aksi Navigasi Cepat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Buka Beranda'),
              subtitle: const Text('Cek jatah aman hari ini'),
              onTap: () => context.go(AppRouter.dashboard),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Buka Catat Transaksi'),
              subtitle: const Text('Tambah transaksi dengan cepat'),
              onTap: () => context.go(AppRouter.transactions),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Buka Daily Closing'),
              subtitle: const Text('Tutup hari dan sinkronkan jatah besok'),
              onTap: () => context.push(AppRouter.dailyClosing),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Layanan ini terintegrasi penuh ke sistem notifikasi background & foreground Android.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
