import 'budget_mode.dart';
import 'usage_style.dart';

class UserSettings {
  const UserSettings({
    this.dailyReminderEnabled = false,
    this.dailyReminderTime = '20:00',
    this.quickToolsNotificationEnabled = true,
    this.autoSavingEnabled = true,
    this.budgetMode = BudgetMode.normal,
    this.usageStyle = UsageStyle.cepat,
  });

  final bool dailyReminderEnabled;
  final String dailyReminderTime;
  final bool quickToolsNotificationEnabled;
  final bool autoSavingEnabled;
  final BudgetMode budgetMode;
  final UsageStyle usageStyle;
}
