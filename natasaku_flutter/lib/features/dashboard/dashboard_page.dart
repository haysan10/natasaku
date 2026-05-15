import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/services/android_widget_service.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/budget_period.dart';
import '../../data/models/budget_status.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../shared/widgets/transaction_entry_sheet.dart';
import '../budgeting/budgeting_engine.dart';
import '../notifications/notifications_service.dart';
import '../../shared/widgets/main_shell.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  final NotificationsService _notificationsService = NotificationsService();

  BudgetPeriod? _period;
  List<TransactionModel> _transactions = <TransactionModel>[];
  bool _loading = true;

  double _parseAmount(String raw) {
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    final value = double.tryParse(normalized) ?? 0;
    return value.isFinite ? value : 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationsService.requestPermission();
      _listenToNotifications();
      _checkInitialWidgetAction();
      _listenToWidgetActions();
    });
  }

  Future<void> _checkInitialWidgetAction() async {
    final action = await AndroidWidgetService.getInitialAction();
    if (action != null) {
      _handleAction(action);
    }
  }

  void _listenToWidgetActions() {
    AndroidWidgetService.onWidgetAction.listen((action) {
      if (mounted) _handleAction(action);
    });
  }

  void _listenToNotifications() {
    _notifSubscription = NotificationsService.onActionSelected.listen((action) {
      if (mounted) _handleAction(action);
    });
  }

  void _handleAction(String action) {
    switch (action) {
      case 'action_add_expense':
      case 'action_quick_add':
        _quickAdd(isExpense: true);
      case 'action_add_income':
        _quickAdd(isExpense: false);
      case 'action_check':
        if (_period != null) {
          final today = DateTime.now();
          final remainingDays = BudgetingEngine.calculateRemainingDays(
            today: today,
            periodEnd: _period!.endDate,
          );
          final totalIncome = _transactions
              .where((t) => !t.isExpense)
              .fold<double>(0, (a, b) => a + b.amount);
          final totalExpense = _transactions
              .where((t) => t.isExpense)
              .fold<double>(0, (a, b) => a + b.amount);
          final remainingFund =
              _period!.flexibleFund + totalIncome - totalExpense;

          _checkBeforeBuy(
            remainingFund: remainingFund,
            remainingDays: remainingDays,
            todayExpense: expenseToday(),
          );
        }
      case 'action_open':
        // Just opens the app/dashboard
        break;
      case 'payload_dashboard':
        // Tap on notification body
        break;
    }
  }

  StreamSubscription? _notifSubscription;

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final period = await _repo.loadPeriod();
    final transactions = await _repo.loadTransactions();
    if (!mounted) return;
    setState(() {
      _period = period;
      _transactions = transactions;
      _loading = false;
    });
    await _syncHomeWidget(period: period, transactions: transactions);
  }

  Future<void> _syncHomeWidget({
    required BudgetPeriod? period,
    required List<TransactionModel> transactions,
  }) async {
    final userSettings = await _repo.loadUserSettings();
    await AndroidWidgetService.setQuickToolsNotificationEnabled(
      userSettings.quickToolsNotificationEnabled,
    );

    if (period == null) {
      await AndroidWidgetService.updateHomeWidget(
        dailySafeBudget: 'Rp0',
        dailyStatus: 'Atur dulu',
        periodStatus: 'Belum aktif',
        remainingFund: 'Rp0',
        todayExpense: 'Rp0',
        tomorrowBudget: 'Rp0',
        advice: 'Buka NataSaku lalu atur periode agar hitungan aktif.',
        dailySafeBudgetAmount: 0,
        remainingFundAmount: 0,
        todayExpenseAmount: 0,
      );
      return;
    }

    final today = DateTime.now();
    final remainingDays = BudgetingEngine.calculateRemainingDays(
      today: today,
      periodEnd: period.endDate,
    );
    final totalIncome = transactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final remainingFund = period.flexibleFund + totalIncome - totalExpense;
    final baseDaily = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max<double>(remainingFund, 0),
      remainingDays: remainingDays,
    );
    final safeDaily = BudgetingEngine.applyBudgetMode(
      baseDailyBudget: baseDaily,
      mode: period.mode,
    );
    final todayExpense = transactions
        .where((t) => t.isExpense)
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold<double>(0, (a, b) => a + b.amount);
    final dailyStatus = BudgetingEngine.getDailyBudgetStatus(
      todayExpense: todayExpense,
      dailySafeBudget: safeDaily,
    );
    final periodStatus = BudgetingEngine.getPeriodFundStatus(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );
    final tomorrowBudget = BudgetingEngine.calculateTomorrowSafeBudget(
      remainingFundAfterToday: remainingFund - todayExpense,
      remainingDaysAfterToday: max(remainingDays - 1, 0),
    );
    final adviceText = BudgetingEngine.generateDynamicRecommendation(
      dailyStatus: dailyStatus,
      periodStatus: periodStatus,
    );
    final usage = BudgetingEngine.calculateTodayBudgetUsage(
      todayExpense: todayExpense,
      dailySafeBudget: safeDaily,
    );
    await AndroidWidgetService.updateHomeWidget(
      dailySafeBudget: CurrencyService.formatRupiah(safeDaily),
      dailyStatus: _dailyStatusLabel(dailyStatus),
      periodStatus: _periodStatusLabel(periodStatus),
      remainingFund: CurrencyService.formatRupiah(remainingFund),
      todayExpense: CurrencyService.formatRupiah(todayExpense),
      tomorrowBudget: CurrencyService.formatRupiah(tomorrowBudget),
      advice: adviceText,
      remainingDays: 'Sisa ${max(remainingDays, 0)} hari',
      usagePercent:
          (usage * 100).isFinite ? (usage * 100).round().clamp(0, 100) : 0,
      dailySafeBudgetAmount: safeDaily.round(),
      remainingFundAmount: remainingFund.round(),
      todayExpenseAmount: todayExpense.round(),
    );
  }

  Future<void> _quickAdd({required bool isExpense}) async {
    final amountController = TextEditingController();

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget amountChip(double amount, String label) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context, amount),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense ? 'Catat Pengeluaran' : 'Catat Pemasukan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih nominal cepat atau masukkan nominal khusus di bawah.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      amountChip(10000, 'Rp10.000'),
                      amountChip(20000, 'Rp20.000'),
                      amountChip(50000, 'Rp50.000'),
                      amountChip(100000, 'Rp100.000'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ATAU',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nominal Lain (Rp)',
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    onSubmitted: (value) {
                      final amount = _parseAmount(value);
                      if (amount > 0) Navigator.pop(context, amount);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final amount = _parseAmount(amountController.text);
                        if (amount <= 0) return;
                        Navigator.pop(context, amount);
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openFullTransactionEntry(initialExpense: isExpense);
                      },
                      child: const Text('Buka Form Detail...'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || result <= 0) return;

    // Play system click sound as feedback
    SystemSound.play(SystemSoundType.click);

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: result,
      isExpense: isExpense,
      category: isExpense ? 'Pengeluaran Cepat' : 'Pemasukan Cepat',
    );

    await _repo.addTransaction(transaction);
    await _load();

    if (!mounted) return;
    final remainingBudget =
        max(dailySafeBudgetForToday() - expenseToday(), 0.0);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${isExpense ? '−' : '+'} ${CurrencyService.formatRupiah(result)} dicatat · Sisa jatah ${CurrencyService.formatRupiah(remainingBudget)}',
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Batalkan',
            onPressed: () async {
              await _removeTransaction(transaction.id);
              if (!mounted) return;
              await _load();
            },
          ),
        ),
      );
  }

  double expenseToday() {
    final today = DateTime.now();
    return _transactions
        .where((t) => t.isExpense)
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold<double>(0, (a, b) => a + b.amount);
  }

  double dailySafeBudgetForToday() {
    final period = _period;
    if (period == null) return 0;
    final today = DateTime.now();
    final remainingDays = BudgetingEngine.calculateRemainingDays(
      today: today,
      periodEnd: period.endDate,
    );
    final totalIncome = _transactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final totalExpense = _transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final remainingFund = period.flexibleFund + totalIncome - totalExpense;
    final baseDailySafe = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max<double>(remainingFund, 0),
      remainingDays: remainingDays,
    );
    return BudgetingEngine.applyBudgetMode(
      baseDailyBudget: baseDailySafe,
      mode: period.mode,
    );
  }

  Future<void> _removeTransaction(String id) async {
    final all = await _repo.loadTransactions();
    final filtered = all.where((item) => item.id != id).toList();
    await LocalStorage().saveTransactions(
      filtered
          .map(
            (t) => <String, dynamic>{
              'id': t.id,
              'date': t.date.toIso8601String(),
              'amount': t.amount,
              'isExpense': t.isExpense,
              'note': t.note,
              'category': t.category,
            },
          )
          .toList(),
    );
  }

  Future<void> _openFullTransactionEntry({
    bool initialExpense = true,
    double? initialAmount,
    String? initialCategory,
    String? initialNote,
  }) async {
    final draft = await showTransactionEntrySheet(
      context,
      initialExpense: initialExpense,
      initialAmount: initialAmount,
      initialCategory: initialCategory,
      initialNote: initialNote,
    );
    if (draft == null) return;

    SystemSound.play(SystemSoundType.click);

    await _repo.addTransaction(
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: draft.date,
        amount: draft.amount,
        isExpense: draft.isExpense,
        note: draft.note,
        category: draft.category,
      ),
    );

    await _load();
  }

  Future<void> _addForgotRecord() async {
    final amountController = TextEditingController();
    DateTime pickedDate = DateTime.now().subtract(const Duration(days: 1));

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saya Lupa Catat'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Nominal pengeluaran'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModalState(() => pickedDate = picked);
                      }
                    },
                    child: Text(
                        'Tanggal: ${pickedDate.toLocal().toString().split(' ').first}'),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Simpan Catatan Terlambat'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != true) return;
    final amount = _parseAmount(amountController.text);
    if (amount <= 0) return;

    await _repo.addTransaction(
      TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: pickedDate,
        amount: amount,
        isExpense: true,
        note: 'Saya lupa catat',
      ),
    );

    await _load();
  }

  Future<void> _checkBeforeBuy({
    required double remainingFund,
    required int remainingDays,
    required double todayExpense,
  }) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cek Sebelum Beli'),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Nominal belanja rencana'),
              ),
              TextField(
                controller: noteController,
                decoration:
                    const InputDecoration(labelText: 'Catatan (opsional)'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Simulasikan'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != true) return;
    final plannedExpense = _parseAmount(amountController.text);
    if (plannedExpense <= 0) return;

    final remainingAfterPlan = remainingFund - plannedExpense;
    final safeBudgetAfterPlan = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max<double>(remainingAfterPlan, 0),
      remainingDays: remainingDays,
    );
    final todayExpenseAfterPlan = todayExpense + plannedExpense;

    final statusAfterPlan = BudgetingEngine.getDailyBudgetStatus(
      todayExpense: todayExpenseAfterPlan,
      dailySafeBudget: safeBudgetAfterPlan,
    );
    final periodAfterPlan = BudgetingEngine.getPeriodFundStatus(
      remainingFund: remainingAfterPlan,
      remainingDays: remainingDays,
    );

    final avgExpense = _transactions.where((t) => t.isExpense).isEmpty
        ? todayExpenseAfterPlan
        : _transactions
                .where((t) => t.isExpense)
                .fold<double>(0, (a, b) => a + b.amount) /
            _transactions.where((t) => t.isExpense).length;

    final endingBalance = BudgetingEngine.predictEndingBalance(
      remainingFund: remainingAfterPlan,
      averageDailyExpense: avgExpense,
      remainingDays: remainingDays,
    );

    final runoutDate = BudgetingEngine.predictFundRunoutDate(
      today: DateTime.now(),
      remainingFund: remainingAfterPlan,
      averageDailyExpense: avgExpense,
    );

    final allowed = periodAfterPlan != PeriodFundStatus.danaHabis &&
        statusAfterPlan != DailyBudgetStatus.boros;

    if (!mounted) return;
    final simulation = _SimulationResult(
      note: noteController.text.trim(),
      plannedAmount: plannedExpense,
      allowed: allowed,
      dailyStatus: _dailyStatusLabel(statusAfterPlan),
      periodStatus: _periodStatusLabel(periodAfterPlan),
      recommendation: _dailyRecommendation(statusAfterPlan, periodAfterPlan),
      safeTomorrow: BudgetingEngine.calculateTomorrowSafeBudget(
        remainingFundAfterToday: remainingAfterPlan - todayExpenseAfterPlan,
        remainingDaysAfterToday: max(0, remainingDays - 1),
      ),
      predictedEndingBalance: endingBalance,
      predictedRunoutDate: runoutDate,
    );

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: _SimulationCard(result: simulation),
          ),
        );
      },
    );
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.transactions);
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.reports);
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.savings);
      case 4:
        Navigator.pushReplacementNamed(context, AppRouter.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final period = _period;
    if (period == null) {
      return MainShell(
        index: 0,
        onNavigate: _onNavigate,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Siap atur keuanganmu?',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Atur periode dan dana fleksibel dulu, lalu NataSaku akan menghitung batas aman belanja harianmu secara otomatis.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.setup)
                              .then((_) => _load()),
                      icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                      label: const Text('Mulai Atur Uang'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hanya butuh 30 detik. Bisa diubah kapan saja.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final today = DateTime.now();
    final remainingDays = BudgetingEngine.calculateRemainingDays(
      today: today,
      periodEnd: period.endDate,
    );
    final totalIncome = _transactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final totalExpense = _transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final remainingFundRaw = period.flexibleFund + totalIncome - totalExpense;
    final double remainingFund =
        remainingFundRaw.isFinite ? remainingFundRaw : 0.0;

    final baseDailySafe = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max<double>(remainingFund, 0),
      remainingDays: remainingDays,
    );
    final dailySafe = BudgetingEngine.applyBudgetMode(
      baseDailyBudget: baseDailySafe,
      mode: period.mode,
    );

    final todayExpense = _transactions
        .where((t) => t.isExpense)
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold<double>(0, (a, b) => a + b.amount);

    final todayIncome = _transactions
        .where((t) => !t.isExpense)
        .where((t) =>
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold<double>(0, (a, b) => a + b.amount);

    final usage = BudgetingEngine.calculateTodayBudgetUsage(
        todayExpense: todayExpense, dailySafeBudget: dailySafe);
    final dailyStatus = BudgetingEngine.getDailyBudgetStatus(
        todayExpense: todayExpense, dailySafeBudget: dailySafe);
    final periodStatus = BudgetingEngine.getPeriodFundStatus(
        remainingFund: remainingFund, remainingDays: remainingDays);
    final tomorrowBudget = BudgetingEngine.calculateTomorrowSafeBudget(
      remainingFundAfterToday: remainingFund - todayExpense,
      remainingDaysAfterToday: max(remainingDays - 1, 0),
    );
    final todayDiff = dailySafe - todayExpense;
    final todayDiffLabel = todayExpense <= 0
        ? 'Belum ada pengeluaran'
        : todayDiff >= 0
            ? 'Sisa ${CurrencyService.formatRupiah(todayDiff)}'
            : 'Lewat ${CurrencyService.formatRupiah(todayDiff.abs())}';
    final recommendationText = today.isBefore(period.startDate)
        ? 'Periode belum dimulai. Kamu bisa siapkan catatan dulu, lalu mulai saat periode aktif.'
        : remainingDays <= 0
            ? 'Periode ini sudah selesai. Atur periode baru agar batas aman harian kembali akurat.'
            : _dailyRecommendation(dailyStatus, periodStatus);

    return MainShell(
      index: 0,
      onNavigate: _onNavigate,
      onFabPressed: () => _quickAdd(isExpense: true),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: [
              _DashboardHeader(
                subtitle: _greetingByTime(),
                onSettingsTap: () =>
                    Navigator.pushNamed(context, AppRouter.settings)
                        .then((_) => _load()),
              ),
              const SizedBox(height: 20),
              _HeroAllowanceCard(
                title: 'Batas Aman Hari Ini',
                dailySafeBudget: CurrencyService.formatRupiah(dailySafe),
                remainingDayLabel: 'Sisa ${max(remainingDays, 0)} hari',
                remainingFundLabel:
                    'Sisa dana ${CurrencyService.formatRupiah(remainingFund)}',
                statusLabel: _dailyStatusLabel(dailyStatus),
                statusColor: _dailyStatusColor(dailyStatus),
                statusAdvice: _dailyStatusMessage(dailyStatus),
                tip:
                    'Tip: angka besar ini adalah batas aman belanja kamu hari ini.',
                usagePercent: usage.isFinite ? usage.clamp(0.0, 1.5) : 0.0,
              ),
              const SizedBox(height: 16),
              _CompactSummaryCard(
                items: [
                  _SummaryItem(
                    label: 'Keluar Hari Ini',
                    value: CurrencyService.formatRupiah(todayExpense),
                    color: todayExpense > 0 ? AppTheme.error : null,
                  ),
                  _SummaryItem(
                    label: 'Masuk Hari Ini',
                    value: CurrencyService.formatRupiah(todayIncome),
                    color: todayIncome > 0 ? AppTheme.success : null,
                  ),
                  _SummaryItem(
                    label: 'Jatah Besok',
                    value: CurrencyService.formatRupiah(tomorrowBudget),
                    emphasized: true,
                  ),
                  _SummaryItem(
                    label: 'Pemakaian',
                    value:
                        '${(usage * 100).isFinite ? (usage * 100).toStringAsFixed(0) : '0'}%',
                    subdued: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RecommendationCard(
                title: 'Artinya untuk hari ini',
                recommendation: recommendationText,
                secondaryText:
                    'Status: ${_dailyStatusLabel(dailyStatus)}. $todayDiffLabel.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi — cek jatah hari ini';
    if (hour < 15) return 'Selamat siang — cek sisa jatah';
    if (hour < 18) return 'Selamat sore — bagaimana belanja hari ini?';
    return 'Selamat malam — sudah catat semua?';
  }

  String _dailyStatusLabel(DailyBudgetStatus status) {
    switch (status) {
      case DailyBudgetStatus.belumAdaPengeluaran:
        return 'Belum Ada Pengeluaran';
      case DailyBudgetStatus.aman:
        return 'Aman';
      case DailyBudgetStatus.mendekatiBatas:
        return 'Mendekati Batas';
      case DailyBudgetStatus.melebihiSedikit:
        return 'Melebihi Sedikit';
      case DailyBudgetStatus.boros:
        return 'Boros';
    }
  }

  String _dailyStatusMessage(DailyBudgetStatus status) {
    switch (status) {
      case DailyBudgetStatus.belumAdaPengeluaran:
        return 'Kamu masih punya ruang penuh hari ini.';
      case DailyBudgetStatus.aman:
        return 'Pengeluaranmu masih aman hari ini.';
      case DailyBudgetStatus.mendekatiBatas:
        return 'Hati-hati, jatah hari ini hampir habis.';
      case DailyBudgetStatus.melebihiSedikit:
        return 'Kamu melewati batas hari ini sedikit.';
      case DailyBudgetStatus.boros:
        return 'Pengeluaran hari ini sudah jauh melewati batas.';
    }
  }

  String _dailyRecommendation(
    DailyBudgetStatus dailyStatus,
    PeriodFundStatus periodStatus,
  ) {
    final mainText = switch (dailyStatus) {
      DailyBudgetStatus.belumAdaPengeluaran =>
        'Catat transaksi pertama agar prediksi besok lebih akurat.',
      DailyBudgetStatus.aman => 'Pertahankan ritme hari ini.',
      DailyBudgetStatus.mendekatiBatas => 'Cek dulu sebelum belanja lagi.',
      DailyBudgetStatus.melebihiSedikit =>
        'Kurangi sedikit pengeluaran besok agar tetap stabil.',
      DailyBudgetStatus.boros =>
        'Aktifkan Mode Hemat atau kurangi pengeluaran beberapa hari ke depan.',
    };

    if (periodStatus == PeriodFundStatus.kritis ||
        periodStatus == PeriodFundStatus.danaHabis) {
      return '$mainText Sisa dana periode juga sudah ketat, jadi fokus ke kebutuhan utama dulu.';
    }

    return mainText;
  }

  String _periodStatusLabel(PeriodFundStatus status) {
    switch (status) {
      case PeriodFundStatus.aman:
        return 'Aman';
      case PeriodFundStatus.waspada:
        return 'Waspada';
      case PeriodFundStatus.kritis:
        return 'Kritis';
      case PeriodFundStatus.danaHabis:
        return 'Dana Habis';
      case PeriodFundStatus.periodeSelesai:
        return 'Periode Selesai';
    }
  }

  Color _dailyStatusColor(DailyBudgetStatus status) {
    switch (status) {
      case DailyBudgetStatus.belumAdaPengeluaran:
        return AppTheme.textSecondary;
      case DailyBudgetStatus.aman:
        return AppTheme.success;
      case DailyBudgetStatus.mendekatiBatas:
        return AppTheme.warning;
      case DailyBudgetStatus.melebihiSedikit:
        return AppTheme.warning;
      case DailyBudgetStatus.boros:
        return AppTheme.error;
    }
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.subtitle,
    this.onSettingsTap,
  });

  final String subtitle;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/branding/logo-natasaku-mark.png',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NataSaku',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
          ),
          child: IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_rounded),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Pengaturan',
          ),
        ),
      ],
    );
  }
}

