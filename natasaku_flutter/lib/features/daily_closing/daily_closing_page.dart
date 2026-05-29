import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/daily_closing.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/saving_goal.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/models/in_app_notification.dart';
import '../budgeting/budgeting_engine.dart';

enum CarryOverStrategy {
  savings,       // Surplus: Simpan ke Celengan
  tomorrow,      // Surplus: Jatah besok
  spread,        // Deficit: Sebarkan ke sisa periode
  cutNextDays,   // Deficit: Potong jatah hari berikutnya
}

class DailyClosingPage extends StatefulWidget {
  const DailyClosingPage({super.key});

  @override
  State<DailyClosingPage> createState() => _DailyClosingPageState();
}

class _DailyClosingPageState extends State<DailyClosingPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  final TextEditingController _noteController = TextEditingController();

  bool _loading = true;
  bool _hasPeriod = true;
  int _todayExpense = 0;
  int _todayIncome = 0;
  int _carryOver = 0;
  CarryOverStrategy? _strategy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final period = await _repo.loadPeriod();
      final txs = await _repo.loadTransactions();
      final now = DateTime.now();

      final todayExpense = txs
          .where((t) => t.isExpense)
          .where((t) =>
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day)
          .fold(0, (a, b) => a + b.amount);

      final todayIncome = txs
          .where((t) => !t.isExpense)
          .where((t) =>
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day)
          .fold(0, (a, b) => a + b.amount);

      var carryOver = 0;
      if (period != null) {
        final remainingDays = max(1, period.endDate.difference(now).inDays + 1);
        final totalIncome = txs
            .where((t) => !t.isExpense)
            .fold(0, (a, b) => a + b.amount);
        final totalExpense =
            txs.where((t) => t.isExpense).fold(0, (a, b) => a + b.amount);
        final remainingFund = BudgetingEngine.calculateRemainingFund(
          flexibleFund: period.flexibleFund,
          fixedExpenses: period.fixedExpenses,
          monthlySavingAllocation: period.monthlySavingAllocation,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          incomeAmounts: txs.where((t) => !t.isExpense).map((t) => t.amount),
        );
        final safeDaily = BudgetingEngine.calculateDailySafeBudget(
          remainingFund: remainingFund,
          remainingDays: remainingDays,
        );
        carryOver = safeDaily - todayExpense;
      }

      if (!mounted) return;
      setState(() {
        _hasPeriod = period != null;
        _todayExpense = todayExpense;
        _todayIncome = todayIncome;
        _carryOver = carryOver;
        _loading = false;
        if (carryOver > 0) {
          _strategy = CarryOverStrategy.savings;
        } else if (carryOver < 0) {
          _strategy = CarryOverStrategy.spread;
        }
      });
    } catch (e, stack) {
      debugPrint('DEBUG DAILY CLOSING LOAD ERROR: $e');
      debugPrint(stack.toString());
    }
  }

  Future<void> _saveClosing() async {
    final now = DateTime.now();

    // 1. Simpan Daily Closing log
    await _repo.addDailyClosing(
      DailyClosing(
        date: now,
        finalExpense: _todayExpense,
        carryOver: _carryOver,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );

    // Reward XP (+50 XP) & In-App Notification
    final currentXp = await _repo.getXp();
    final newXp = currentXp + 50;
    await _repo.saveXp(newXp);

    final currentLevel = (currentXp ~/ 100) + 1;
    final newLevel = (newXp ~/ 100) + 1;

    await _repo.addInAppNotification(
      InAppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'Tutup Harian! 📝 +50 XP',
        message: 'Bagus! Kamu berhasil menyelesaikan tutup harian hari ini.',
        date: DateTime.now(),
        type: 'info',
      ),
    );

    if (newLevel > currentLevel) {
      await _repo.addInAppNotification(
        InAppNotification(
          id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
          title: 'Naik Level! 🌟 Level $newLevel',
          message: 'Selamat! Finansialmu semakin terarah. Kamu naik ke level baru!',
          date: DateTime.now(),
          type: 'level',
        ),
      );
    }

    String message = 'Daily Closing tersimpan';

    if (_carryOver > 0) {
      if (_strategy == CarryOverStrategy.savings) {
        // Tambahkan transaksi Menabung agar terdebit dari anggaran periode berjalan
        final tx = TransactionModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          date: now,
          amount: _carryOver,
          isExpense: true,
          category: 'Menabung',
          note: 'Celengan Harian (Daily Closing) 🚀',
        );
        await _repo.addTransaction(tx);

        // Tambah alokasi celengan otomatis
        await _repo.addAutoSavingAllocation(
          amount: _carryOver,
          date: now,
          source: 'daily_closing',
        );

        // Tambahkan saldo ke tujuan menabung utama jika ada
        final activeGoal = await _repo.loadSavingGoal();
        if (activeGoal != null) {
          final updatedGoal = SavingGoal(
            id: activeGoal.id,
            name: activeGoal.name,
            targetAmount: activeGoal.targetAmount,
            currentAmount: activeGoal.currentAmount + _carryOver,
            targetDate: activeGoal.targetDate,
          );
          await _repo.saveSavingGoal(updatedGoal);
        }
        message = 'Daily Closing tersimpan dan ${CurrencyService.formatRupiah(_carryOver)} dialokasikan ke Celengan.';
      } else if (_strategy == CarryOverStrategy.tomorrow) {
        // Jatah Besok
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
        await _repo.saveDailyBudgetAdjustment(_carryOver);
        await _repo.saveDailyBudgetAdjustmentDate(tomorrowStr);
        message = 'Daily Closing tersimpan. Sisa ${CurrencyService.formatRupiah(_carryOver)} ditambahkan ke jatah besok.';
      }
    } else if (_carryOver < 0) {
      if (_strategy == CarryOverStrategy.spread) {
        // Sebarkan ke Sisa Periode
        await _repo.saveDailyBudgetAdjustment(0);
        await _repo.saveDailyBudgetAdjustmentDate(null);
        message = 'Daily Closing tersimpan. Defisit disebarkan ke sisa periode.';
      } else if (_strategy == CarryOverStrategy.cutNextDays) {
        // Potong Jatah Hari Berikutnya
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
        await _repo.saveDailyBudgetAdjustment(_carryOver);
        await _repo.saveDailyBudgetAdjustmentDate(tomorrowStr);
        message = 'Daily Closing tersimpan. Jatah belanja besok akan dipotong untuk melunasi defisit.';
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  Widget _buildStrategyCard({
    required String title,
    required String description,
    required IconData icon,
    required bool selected,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final activeBorderColor = primaryColor;
    final inactiveBorderColor = isDark ? const Color(0xFF2A4240) : AppColors.borderLight;
    final activeBgColor = primaryColor.withValues(alpha: 0.08);
    final inactiveBgColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF162826) : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? activeBgColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeBorderColor : inactiveBorderColor,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? primaryColor : (isDark ? const Color(0xFF1E2E2C) : AppColors.surfaceVariantLight),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? (isDark ? const Color(0xFF003730) : Colors.white) : (isDark ? const Color(0xFF99F6E4) : AppColors.textSecondaryLight),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: selected ? primaryColor : (isDark ? const Color(0xFFE0F2F0) : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Closing')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text('Ringkasan Hari Ini',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Tutup hari dengan cepat agar jatah besok lebih akurat.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (!_hasPeriod)
            const Card(
              child: ListTile(
                title: Text('Info'),
                subtitle:
                    Text('Setup periode belum ada, carry-over dihitung 0.'),
              ),
            ),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkCardGradient
                    : const LinearGradient(
                        colors: [AppColors.surfaceVariantLight, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pemasukan Hari Ini',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        CurrencyService.formatRupiah(_todayIncome),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengeluaran Hari Ini',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        CurrencyService.formatRupiah(_todayExpense),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _carryOver < 0 ? 'Defisit Hari Ini' : 'Sisa Jatah Hari Ini',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        CurrencyService.formatRupiah(_carryOver.abs()),
                        style: TextStyle(
                          color: _carryOver < 0 ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_carryOver > 0) ...[
            const SizedBox(height: 16),
            const Text(
              'Pilih Alokasi Sisa Jatah Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStrategyCard(
              title: 'Simpan ke Celengan',
              description: 'Masukkan sisa uang hari ini ke tabungan aktif untuk masa depan.',
              icon: Icons.savings_outlined,
              selected: _strategy == CarryOverStrategy.savings,
              context: context,
              onTap: () => setState(() => _strategy = CarryOverStrategy.savings),
            ),
            _buildStrategyCard(
              title: 'Tambahkan ke Jatah Besok',
              description: 'Gunakan sisa uang hari ini untuk jajan lebih banyak besok.',
              icon: Icons.next_plan_outlined,
              selected: _strategy == CarryOverStrategy.tomorrow,
              context: context,
              onTap: () => setState(() => _strategy = CarryOverStrategy.tomorrow),
            ),
          ] else if (_carryOver < 0) ...[
            const SizedBox(height: 16),
            const Text(
              'Pilih Penyesuaian Defisit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStrategyCard(
              title: 'Sebarkan ke Sisa Periode',
              description: 'Beban defisit dibagi rata ke sisa hari. Jatah harian berkurang sedikit.',
              icon: Icons.balance_outlined,
              selected: _strategy == CarryOverStrategy.spread,
              context: context,
              onTap: () => setState(() => _strategy = CarryOverStrategy.spread),
            ),
            _buildStrategyCard(
              title: 'Potong Jatah Hari Berikutnya',
              description: 'Jatah besok (dan lusa jika perlu) dipotong hingga Rp0 sampai defisit lunas.',
              icon: Icons.trending_down_outlined,
              selected: _strategy == CarryOverStrategy.cutNextDays,
              context: context,
              onTap: () => setState(() => _strategy = CarryOverStrategy.cutNextDays),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration:
                const InputDecoration(labelText: 'Catatan hari ini (opsional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _saveClosing,
              child: const Text('Simpan Daily Closing')),
        ],
      ),
    );
  }
}
