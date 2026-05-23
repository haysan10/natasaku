package com.natasaku.app.presentation.navigation

sealed class Screen(val route: String) {
    data object Splash : Screen("splash")
    data object SetupGraph : Screen("setup_graph")
    data object Welcome : Screen("welcome")
    data object Onboarding : Screen("onboarding")
    data object SetupPeriod : Screen("setup_period")
    data object SetupIncome : Screen("setup_income")
    data object SetupFixedExpense : Screen("setup_fixed_expense")
    data object SetupSaving : Screen("setup_saving")
    data object SetupReview : Screen("setup_review")
    data object Main : Screen("main")
    data object Home : Screen("home")
    data object TransactionHistory : Screen("transaction_history")
    data object Budget : Screen("budget")
    data object Saving : Screen("saving")
    data object Settings : Screen("settings")
    data object MonthlyReport : Screen("monthly_report")
    data object ExportSuccess : Screen("export_success/{fileName}/{mimeType}/{uri}") {
        fun createRoute(fileName: String, mimeType: String, uri: String): String {
            return "export_success/$fileName/$mimeType/$uri"
        }
    }
}
