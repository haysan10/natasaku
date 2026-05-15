package com.natasaku.app.presentation.navigation

import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.navigation
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.natasaku.app.presentation.screen.report.ExportSuccessRoute
import com.natasaku.app.presentation.screen.setup.SetupFixedExpenseRoute
import com.natasaku.app.presentation.screen.setup.SetupIncomeRoute
import com.natasaku.app.presentation.screen.setup.SetupOnboardingRoute
import com.natasaku.app.presentation.screen.setup.SetupPeriodRoute
import com.natasaku.app.presentation.screen.setup.SetupReviewRoute
import com.natasaku.app.presentation.screen.setup.SetupSavingRoute
import com.natasaku.app.presentation.screen.setup.SetupViewModel
import com.natasaku.app.presentation.screen.setup.SetupWelcomeRoute
import com.natasaku.app.presentation.screen.splash.SplashDestination
import com.natasaku.app.presentation.screen.splash.SplashRoute

@Composable
fun NataSakuNavHost() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = Screen.Splash.route) {
        composable(Screen.Splash.route) {
            SplashRoute(
                onNavigate = { destination ->
                    val targetRoute = when (destination) {
                        SplashDestination.Welcome -> Screen.Welcome.route
                        SplashDestination.SetupPeriod -> Screen.SetupPeriod.route
                        SplashDestination.Main -> Screen.Main.route
                    }
                    navController.navigate(targetRoute) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                },
            )
        }

        navigation(
            route = Screen.SetupGraph.route,
            startDestination = Screen.Welcome.route,
        ) {
            composable(Screen.Welcome.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupWelcomeRoute(
                    onNextRoute = { navController.navigate(Screen.Onboarding.route) },
                    vm = vm,
                )
            }
            composable(Screen.Onboarding.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupOnboardingRoute(
                    onNextRoute = { navController.navigate(Screen.SetupPeriod.route) },
                    onBackRoute = { navController.popBackStack() },
                    vm = vm,
                )
            }
            composable(Screen.SetupPeriod.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupPeriodRoute(
                    onNextRoute = { navController.navigate(Screen.SetupIncome.route) },
                    onBackRoute = { navController.popBackStack() },
                    vm = vm,
                )
            }
            composable(Screen.SetupIncome.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupIncomeRoute(
                    onNextRoute = { navController.navigate(Screen.SetupFixedExpense.route) },
                    onBackRoute = { navController.popBackStack() },
                    vm = vm,
                )
            }
            composable(Screen.SetupFixedExpense.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupFixedExpenseRoute(
                    onNextRoute = { navController.navigate(Screen.SetupSaving.route) },
                    onBackRoute = { navController.popBackStack() },
                    vm = vm,
                )
            }
            composable(Screen.SetupSaving.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupSavingRoute(
                    onNextRoute = { navController.navigate(Screen.SetupReview.route) },
                    onBackRoute = { navController.popBackStack() },
                    vm = vm,
                )
            }
            composable(Screen.SetupReview.route) { backStackEntry ->
                val parentEntry = remember(backStackEntry) {
                    navController.getBackStackEntry(Screen.SetupGraph.route)
                }
                val vm: SetupViewModel = hiltViewModel(parentEntry)
                SetupReviewRoute(
                    onBackRoute = { navController.popBackStack() },
                    onFinish = {
                        navController.navigate(Screen.Main.route) {
                            popUpTo(Screen.SetupGraph.route) { inclusive = true }
                        }
                    },
                    vm = vm,
                )
            }
        }

        composable(Screen.Main.route) {
            MainTabsRoute(
                onOpenSettings = { navController.navigate(Screen.Settings.route) },
                onOpenExportSuccess = { file ->
                    navController.navigate(
                        Screen.ExportSuccess.createRoute(
                            fileName = Uri.encode(file.fileName),
                            mimeType = Uri.encode(file.mimeType),
                            uri = Uri.encode(file.uri.toString()),
                        ),
                    )
                },
            )
        }
        composable(Screen.Settings.route) {
            com.natasaku.app.presentation.screen.settings.SettingsRoute(onBack = { navController.popBackStack() })
        }
        composable(
            route = Screen.ExportSuccess.route,
            arguments = listOf(
                navArgument("fileName") { type = NavType.StringType },
                navArgument("mimeType") { type = NavType.StringType },
                navArgument("uri") { type = NavType.StringType },
            ),
        ) { backStackEntry ->
            ExportSuccessRoute(
                fileName = Uri.decode(backStackEntry.arguments?.getString("fileName").orEmpty()),
                mimeType = Uri.decode(backStackEntry.arguments?.getString("mimeType").orEmpty()),
                uri = Uri.decode(backStackEntry.arguments?.getString("uri").orEmpty()),
                onBack = { navController.popBackStack() },
            )
        }
    }
}
