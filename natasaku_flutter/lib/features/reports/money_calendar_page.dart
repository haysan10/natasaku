import 'package:flutter/material.dart';

import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';

class MoneyCalendarPage extends StatefulWidget {
  const MoneyCalendarPage({super.key});

  @override
  State<MoneyCalendarPage> createState() => _MoneyCalendarPageState();
}

class _MoneyCalendarPageState extends State<MoneyCalendarPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());

  bool _loading = true;
  DateTime _selected = DateTime.now();
  List<TransactionModel> _transactions = <TransactionModel>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tx = await _repo.loadTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = tx;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dayItems = _transactions
        .where((t) =>
            t.date.year == _selected.year &&
            t.date.month == _selected.month &&
            t.date.day == _selected.day)
        .toList();
    final expense = dayItems
        .where((t) => t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);
    final income = dayItems
        .where((t) => !t.isExpense)
        .fold<double>(0, (a, b) => a + b.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Uang')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          CalendarDatePicker(
            initialDate: _selected,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            onDateChanged: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Ringkasan Tanggal Terpilih'),
              subtitle: Text(_selected.toIso8601String().split('T').first),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Pengeluaran'),
              subtitle: Text(CurrencyService.formatRupiah(expense)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Pemasukan'),
              subtitle: Text(CurrencyService.formatRupiah(income)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total Transaksi'),
              subtitle: Text('${dayItems.length} transaksi'),
            ),
          ),
        ],
      ),
    );
  }
}
