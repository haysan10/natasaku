package com.natasaku.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            QuickToolsContract.channelName
        )

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "syncQuickToolsData", "updateHomeWidget" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args == null) {
                        result.error("INVALID_ARGS", "Arguments missing", null)
                        return@setMethodCallHandler
                    }
                    val state = QuickToolsStateStore.saveFromMap(applicationContext, args)
                    QuickToolsWidgetRegistry.refreshAll(applicationContext)
                    QuickToolsNotificationManager.showOrUpdate(applicationContext, state)
                    result.success(null)
                }

                "setQuickToolsNotificationEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    QuickToolsStateStore.setNotificationEnabled(applicationContext, enabled)
                    if (enabled) {
                        QuickToolsNotificationManager.showOrUpdate(applicationContext)
                    } else {
                        QuickToolsNotificationManager.cancel(applicationContext)
                    }
                    result.success(null)
                }

                "refreshQuickTools" -> {
                    QuickToolsWidgetRegistry.refreshAll(applicationContext)
                    QuickToolsNotificationManager.showOrUpdate(applicationContext)
                    result.success(null)
                }

                "getInitialAction" -> {
                    val action = intent.getStringExtra(QuickToolsContract.intentActionKey)
                    result.success(action)
                    intent.removeExtra(QuickToolsContract.intentActionKey)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val action = intent.getStringExtra(QuickToolsContract.intentActionKey)
        if (action != null) {
            methodChannel?.invokeMethod("onQuickToolsAction", action)
            intent.removeExtra(QuickToolsContract.intentActionKey)
        }
    }
}
