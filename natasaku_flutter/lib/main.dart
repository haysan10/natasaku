import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/services/android_widget_service.dart';
import 'features/notifications/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const NataSakuApp());
}