class _HeroAllowanceCard extends StatelessWidget {
  const _HeroAllowanceCard({
    required this.title,
    required this.dailySafeBudget,
    required this.remainingDayLabel,
    required this.remainingFundLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.statusAdvice,
    required this.tip,
    this.usagePercent = 0.0,
  });

  final String title;
  final String dailySafeBudget;
  final String remainingDayLabel;
  final String remainingFundLabel;
  final String statusLabel;
  final Color statusColor;
  final String statusAdvice;
  final String tip;
  final double usagePercent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF134E4A), const Color(0xFF0F766E)]
              : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        remainingDayLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        dailySafeBudget,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (usagePercent > 0)
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: usagePercent.clamp(0.0, 1.0),
                              strokeWidth: 5,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                usagePercent > 1.0
                                    ? const Color(0xFFFF6B6B)
                                    : usagePercent > 0.7
                                        ? const Color(0xFFFFD93D)
                                        : Colors.white,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                            Text(
                              '${(usagePercent * 100).clamp(0, 999).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  statusAdvice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.2), height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remainingFundLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.subdued = false,
    this.color,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool subdued;
  final Color? color;
}

class _CompactSummaryCard extends StatelessWidget {
  const _CompactSummaryCard({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan Singkat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: item.emphasized ? 16 : 15,
                          fontWeight: item.emphasized
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: item.color ??
                              (item.subdued
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.recommendation,
    required this.secondaryText,
  });

  final String title;
  final String recommendation;
  final String secondaryText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondaryText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulationResult {
  const _SimulationResult({
    required this.note,
    required this.plannedAmount,
    required this.allowed,
    required this.dailyStatus,
    required this.periodStatus,
    required this.recommendation,
    required this.safeTomorrow,
    required this.predictedEndingBalance,
    required this.predictedRunoutDate,
  });

  final String note;
  final double plannedAmount;
  final bool allowed;
  final String dailyStatus;
  final String periodStatus;
  final String recommendation;
  final double safeTomorrow;
  final double predictedEndingBalance;
  final DateTime? predictedRunoutDate;
}

class _SimulationCard extends StatelessWidget {
  const _SimulationCard({required this.result});

  final _SimulationResult result;

  @override
  Widget build(BuildContext context) {
    final decisionText = result.allowed ? 'Boleh belanja' : 'Sebaiknya tunda';
    final decisionColor = result.allowed ? AppTheme.success : AppTheme.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Simulasi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: decisionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: decisionColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                result.allowed
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: decisionColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                decisionText,
                style: TextStyle(
                  color: decisionColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rencana belanja: ${CurrencyService.formatRupiah(result.plannedAmount)}',
                style: TextStyle(
                  color: decisionColor.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SimulationInfoTile(
          label: 'Status harian setelah ini',
          value: result.dailyStatus,
          icon: Icons.today,
        ),
        _SimulationInfoTile(
          label: 'Status periode setelah ini',
          value: result.periodStatus,
          icon: Icons.date_range,
        ),
        _SimulationInfoTile(
          label: 'Jatah aman besok',
          value: CurrencyService.formatRupiah(result.safeTomorrow),
          icon: Icons.next_plan_outlined,
        ),
        _SimulationInfoTile(
          label: 'Sisa akhir periode',
          value: CurrencyService.formatRupiah(result.predictedEndingBalance),
          icon: Icons.account_balance_rounded,
          isLast: true,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            result.recommendation,
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _SimulationInfoTile extends StatelessWidget {
  const _SimulationInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              height: 1),
      ],
    );
  }
}
