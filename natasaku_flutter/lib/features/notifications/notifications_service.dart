import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_status.dart';
import '../../data/repositories/budget_repository.dart';
import '../budgeting/budgeting_engine.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (response.actionId == 'action_quick_expense_bg' &&
      response.input != null) {
    final input = response.input!.trim();
    if (input.isEmpty) return;

    final amount =
        int.tryParse(input.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amount <= 0) return;

    final repo = BudgetRepository(LocalStorage());
    await repo.addTransaction(TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      isExpense: true,
      note: 'Catat Cepat (Notifikasi)',
      category: 'Lainnya',
    ));

    final notifService = NotificationsService();
    await notifService.initialize();
    await notifService.refreshPersistentNotification(playSuccessSound: true);
  }
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _persistentNotifId = 9001;
  static const int _dailyReminderId = 9002;
  static const String _channelId = 'natasaku_persistent';
  static const String _channelName = 'NataSaku Status';
  static const String _reminderChannelId = 'natasaku_reminder';
  static const String _reminderChannelName = 'Pengingat Harian';
  static const String _eventChannelId = 'natasaku_events';
  static const String _eventChannelName = 'Event Penting NataSaku';

  static bool _initialized = false;
  static bool _timezoneInitialized = false;
  static final _actionStreamController = StreamController<String>.broadcast();
  static Stream<String> get onActionSelected => _actionStreamController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId != null) {
          _actionStreamController.add(response.actionId!);
        } else if (response.payload != null) {
          _actionStreamController.add('payload_${response.payload}');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create persistent channel
    const persistentChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Menampilkan batas aman harian NataSaku',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    // Create reminder channel
    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: 'Pengingat harian catat pengeluaran',
      importance: Importance.high,
    );
    const eventChannel = AndroidNotificationChannel(
      _eventChannelId,
      _eventChannelName,
      description: 'Sound hanya untuk transaksi, warning, dan export selesai',
      importance: Importance.high,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(persistentChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);
    await androidPlugin?.createNotificationChannel(eventChannel);

    _initialized = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {
      // Ignore in environments where native plugin bootstrapping is unavailable.
    }
  }

  /// Tampilkan Notifikasi Jatah Harian NataSaku (Ongoing/Persistent)
  Future<void> showDailyAllowanceNotification({
    required int sisaJatah,
    required String status, // 'aman', 'waspada', 'over', 'loading', 'error'
    required bool hideBalance,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await initialize();

    // Tentukan warna aksen, status text, dan advice text berdasarkan state
    Color accentColor;
    String statusText;
    String adviceText;
    String sisaJatahStr = hideBalance ? 'Rp••••••' : CurrencyService.formatRupiah(sisaJatah);

    switch (status.toLowerCase()) {
      case 'aman':
        accentColor = const Color(0xFF0D9488); // Teal
        statusText = 'Aman';
        adviceText = 'Masih aman untuk hari ini 💚';
        break;
      case 'waspada':
        accentColor = const Color(0xFFF59E0B); // Oranye
        statusText = 'Waspada';
        adviceText = 'Hampir sampai batasmu hari ini. Pertimbangkan dua kali ya 🙏';
        break;
      case 'over':
        accentColor = const Color(0xFFEF4444); // Merah
        statusText = 'Over';
        adviceText = 'Hari ini sudah melebihi rencana. Tidak apa-apa, besok mulai baru! 💪';
        break;
      case 'loading':
        accentColor = const Color(0xFF64748B); // Abu-abu
        statusText = 'Updating';
        adviceText = 'Memperbarui data jatah harian... ⏳';
        sisaJatahStr = 'Rp...';
        break;
      case 'error':
      default:
        accentColor = const Color(0xFFEF4444); // Merah
        statusText = 'Error';
        adviceText = 'Gagal memperbarui jatah harian ❌';
        break;
    }

    final collapsedText = 'Sisa jatah: $sisaJatahStr • $statusText';
    final expandedText = 'Sisa jatah hari ini: $sisaJatahStr\n$adviceText';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Menampilkan batas aman harian NataSaku',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      showWhen: true, // Menampilkan timestamp update
      color: accentColor,
      styleInformation: BigTextStyleInformation(
        expandedText,
        contentTitle: 'NataSaku',
        summaryText: 'Jatah Harian',
      ),
      ticker: 'NataSaku - $collapsedText',
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_jajan',
          'Catat Jajan',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'action_secure',
          'Amankan Sisa',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'action_budget',
          'Budget',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      _persistentNotifId,
      'NataSaku',
      collapsedText,
      NotificationDetails(android: androidDetails),
      payload: 'dashboard',
    );
  }

  /// Update persistent notification with latest data.
  Future<void> updateDailyAllowanceNotification({
    required int sisaJatah,
    required String status,
    required bool hideBalance,
  }) async {
    await showDailyAllowanceNotification(
      sisaJatah: sisaJatah,
      status: status,
      hideBalance: hideBalance,
    );
  }

  Future<void> refreshPersistentNotification(
      {bool playSuccessSound = false}) async {
    final repo = BudgetRepository(LocalStorage());
    final period = await repo.loadPeriod();
    if (period == null) return;

    final tx = await repo.loadTransactions();
    final expenses = tx.where((t) => t.isExpense).toList();
    final incomes = tx.where((t) => !t.isExpense).toList();

    final totalExpense = expenses.fold(0, (a, b) => a + b.amount);
    final totalIncome = incomes.fold(0, (a, b) => a + b.amount);
    final remainingFund = period.flexibleFund + totalIncome - totalExpense;

    final today = DateTime.now();
    final remainingDays = BudgetingEngine.calculateRemainingDays(
      today: today,
      periodEnd: period.endDate,
    );

    final baseDailySafe = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );

    final dailySafe = BudgetingEngine.applyBudgetMode(
      baseDailyBudget: baseDailySafe,
      mode: period.mode,
    );

    final todayExpense = expenses
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0, (a, b) => a + b.amount);

    final dailyStatus = BudgetingEngine.getDailyBudgetStatus(
      todayExpense: todayExpense,
      dailySafeBudget: dailySafe,
    );

    final prefs = await SharedPreferences.getInstance();
    final hideBalance = prefs.getBool(AppConstants.hideBalanceKey) ?? false;

    // Tentukan status string untuk showDailyAllowanceNotification
    String statusStr = 'aman';
    if (dailyStatus == DailyBudgetStatus.mendekatiBatas) {
      statusStr = 'waspada';
    } else if (dailyStatus == DailyBudgetStatus.melebihiSedikit ||
               dailyStatus == DailyBudgetStatus.boros) {
      statusStr = 'over';
    }

    final sisa = max(dailySafe - todayExpense, 0);

    await showDailyAllowanceNotification(
      sisaJatah: sisa,
      status: statusStr,
      hideBalance: hideBalance,
    );

    // Near limit warning
    final usage = BudgetingEngine.calculateTodayBudgetUsage(
      todayExpense: todayExpense,
      dailySafeBudget: dailySafe,
    );
    if (usage >= 0.8 && !playSuccessSound) {
      await _plugin.show(
        9004,
        '⚠️ Hampir Batas Harian',
        'Kamu sudah memakai ${(usage * 100).toStringAsFixed(0)}% batas harianmu. Simpan sisanya ya! 🙏',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _eventChannelId,
            _eventChannelName,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }

    if (playSuccessSound) {
      final remainingToday =
          max(dailySafe - todayExpense, 0);
      await _plugin.show(
        9003,
        '✔️ Tersimpan',
        'Sisa jatah hari ini: ${CurrencyService.formatRupiah(remainingToday)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _eventChannelId,
            _eventChannelName,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            timeoutAfter: 4000,
          ),
        ),
      );
    }
  }

  Future<void> showExportCompleteNotification({required String fileName}) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await initialize();
    await _plugin.show(
      9005,
      'Laporan berhasil diekspor',
      fileName,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _eventChannelId,
          _eventChannelName,
          channelDescription:
              'Sound hanya untuk transaksi, warning, dan export selesai',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          autoCancel: true,
          timeoutAfter: 5000,
        ),
      ),
      payload: 'reports',
    );
  }

  /// Schedule a daily reminder notification at the given time.
  Future<void> scheduleDailyReminder({
    required bool enabled,
    required String timeHHmm,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await initialize();

    // Cancel existing reminder
    await _plugin.cancel(_dailyReminderId);

    if (!enabled || timeHHmm.isEmpty) return;

    final parts = timeHHmm.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    if (!_timezoneInitialized) {
      tz.initializeTimeZones();
      _timezoneInitialized = true;
    }

    const androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: 'Pengingat harian catat pengeluaran',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        'Yuk cek pengeluaran hari ini dan catat yang belum masuk. Tutup hari dengan tenang! 🌙',
        contentTitle: '🌙 Tutup hari dengan tenang',
        summaryText: 'NataSaku Reminder',
      ),
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      '🌙 Tutup hari dengan tenang',
      'Yuk cek pengeluaran hari ini dan catat yang belum masuk. Tutup hari dengan tenang! 🌙',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: androidDetails,
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'reminder',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancel the persistent notification.
  Future<void> cancelPersistentNotification() async {
    await _plugin.cancel(_persistentNotifId);
  }
}
