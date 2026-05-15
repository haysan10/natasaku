package com.natasaku.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebSettings
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.natasaku.app.reminder.ExpenseReminderReceiver
import com.natasaku.app.reminder.ExpenseReminderScheduler
import com.natasaku.app.reminder.ExpenseReminderStore
import com.natasaku.app.reminder.NataSakuWebBridge
import dagger.hilt.android.AndroidEntryPoint
import org.json.JSONObject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private lateinit var webView: WebView
    private lateinit var reminderScheduler: ExpenseReminderScheduler
    private lateinit var reminderStore: ExpenseReminderStore
    private var pendingOpenTransactionModal = false

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        maybeRequestNotificationPermission()
        reminderStore = ExpenseReminderStore(this)
        reminderScheduler = ExpenseReminderScheduler(this)

        webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.databaseEnabled = true
            settings.allowFileAccess = true
            settings.allowContentAccess = true
            settings.useWideViewPort = true
            settings.loadWithOverviewMode = true
            settings.cacheMode = WebSettings.LOAD_NO_CACHE
            clearCache(true)
            addJavascriptInterface(
                NataSakuWebBridge(this@MainActivity, reminderStore, reminderScheduler),
                "NataSakuNative",
            )
            webChromeClient = WebChromeClient()
            webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    injectPendingQuickTransactions()
                    if (pendingOpenTransactionModal) {
                        evaluateJavascriptSafely("window.openTransactionModal && window.openTransactionModal();")
                        pendingOpenTransactionModal = false
                    }
                }
            }
            loadUrl("file:///android_asset/index.html?v=${System.currentTimeMillis()}")
        }
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (webView.canGoBack()) {
                    webView.goBack()
                } else {
                    isEnabled = false
                    onBackPressedDispatcher.onBackPressed()
                }
            }
        })
        setContentView(webView)
        handleIntent(intent)
        reminderScheduler.scheduleNext()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun maybeRequestNotificationPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) return
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1100)
    }

    private fun handleIntent(intent: Intent?) {
        val shouldOpenQuickInput = intent?.getBooleanExtra(ExpenseReminderReceiver.EXTRA_OPEN_QUICK_INPUT, false) == true ||
            intent?.action == ExpenseReminderReceiver.ACTION_OPEN_QUICK_INPUT
        if (!shouldOpenQuickInput) return

        if (::webView.isInitialized) {
            evaluateJavascriptSafely("window.openTransactionModal && window.openTransactionModal();")
        } else {
            pendingOpenTransactionModal = true
        }
    }

    private fun injectPendingQuickTransactions() {
        val pendingJson = reminderStore.consumePendingTransactionsJson()
        if (pendingJson == "[]") return
        val escaped = JSONObject.quote(pendingJson)
        evaluateJavascriptSafely(
            "window.__natasakuApplyNativeQuickEntries && window.__natasakuApplyNativeQuickEntries(JSON.parse($escaped));",
        )
    }

    private fun evaluateJavascriptSafely(script: String) {
        if (!::webView.isInitialized) return
        webView.post { webView.evaluateJavascript(script, null) }
    }
}
