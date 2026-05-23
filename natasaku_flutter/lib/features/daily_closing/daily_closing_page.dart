import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/daily_closing.dart';
import '../../data/repositories/budget_repository.dart';
import '../budgeting/budgeting_engine.dart';

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
      final remainingFund = period.flexibleFund + totalIncome - totalExpense;
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
    });
  }

  Future<void> _saveClosing() async {
    final now = DateTime.now();
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
    final settings = await _repo.loadUserSettings();
    if (settings.autoSavingEnabled && _carryOver > 0) {
      await _repo.addAutoSavingAllocation(
        amount: _carryOver,
        date: now,
        source: 'daily_closing',
      );
    }

    if (!mounted) return;
    final message = settings.autoSavingEnabled && _carryOver > 0
        ? 'Daily Closing tersimpan dan ${CurrencyService.formatRupiah(_carryOver)} masuk Auto-Celengan.'
        : 'Daily Closing tersimpan';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          const SizedBox(height: 12),
          if (!_hasPeriod)
            const Card(
              child: ListTile(
                title: Text('Info'),
                subtitle:
                    Text('Setup periode belum ada, carry-over dihitung 0.'),
              ),
            ),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: const Text('Pengeluaran Hari Ini'),
              subtitle: Text(CurrencyService.formatRupiah(_todayExpense)),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: const Text('Pemasukan Hari Ini'),
              subtitle: Text(CurrencyService.formatRupiah(_todayIncome)),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: const Text('Sisa / Kelebihan Jatah Hari Ini'),
              subtitle: Text(
                CurrencyService.formatRupiah(_carryOver),
                style: TextStyle(
                  color: _carryOver < 0 ? AppTheme.error : AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextField(
            controller: _noteController,
            decoration:
                const InputDecoration(labelText: 'Catatan hari ini (opsional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _saveClosing,
              child: const Text('Simpan Daily Closing')),
        ],
      ),
    );
  }
}
