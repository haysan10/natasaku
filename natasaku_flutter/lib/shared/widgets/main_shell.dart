import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../features/dashboard/feature_tour_manager.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.index,
    required this.body,
    required this.onNavigate,
    this.onFabPressed,
    this.fabKey,
  });

  final int index;
  final Widget body;
  final ValueChanged<int> onNavigate;
  final VoidCallback? onFabPressed;
  final GlobalKey? fabKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: body,
      floatingActionButton: onFabPressed != null
          ? Container(
              key: fabKey ?? TourKeys.fabButton,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: onFabPressed,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const CircleBorder(),
                tooltip: 'Catat Pengeluaran',
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.border,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onNavigate,
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
              key: TourKeys.navSavings,
              icon: const Icon(Icons.savings_outlined),
              selectedIcon: const Icon(Icons.savings_rounded),
              label: 'Tabungan',
            ),
            NavigationDestination(
              key: TourKeys.navReports,
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart_rounded),
              label: 'Laporan',
            ),
          ],
        ),
      ),
    );
  }
}
