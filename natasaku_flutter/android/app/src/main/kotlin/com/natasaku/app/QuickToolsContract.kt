package com.natasaku.app

object QuickToolsContract {
    const val channelName = "com.natasaku.quick_tools"

    const val prefsName = "natasaku_quick_tools"
    const val flutterPrefsName = "FlutterSharedPreferences"
    const val flutterTransactionsKey = "flutter.transactions"

    const val keyDailySafeBudget = "dailySafeBudget"
    const val keyDailyStatus = "dailyStatus"
    const val keyPeriodStatus = "periodStatus"
    const val keyRemainingFund = "remainingFund"
    const val keyTodayExpense = "todayExpense"
    const val keyTomorrowBudget = "tomorrowBudget"
    const val keyAdvice = "advice"
    const val keyRemainingDays = "remainingDays"
    const val keyUsagePercent = "usagePercent"
    const val keyDailySafeBudgetAmount = "dailySafeBudgetAmount"
    const val keyRemainingFundAmount = "remainingFundAmount"
    const val keyTodayExpenseAmount = "todayExpenseAmount"
    const val keyNotificationEnabled = "quickToolsNotificationEnabled"

    const val intentActionKey = "action"
    const val actionOpen = "action_open"
    const val actionQuickAdd = "action_quick_add"
    const val actionAddExpense = "action_add_expense"
    const val actionCheck = "action_check"

    const val receiverActionOpen = "com.natasaku.app.quicktools.OPEN"
    const val receiverActionCheck = "com.natasaku.app.quicktools.CHECK"
    const val receiverActionQuickExpense10k = "com.natasaku.app.quicktools.EXPENSE_10K"
    const val receiverActionQuickExpense50k = "com.natasaku.app.quicktools.EXPENSE_50K"
    const val receiverActionSimulasi = "com.natasaku.app.quicktools.SIMULASI"
    const val receiverActionQuickAdd = "com.natasaku.app.quicktools.QUICK_ADD"
    const val actionSimulasi = "action_simulasi"

    const val notificationChannelId = "natasaku_quick_tools"
    const val notificationId = 9031
    const val receiptNotificationId = 9032
}
