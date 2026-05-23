import 'package:flutter/material.dart';

import 'budget_mode.dart';
import 'usage_style.dart';

class UserSettings {
  const UserSettings({
    this.dailyReminderEnabled = false,
    this.dailyReminderTime = '20:00',
    this.quickToolsNotificationEnabled = true,
    this.autoSavingEnabled = true,
    this.themeMode = ThemeMode.system,
    this.budgetMode = BudgetMode.normal,
    this.usageStyle = UsageStyle.cepat,
  });

  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final bool quickToolsNotificationEnabled;
  final bool autoSavingEnabled;
  final ThemeMode themeMode;
  final BudgetMode budgetMode;
  final UsageStyle usageStyle;

  UserSettings copyWith({
    bool? dailyReminderEnabled,
    String? dailyReminderTime,
    bool? quickToolsNotificationEnabled,
    bool? autoSavingEnabled,
    ThemeMode? themeMode,
    BudgetMode? budgetMode,
    UsageStyle? usageStyle,
  }) {
    return UserSettings(
      dailyReminderEnabled:
          dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      quickToolsNotificationEnabled:
          quickToolsNotificationEnabled ?? this.quickToolsNotificationEnabled,
      autoSavingEnabled: autoSavingEnabled ?? this.autoSavingEnabled,
      themeMode: themeMode ?? this.themeMode,
      budgetMode: budgetMode ?? this.budgetMode,
      usageStyle: usageStyle ?? this.usageStyle,
    );
  }
}
