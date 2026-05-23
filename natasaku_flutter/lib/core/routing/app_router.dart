import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/setup/setup_page.dart';
import '../../features/transactions/transactions_page.dart';
import '../../shared/widgets/main_shell.dart';

// Tour page — import only if the file exists
import '../../features/tour/tour_page.dart';

class AppRouter {
  // Route constants — used across the whole app
  static const String launch        = '/';
  static const String tour          = '/tour';
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

  static final router = GoRouter(
    initialLocation: launch,
    routes: [
      GoRoute(
        path: launch,
        builder: (context, state) => const LaunchPage(),
      ),
      GoRoute(
        path: tour,
        builder: (context, state) => const TourPage(),
      ),
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
    ],
  );
}
