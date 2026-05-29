// DEPRECATED: Use lib/core/routing/app_router.dart (GoRouter). Kept for reference only.
import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/daily_closing/daily_closing_page.dart';
import '../features/budget/budget_page.dart';
import '../features/launch/launch_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/reports/money_calendar_page.dart';
import '../features/reports/reports_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';
import '../features/setup/setup_page.dart';
// import '../features/tour/tour_page.dart';
import '../features/transactions/transactions_page.dart';

class AppRouter {
  static const String launch = '/';
  static const String tour = '/tour';
  static const String setup = '/setup';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String budget = '/budget';
  static const String reports = '/reports';
  static const String savings = '/savings';
  static const String dailyClosing = '/daily-closing';
  static const String notifications = '/notifications';
  static const String moneyCalendar = '/money-calendar';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case launch:
        return MaterialPageRoute(builder: (_) => const LaunchPage());
      case tour:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Tour Deprecated'))));
      case setup:
        return MaterialPageRoute(builder: (_) => const SetupPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionsPage());
      case budget:
        return MaterialPageRoute(builder: (_) => const BudgetPage());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      case savings:
        return MaterialPageRoute(builder: (_) => const SavingsPage());
      case dailyClosing:
        return MaterialPageRoute(builder: (_) => const DailyClosingPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case moneyCalendar:
        return MaterialPageRoute(builder: (_) => const MoneyCalendarPage());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const LaunchPage());
    }
  }
}
