import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../data/models/transaction_model.dart';
import './transaction_entry_sheet.dart';
import '../../shared/widgets/global_feature_tour.dart';

class MainShell extends ConsumerWidget {
  const MainShell({
    super.key,
    this.navigationShell,
    this.index,
    this.onNavigate,
    this.child,
  });

  final StatefulNavigationShell? navigationShell;
  final int? index;
  final ValueChanged<int>? onNavigate;
  final Widget? child;

  Future<void> _addTransaction(BuildContext context, WidgetRef ref) async {
    final draft = await showTransactionEntrySheet(context);
    if (draft == null) return;

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: draft.date,
      amount: draft.amount,
      isExpense: draft.isExpense,
      note: draft.note,
      category: draft.category,
      isNeed: draft.isNeed,
    );
    
    await ref.read(dashboardProvider.notifier).addTransaction(transaction);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell?.currentIndex ?? index ?? 0;

    final showFab = currentIndex == 0 || currentIndex == 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (navigationShell != null && currentIndex != 0) {
          navigationShell!.goBranch(0);
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Kamu sudah di Beranda utama.'),
              duration: Duration(seconds: 2),
            ),
          );
      },
      child: Scaffold(
        body: navigationShell ?? child ?? const SizedBox.shrink(),
        floatingActionButton: showFab
            ? Container(
                key: TourKeys.fabButton,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Semantics(
                  button: true,
                  label: 'Catat pengeluaran',
                  child: FloatingActionButton(
                    onPressed: () => _addTransaction(context, ref),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const CircleBorder(),
                    tooltip: 'Catat Pengeluaran',
                    child: const Icon(Icons.add_rounded, size: 28),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? Theme.of(context).colorScheme.outlineVariant : Colors.grey.shade300,
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (idx) {
              if (navigationShell != null) {
                navigationShell!.goBranch(
                  idx,
                  initialLocation: idx == currentIndex,
                );
              } else {
                onNavigate?.call(idx);
              }
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Transaksi',
              ),
              const NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Budget',
              ),
              NavigationDestination(
                
                icon: const Icon(Icons.savings_outlined),
                selectedIcon: const Icon(Icons.savings_rounded),
                label: 'Tabungan',
              ),
              NavigationDestination(
                
                icon: const Icon(Icons.analytics_outlined),
                selectedIcon: const Icon(Icons.analytics_rounded),
                label: 'Laporan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
