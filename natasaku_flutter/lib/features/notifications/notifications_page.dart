import 'package:flutter/material.dart';

import '../../app/router.dart';
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
    final updated = UserSettings(
      dailyReminderEnabled: reminderEnabled,
      dailyReminderTime: '$hh:$mm',
      quickToolsNotificationEnabled: quickToolsNotificationEnabled,
      autoSavingEnabled: _settings.autoSavingEnabled,
      budgetMode: _settings.budgetMode,
      usageStyle: _settings.usageStyle,
    );
    await _repo.saveUserSettings(updated);
    await _service.scheduleDailyReminder(
      enabled: reminderEnabled,
      timeHHmm: '$hh:$mm',
    );
    await AndroidWidgetService.setQuickToolsNotificationEnabled(
      quickToolsNotificationEnabled,
    );
    if (!mounted) return;
    setState(() {
      _settings = updated;
      _time = reminderTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder & Quick Action')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
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
              title: const Text('Quick Tools Selalu Tampil'),
              subtitle: const Text(
                'Notifikasi ringkas tetap ada di shade untuk catat cepat.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Quick Action', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Buka Beranda'),
              subtitle: const Text('Cek jatah aman hari ini'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRouter.dashboard),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Buka Catat Transaksi'),
              subtitle: const Text('Tambah transaksi dengan cepat'),
              onTap: () => Navigator.pushReplacementNamed(
                  context, AppRouter.transactions),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Buka Daily Closing'),
              subtitle: const Text('Tutup hari dan sinkronkan jatah besok'),
              onTap: () => Navigator.pushNamed(context, AppRouter.dailyClosing),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick Tools Android aktif lewat notifikasi persisten dan widget homescreen.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
