import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/services/currency_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/transaction_entry_sheet.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  List<TransactionModel> _items = <TransactionModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.loadTransactions();
    items.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _addTransaction() async {
    final draft = await showTransactionEntrySheet(context);
    if (draft == null) return;

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

  void _onNavigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      case 1:
        break;
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
    return MainShell(
      index: 1,
      onNavigate: _onNavigate,
      onFabPressed: _addTransaction,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? _TransactionsEmptyState(onAdd: _addTransaction)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Riwayat Transaksi',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          '${_items.length} transaksi tercatat',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _addTransaction,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Catat Detail'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final tx = _items[index];
                              final color = tx.isExpense
                                  ? AppTheme.error
                                  : AppTheme.success;
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      tx.isExpense
                                          ? Icons.call_made_rounded
                                          : Icons.call_received_rounded,
                                      color: color,
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    tx.category ??
                                        (tx.isExpense
                                            ? 'Pengeluaran'
                                            : 'Pemasukan'),
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      [
                                        tx.note?.trim(),
                                        tx.date
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first,
                                      ]
                                          .whereType<String>()
                                          .where((item) => item.isNotEmpty)
                                          .join('\n'),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  trailing: Text(
                                    CurrencyService.formatRupiah(tx.amount),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada transaksi',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Catat pengeluaran atau pemasukan pertamamu, dan NataSaku akan mulai menghitung jatah amanmu.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Catat Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
