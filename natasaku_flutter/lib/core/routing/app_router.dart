import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../features/bills/bills_page.dart';
import '../../features/budget/budget_page.dart';
import '../../features/daily_closing/daily_closing_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/launch/launch_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/reports/money_calendar_page.dart';
import '../../features/reports/reports_page.dart';
import '../../features/savings/savings_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/settings/recurring_transactions_page.dart';
import '../../features/setup/setup_page.dart';
import '../../features/transactions/transactions_page.dart';
import '../../features/debts/debts_page.dart';
import '../../shared/widgets/main_shell.dart';

// Tour page removed

class AppRouter {
  // Route constants — used across the whole app
  static const String launch        = '/';
// Tour route removed
  static const String setup         = '/setup';
  static const String dashboard     = '/dashboard';
  static const String transactions  = '/transactions';
  static const String budget        = '/budget';
  static const String reports       = '/reports';
  static const String savings       = '/savings';
  static const String dailyClosing  = '/daily-closing';
  static const String notifications = '/notifications';
  static const String moneyCalendar = '/money-calendar';
  static const String settings      = '/settings';
  static const String bills         = '/bills';
  static const String recurringTransactions = '/recurring-transactions';
  static const String debts         = '/debts';

  static final router = GoRouter(
    initialLocation: launch,
    redirect: (context, state) async {
      final storage = LocalStorage();
      final onboardingComplete = await storage.getOnboardingComplete();
      final hasPeriod = await storage.getBudgetPeriod() != null;
      final location = state.matchedLocation;
      final isOnboardingFlow =
          location == launch || location == setup;

      if (!onboardingComplete) {
        if (!isOnboardingFlow) return launch;
        return null;
      }

      if (!hasPeriod) {
        if (location != setup) return setup;
        return null;
      }

      // Allow access to setup (edit mode) if onboarding is complete and budget period exists.
      // But redirect to dashboard if trying to access launch.
      if (location == launch) {
        return dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: launch,
        builder: (context, state) => const LaunchPage(),
      ),
// Tour GoRoute removed
      GoRoute(
        path: setup,
        builder: (context, state) => const SetupPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const DashboardPage(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: transactions,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const TransactionsPage(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: budget,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const BudgetPage(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: savings,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const SavingsPage(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: reports,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ReportsPage(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: dailyClosing,
        builder: (context, state) => const DailyClosingPage(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: moneyCalendar,
        builder: (context, state) => const MoneyCalendarPage(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: bills,
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: recurringTransactions,
        builder: (context, state) => const RecurringTransactionsPage(),
      ),
      GoRoute(
        path: debts,
        builder: (context, state) => const DebtsPage(),
      ),
    ],
  );
}
