import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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
        double.tryParse(input.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
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

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(persistentChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);

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

  /// Show persistent notification in the notification bar.
  /// This notification stays until manually dismissed or updated.
  Future<void> showPersistentNotification({
    required String dailySafeBudget,
    required String dailyStatus,
    required String remainingFund,
    required String advice,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await initialize();

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
      showWhen: false,
      styleInformation: BigTextStyleInformation(
        'Status: $dailyStatus\nSisa Dana: $remainingFund\n$advice',
        contentTitle: 'Batas Aman: $dailySafeBudget',
        summaryText: 'NataSaku',
      ),
      ticker: 'NataSaku - $dailySafeBudget',
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'action_quick_expense_bg',
          '⚡ Ketik...',
          showsUserInterface: false,
          inputs: [
            AndroidNotificationActionInput(
              label: 'Rp...',
            ),
          ],
        ),
        const AndroidNotificationAction(
          'action_add_expense',
          '📝 Detail',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'action_check',
          '🛍️ Cek',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      _persistentNotifId,
      'Batas Aman Hari Ini: $dailySafeBudget',
      'Status: $dailyStatus · Sisa Dana: $remainingFund',
      NotificationDetails(android: androidDetails),
      payload: 'dashboard',
    );
  }

  /// Update persistent notification with latest data.
  Future<void> updatePersistentNotification({
    required String dailySafeBudget,
    required String dailyStatus,
    required String remainingFund,
    required String advice,
  }) async {
    await showPersistentNotification(
      dailySafeBudget: dailySafeBudget,
      dailyStatus: dailyStatus,
      remainingFund: remainingFund,
      advice: advice,
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

    final totalExpense = expenses.fold<double>(0, (a, b) => a + b.amount);
    final totalIncome = incomes.fold<double>(0, (a, b) => a + b.amount);
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
        .fold<double>(0, (a, b) => a + b.amount);

    final dailyStatus = BudgetingEngine.getDailyBudgetStatus(
      todayExpense: todayExpense,
      dailySafeBudget: dailySafe,
    );

    final periodStatus = BudgetingEngine.getPeriodFundStatus(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );

    final adviceText = BudgetingEngine.generateDynamicRecommendation(
      dailyStatus: dailyStatus,
      periodStatus: periodStatus,
    );

    await showPersistentNotification(
      dailySafeBudget: CurrencyService.formatRupiah(dailySafe),
      dailyStatus: _dailyStatusLabel(dailyStatus),
      remainingFund: CurrencyService.formatRupiah(remainingFund),
      advice:
          playSuccessSound ? '✔️ Catatan berhasil ditambahkan!' : adviceText,
    );

    // Near limit warning
    final usage = BudgetingEngine.calculateTodayBudgetUsage(
      todayExpense: todayExpense,
      dailySafeBudget: dailySafe,
    );
    if (usage >= 0.8 && !playSuccessSound) {
      await _plugin.show(
        9004,
        '⚠️ Awas Mendekati Batas',
        'Kamu sudah pakai ${(usage * 100).toStringAsFixed(0)}% jatah hari ini. Hati-hati ya!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'natasaku_alerts',
            'NataSaku Alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }

    if (playSuccessSound) {
      final remainingToday =
          (dailySafe - todayExpense).clamp(0.0, double.infinity);
      await _plugin.show(
        9003,
        '✔️ Tersimpan',
        'Sisa jatah hari ini: ${CurrencyService.formatRupiah(remainingToday)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'natasaku_alerts',
            'NataSaku Alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            timeoutAfter: 4000,
          ),
        ),
      );
    }
  }

  String _dailyStatusLabel(DailyBudgetStatus status) {
    switch (status) {
      case DailyBudgetStatus.belumAdaPengeluaran:
        return 'Belum Ada Pengeluaran';
      case DailyBudgetStatus.aman:
        return 'Aman Terkendali';
      case DailyBudgetStatus.mendekatiBatas:
        return 'Mendekati Batas';
      case DailyBudgetStatus.melebihiSedikit:
        return 'Melebihi Sedikit';
      case DailyBudgetStatus.boros:
        return 'Boros';
    }
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
        'Jangan lupa cek sisa jatahmu hari ini dan catat pengeluaran yang belum masuk ya. Tutup hari dengan tenang!',
        contentTitle: '🌙 Waktunya cek pengeluaran hari ini',
        summaryText: 'NataSaku Reminder',
      ),
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      '🌙 Waktunya cek pengeluaran',
      'Jangan lupa cek sisa jatahmu hari ini.',
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
