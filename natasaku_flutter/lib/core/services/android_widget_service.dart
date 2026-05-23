import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidWidgetService {
  static const MethodChannel _channel =
      MethodChannel('com.natasaku.quick_tools');

  static final _actionStreamController = StreamController<String>.broadcast();
  static Stream<String> get onWidgetAction => _actionStreamController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onQuickToolsAction' ||
          call.method == 'onWidgetAction') {
        final action = call.arguments as String?;
        if (action != null) {
          _actionStreamController.add(action);
        }
      }
    });
  }

  static Future<String?> getInitialAction() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    return await _channel.invokeMethod<String?>('getInitialAction');
  }

  static Future<void> setQuickToolsNotificationEnabled(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setQuickToolsNotificationEnabled', {
        'enabled': enabled,
      });
    } catch (_) {
      // Keep settings interactions non-blocking.
    }
  }

  static Future<void> refreshQuickTools() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('refreshQuickTools');
    } catch (_) {
      // Keep dashboard flow non-blocking.
    }
  }

  static Future<void> updateHomeWidget({
    required String dailySafeBudget,
    required String dailyStatus,
    required String periodStatus,
    required String remainingFund,
    required String todayExpense,
    required String tomorrowBudget,
    required String advice,
    String remainingDays = '— hari',
    int usagePercent = 0,
    int dailySafeBudgetAmount = 0,
    int remainingFundAmount = 0,
    int todayExpenseAmount = 0,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('syncQuickToolsData', {
        'dailySafeBudget': dailySafeBudget,
        'dailyStatus': dailyStatus,
        'periodStatus': periodStatus,
        'remainingFund': remainingFund,
        'todayExpense': todayExpense,
        'tomorrowBudget': tomorrowBudget,
        'advice': advice,
        'remainingDays': remainingDays,
        'usagePercent': usagePercent,
        'dailySafeBudgetAmount': dailySafeBudgetAmount,
        'remainingFundAmount': remainingFundAmount,
        'todayExpenseAmount': todayExpenseAmount,
      });
    } catch (_) {
      // Fail silently so dashboard flow is never blocked by quick-tools sync.
    }
  }
}
