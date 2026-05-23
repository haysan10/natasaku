package com.natasaku.app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.natasaku.app.MainActivity
import com.natasaku.app.R
import java.time.LocalTime
import java.time.format.DateTimeFormatter

enum class WidgetState {
    NORMAL, LOADING, EMPTY, ERROR
}

object WidgetDataStore {
    private const val PREFS_NAME = "natasaku_widget_prefs"
    private const val KEY_STATE = "widget_state"
    private const val KEY_BALANCE_HIDDEN = "is_balance_hidden"

    fun getWidgetState(context: Context): WidgetState {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val name = prefs.getString(KEY_STATE, WidgetState.NORMAL.name) ?: WidgetState.NORMAL.name
        return runCatching { WidgetState.valueOf(name) }.getOrDefault(WidgetState.NORMAL)
    }

    fun setWidgetState(context: Context, state: WidgetState) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_STATE, state.name).apply()
    }

    fun isBalanceHidden(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_BALANCE_HIDDEN, false)
    }

    fun setBalanceHidden(context: Context, hidden: Boolean) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_BALANCE_HIDDEN, hidden).apply()
    }
}

open class BaseWidgetProvider : AppWidgetProvider() {
    companion object {
        const val ACTION_TOGGLE_BALANCE = "com.natasaku.app.widget.ACTION_TOGGLE_BALANCE"
        const val ACTION_CYCLE_STATE = "com.natasaku.app.widget.ACTION_CYCLE_STATE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_TOGGLE_BALANCE -> {
                val current = WidgetDataStore.isBalanceHidden(context)
                WidgetDataStore.setBalanceHidden(context, !current)
                triggerWidgetUpdate(context)
            }
            ACTION_CYCLE_STATE -> {
                val currentState = WidgetDataStore.getWidgetState(context)
                val nextState = when (currentState) {
                    WidgetState.NORMAL -> WidgetState.LOADING
                    WidgetState.LOADING -> WidgetState.EMPTY
                    WidgetState.EMPTY -> WidgetState.ERROR
                    WidgetState.ERROR -> WidgetState.NORMAL
                }
                WidgetDataStore.setWidgetState(context, nextState)
                triggerWidgetUpdate(context)
            }
        }
    }

    private fun triggerWidgetUpdate(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetProviders = listOf(
            MiniStatusWidgetProvider::class.java,
            QuickAddWidgetProvider::class.java,
            DailyBudgetWidgetProvider::class.java,
            SavingGoalWidgetProvider::class.java,
            WeeklySpendingWidgetProvider::class.java,
            FinancialSummaryWidgetProvider::class.java,
            SmartAssistantWidgetProvider::class.java
        )
        for (provider in widgetProviders) {
            val ids = appWidgetManager.getAppWidgetIds(ComponentName(context, provider))
            if (ids.isNotEmpty()) {
                val updateIntent = Intent(context, provider).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(updateIntent)
            }
        }
    }

    protected fun createDeepLinkPendingIntent(context: Context, uriString: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse(uriString)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, requestCode, intent, flags)
    }

    protected fun createBroadcastPendingIntent(context: Context, action: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, javaClass).apply {
            this.action = action
        }
        val flags = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(context, requestCode, intent, flags)
    }

    protected fun setupCommonStates(views: RemoteViews, state: WidgetState) {
        when (state) {
            WidgetState.NORMAL -> {
                views.setViewVisibility(R.id.layout_normal, View.VISIBLE)
                setViewVisibilityIfExists(views, R.id.layout_loading, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_empty, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_error, View.GONE)
            }
            WidgetState.LOADING -> {
                views.setViewVisibility(R.id.layout_normal, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_loading, View.VISIBLE)
                setViewVisibilityIfExists(views, R.id.layout_empty, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_error, View.GONE)
            }
            WidgetState.EMPTY -> {
                views.setViewVisibility(R.id.layout_normal, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_loading, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_empty, View.VISIBLE)
                setViewVisibilityIfExists(views, R.id.layout_error, View.GONE)
            }
            WidgetState.ERROR -> {
                views.setViewVisibility(R.id.layout_normal, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_loading, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_empty, View.GONE)
                setViewVisibilityIfExists(views, R.id.layout_error, View.VISIBLE)
            }
        }
    }

    private fun setViewVisibilityIfExists(views: RemoteViews, viewId: Int, visibility: Int) {
        runCatching {
            views.setViewVisibility(viewId, visibility)
        }
    }

    protected fun getFormattedTime(): String {
        return "Updated " + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm"))
    }
}

class MiniStatusWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_mini_status)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val allowanceText = if (isHidden) "Rp••••••" else "Rp166.667"
                views.setTextViewText(R.id.tv_allowance_value, allowanceText)
                views.setTextViewText(R.id.tv_status_badge, "Aman")
                views.setImageViewResource(R.id.btn_toggle_balance, if (isHidden) R.drawable.ic_widget_invisible else R.drawable.ic_widget_visible)
                
                views.setOnClickPendingIntent(R.id.tv_allowance_value, createDeepLinkPendingIntent(context, "natasaku://detail-jatah", appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.btn_toggle_balance, createBroadcastPendingIntent(context, ACTION_TOGGLE_BALANCE, appWidgetId + 2))
                views.setOnClickPendingIntent(R.id.tv_status_badge, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 3))
            }
            
            views.setOnClickPendingIntent(R.id.layout_normal, createDeepLinkPendingIntent(context, "natasaku://home", appWidgetId))
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class QuickAddWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                views.setOnClickPendingIntent(R.id.btn_quick_jajan, createDeepLinkPendingIntent(context, "natasaku://jajan", appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.btn_quick_pemasukan, createDeepLinkPendingIntent(context, "natasaku://pemasukan", appWidgetId + 2))
                views.setOnClickPendingIntent(R.id.btn_quick_tabung, createDeepLinkPendingIntent(context, "natasaku://tabung", appWidgetId + 3))
                views.setOnClickPendingIntent(R.id.btn_quick_budget, createDeepLinkPendingIntent(context, "natasaku://budget", appWidgetId + 4))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class DailyBudgetWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_daily_budget)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val allowanceText = if (isHidden) "Rp••••••" else "Rp166.667"
                val usedText = if (isHidden) "Dipakai Rp••••••" else "Dipakai Rp58.333"
                val limitText = if (isHidden) "Batas Rp••••••" else "Batas Rp166.667"
                
                views.setTextViewText(R.id.tv_daily_allowance, allowanceText)
                views.setTextViewText(R.id.tv_used_label, usedText)
                views.setTextViewText(R.id.tv_limit_label, limitText)
                views.setProgressBar(R.id.progress_usage, 100, 35, false)
                
                views.setOnClickPendingIntent(R.id.btn_record_jajan, createDeepLinkPendingIntent(context, "natasaku://jajan", appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.tv_daily_allowance, createDeepLinkPendingIntent(context, "natasaku://detail-jatah", appWidgetId + 2))
                
                // Allow cycling test state by clicking the header allowance text container
                views.setOnClickPendingIntent(R.id.tv_limit_label, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 3))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class SavingGoalWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_saving_goal)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val valuesText = if (isHidden) "Rp•••••• / Rp••••••" else "Rp1.250.000 / Rp5.000.000"
                views.setTextViewText(R.id.tv_saving_title, "Dana Darurat")
                views.setTextViewText(R.id.tv_saving_values, valuesText)
                views.setProgressBar(R.id.progress_saving, 100, 25, false)
                
                views.setOnClickPendingIntent(R.id.btn_record_saving, createDeepLinkPendingIntent(context, "natasaku://target-tabungan", appWidgetId + 1))
                
                // Cycle states on percent click
                views.setOnClickPendingIntent(R.id.tv_saving_percent, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 2))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class WeeklySpendingWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_weekly_spending)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val totalText = if (isHidden) "Rp••••••" else "Rp190.000"
                views.setTextViewText(R.id.tv_weekly_total, totalText)
                views.setTextViewText(R.id.tv_weekly_status, "Aman")
                
                // Setup visual bar levels Monday to Sunday using weight adjustments
                views.setViewLayoutWeight(R.id.bar_space_day1, 80f)
                views.setViewLayoutWeight(R.id.bar_fill_day1, 20f)
                views.setViewLayoutWeight(R.id.bar_space_day2, 65f)
                views.setViewLayoutWeight(R.id.bar_fill_day2, 35f)
                views.setViewLayoutWeight(R.id.bar_space_day3, 85f)
                views.setViewLayoutWeight(R.id.bar_fill_day3, 15f)
                views.setViewLayoutWeight(R.id.bar_space_day4, 50f)
                views.setViewLayoutWeight(R.id.bar_fill_day4, 50f)
                views.setViewLayoutWeight(R.id.bar_space_day5, 60f)
                views.setViewLayoutWeight(R.id.bar_fill_day5, 40f)
                views.setViewLayoutWeight(R.id.bar_space_day6, 70f)
                views.setViewLayoutWeight(R.id.bar_fill_day6, 30f)
                views.setViewLayoutWeight(R.id.bar_space_day7, 100f)
                views.setViewLayoutWeight(R.id.bar_fill_day7, 0f)
                
                views.setOnClickPendingIntent(R.id.tv_weekly_status, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.layout_normal, createDeepLinkPendingIntent(context, "natasaku://laporan", appWidgetId + 2))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class FinancialSummaryWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_financial_summary)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val incomeText = if (isHidden) "Rp••••••" else "Rp5.300.000"
                val expenseText = if (isHidden) "Rp••••••" else "Rp2.311.487"
                val netflowText = if (isHidden) "Rp••••••" else "Rp2.988.513"
                val savingsText = if (isHidden) "Rp••••••" else "Rp2.500.000"
                
                views.setTextViewText(R.id.tv_income_value, incomeText)
                views.setTextViewText(R.id.tv_expense_value, expenseText)
                views.setTextViewText(R.id.tv_netflow_value, netflowText)
                views.setTextViewText(R.id.tv_savings_value, savingsText)
                views.setTextViewText(R.id.tv_summary_badge, "Sangat Sehat")
                views.setTextViewText(R.id.tv_last_updated, getFormattedTime())
                
                views.setOnClickPendingIntent(R.id.tv_summary_badge, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.layout_normal, createDeepLinkPendingIntent(context, "natasaku://laporan", appWidgetId + 2))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class SmartAssistantWidgetProvider : BaseWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetDataStore.getWidgetState(context)
        val isHidden = WidgetDataStore.isBalanceHidden(context)
        
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_smart_assistant)
            setupCommonStates(views, state)
            
            if (state == WidgetState.NORMAL) {
                val allowanceText = if (isHidden) "Rp••••••" else "Rp166.667"
                views.setTextViewText(R.id.tv_assistant_allowance, allowanceText)
                views.setTextViewText(R.id.tv_assistant_badge, "Masih aman")
                views.setTextViewText(R.id.tv_assistant_insight, "Pengeluaran makan paling besar bulan ini. Amankan jatah harianmu!")
                views.setProgressBar(R.id.progress_ast_saving, 100, 25, false)
                views.setTextViewText(R.id.tv_ast_last_updated, getFormattedTime())
                
                views.setOnClickPendingIntent(R.id.btn_ast_jajan, createDeepLinkPendingIntent(context, "natasaku://jajan", appWidgetId + 1))
                views.setOnClickPendingIntent(R.id.btn_ast_masuk, createDeepLinkPendingIntent(context, "natasaku://pemasukan", appWidgetId + 2))
                views.setOnClickPendingIntent(R.id.btn_ast_tabung, createDeepLinkPendingIntent(context, "natasaku://tabung", appWidgetId + 3))
                views.setOnClickPendingIntent(R.id.btn_ast_budget, createDeepLinkPendingIntent(context, "natasaku://budget", appWidgetId + 4))
                
                views.setOnClickPendingIntent(R.id.btn_insight_card, createDeepLinkPendingIntent(context, "natasaku://home", appWidgetId + 5))
                views.setOnClickPendingIntent(R.id.btn_savings_goal, createDeepLinkPendingIntent(context, "natasaku://target-tabungan", appWidgetId + 6))
                
                views.setOnClickPendingIntent(R.id.tv_assistant_badge, createBroadcastPendingIntent(context, ACTION_CYCLE_STATE, appWidgetId + 7))
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
