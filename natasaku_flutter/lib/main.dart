import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/services/android_widget_service.dart';
import 'features/notifications/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for id_ID locale to prevent date format exceptions
  await initializeDateFormatting('id_ID', null);

  try {
    // Initialize notification service for persistent notification bar
    final notificationsService = NotificationsService();
    await notificationsService.initialize();

    // Initialize widget service for Home Widget actions
    AndroidWidgetService.initialize();
    await AndroidWidgetService.refreshQuickTools();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const ProviderScope(child: NataSakuApp()));
}
