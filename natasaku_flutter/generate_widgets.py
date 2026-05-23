import os

WIDGETS = [
    ("Widget1Compact", "widget_1_compact", "1x1", 40, 40, "Compact Shortcut Widget"),
    ("Widget2Today", "widget_2_today", "2x2", 110, 110, "Today Summary Widget"),
    ("Widget3QuickActions", "widget_3_quick_actions", "3x2", 180, 110, "Quick Actions Widget"),
    ("Widget4Progress", "widget_4_progress", "3x2", 180, 110, "Progress Widget"),
    ("Widget5List", "widget_5_list", "4x2", 250, 110, "List Preview Widget"),
    ("Widget6Focus", "widget_6_focus", "2x2", 110, 110, "Focus Reminder Widget"),
    ("Widget7Dashboard", "widget_7_dashboard", "4x4", 250, 250, "Large Dashboard Widget"),
    ("Widget8Minimal", "widget_8_minimal", "2x1", 110, 40, "Minimal Aesthetic Widget"),
]

base_dir = "android/app/src/main"
layout_dir = os.path.join(base_dir, "res/layout")
xml_dir = os.path.join(base_dir, "res/xml")
kt_dir = os.path.join(base_dir, "kotlin/com/natasaku/app")

os.makedirs(layout_dir, exist_ok=True)
os.makedirs(xml_dir, exist_ok=True)
os.makedirs(kt_dir, exist_ok=True)

layout_templates = {
    "widget_1_compact": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="@drawable/widget_bg"
    android:gravity="center" android:padding="8dp">
    <ImageView android:layout_width="24dp" android:layout_height="24dp" android:src="@mipmap/ic_launcher" />
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:text="Add" android:textSize="12sp" android:textColor="#0F766E" android:textStyle="bold" android:layout_marginTop="4dp"/>
</LinearLayout>""",
    "widget_2_today": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="@drawable/widget_bg" android:padding="16dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="HARI INI" android:textSize="10sp" android:textStyle="bold" android:textColor="#6B7280" />
    <TextView android:id="@+id/tv_expense" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Rp0" android:textSize="20sp" android:textStyle="bold" android:textColor="#111827" />
    <TextView android:id="@+id/tv_safe" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Batas: Rp0" android:textSize="12sp" android:textColor="#059669" android:layout_marginTop="4dp"/>
</LinearLayout>""",
    "widget_3_quick_actions": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="horizontal" android:background="@drawable/widget_bg" android:gravity="center" android:padding="16dp" android:weightSum="3">
    <Button android:id="@+id/btn_action_1" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Catat" android:textSize="10sp" />
    <Button android:id="@+id/btn_action_2" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Laporan" android:textSize="10sp" />
    <Button android:id="@+id/btn_action_3" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Setting" android:textSize="10sp" />
</LinearLayout>""",
    "widget_4_progress": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="@drawable/widget_bg" android:padding="16dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Progress Pemakaian" android:textSize="12sp" android:textStyle="bold" android:textColor="#374151" />
    <ProgressBar android:id="@+id/progress_bar" style="?android:attr/progressBarStyleHorizontal" android:layout_width="match_parent" android:layout_height="wrap_content" android:max="100" android:progress="0" android:layout_marginTop="8dp"/>
    <TextView android:id="@+id/tv_percent" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="0%" android:textAlignment="viewEnd" android:textSize="12sp" android:textColor="#6B7280" />
</LinearLayout>""",
    "widget_5_list": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="@drawable/widget_bg" android:padding="12dp">
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Daftar Cepat" android:textSize="12sp" android:textStyle="bold" android:textColor="#374151" />
    <View android:layout_width="match_parent" android:layout_height="1dp" android:background="#E5E7EB" android:layout_marginTop="4dp" android:layout_marginBottom="4dp"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="1. Buka NataSaku untuk detail" android:textSize="11sp" android:textColor="#6B7280" />
</LinearLayout>""",
    "widget_6_focus": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0F766E" android:padding="16dp" android:gravity="center">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="FOKUS HARI INI" android:textSize="10sp" android:textColor="#99F6E4" />
    <TextView android:id="@+id/tv_advice" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Catat transaksimu!" android:textSize="14sp" android:textStyle="bold" android:textColor="#FFFFFF" android:textAlignment="center" android:layout_marginTop="8dp" />
</LinearLayout>""",
    "widget_7_dashboard": """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="@drawable/widget_bg" android:padding="16dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Dashboard Keuangan" android:textSize="14sp" android:textStyle="bold" android:textColor="#111827" />
    <TextView android:id="@+id/tv_expense" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Keluar: Rp0" android:textSize="12sp" android:textColor="#DC2626" android:layout_marginTop="8dp"/>
    <TextView android:id="@+id/tv_safe" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Batas: Rp0" android:textSize="12sp" android:textColor="#059669" />
    <TextView android:id="@+id/tv_fund" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Sisa Dana: Rp0" android:textSize="12sp" android:textColor="#374151" />
</LinearLayout>""",
    "widget_8_minimal": """<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:background="@android:color/transparent" android:padding="8dp">
    <TextView android:id="@+id/tv_safe" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Batas: Rp0" android:textSize="14sp" android:textColor="#FFFFFF" android:textStyle="bold" android:shadowColor="#000000" android:shadowDx="1" android:shadowDy="1" android:shadowRadius="2" android:layout_centerInParent="true" />
</RelativeLayout>"""
}

# Create dummy drawable
drawable_dir = os.path.join(base_dir, "res/drawable")
os.makedirs(drawable_dir, exist_ok=True)
with open(os.path.join(drawable_dir, "widget_bg.xml"), "w") as f:
    f.write("""<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#FFFFFF" />
    <corners android:radius="16dp" />
</shape>""")

for class_name, layout_name, size, w, h, title in WIDGETS:
    # Write Layout XML
    with open(os.path.join(layout_dir, f"{layout_name}.xml"), "w") as f:
        f.write(layout_templates[layout_name])
    
    # Write Info XML
    with open(os.path.join(xml_dir, f"{layout_name}_info.xml"), "w") as f:
        f.write(f"""<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="{w}dp"
    android:minHeight="{h}dp"
    android:targetCellWidth="{size.split('x')[0]}"
    android:targetCellHeight="{size.split('x')[1]}"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:initialLayout="@layout/{layout_name}"
    android:description="@string/app_name" />""")

    # Write Kotlin Provider
    with open(os.path.join(kt_dir, f"{class_name}Provider.kt"), "w") as f:
        f.write(f"""package com.natasaku.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.content.ComponentName

class {class_name}Provider : AppWidgetProvider() {{
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {{
        for (appWidgetId in appWidgetIds) {{
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }}
    }}

    companion object {{
        fun refreshAll(context: Context) {{
            val intent = Intent(context, {class_name}Provider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, {class_name}Provider::class.java))
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }}

        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {{
            val prefs = context.getSharedPreferences("natasaku_widget", Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.{layout_name})
            
            val intent = Intent(context, MainActivity::class.java)
            intent.putExtra("action", "quick_add")
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            
            // Set click action for root view or button
            views.setOnClickPendingIntent(R.id.btn_action_1, pendingIntent) // if exists
            // Or set to the whole widget (if no specific btn)
            try {{ views.setOnClickPendingIntent(android.R.id.background, pendingIntent) }} catch(e: Exception) {{}}

            try {{ views.setTextViewText(R.id.tv_expense, prefs.getString("todayExpense", "Rp0")) }} catch(e: Exception) {{}}
            try {{ views.setTextViewText(R.id.tv_safe, "Batas: " + prefs.getString("dailySafeBudget", "Rp0")) }} catch(e: Exception) {{}}
            try {{ views.setTextViewText(R.id.tv_fund, "Sisa: " + prefs.getString("remainingFund", "Rp0")) }} catch(e: Exception) {{}}
            try {{ views.setTextViewText(R.id.tv_advice, prefs.getString("advice", "Catat pengeluaranmu!")) }} catch(e: Exception) {{}}
            try {{ 
                val pct = prefs.getInt("usagePercent", 0)
                views.setProgressBar(R.id.progress_bar, 100, pct, false)
                views.setTextViewText(R.id.tv_percent, "$pct%")
            }} catch(e: Exception) {{}}

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }}
    }}
}}
""")

# Setup Quick Tools Service & Receiver
with open(os.path.join(kt_dir, "QuickToolsService.kt"), "w") as f:
    f.write("""package com.natasaku.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class QuickToolsService : Service() {
    private val CHANNEL_ID = "natasaku_quick_tools"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_SERVICE") {
            stopForeground(true)
            stopSelf()
            return START_NOT_STICKY
        }
        
        val notification = createNotification()
        startForeground(1001, notification)
        return START_STICKY
    }

    private fun createNotification(): Notification {
        val prefs = getSharedPreferences("natasaku_widget", Context.MODE_PRIVATE)
        val limit = prefs.getString("dailySafeBudget", "Rp0")

        val intentOpen = Intent(this, MainActivity::class.java)
        val pIntentOpen = PendingIntent.getActivity(this, 0, intentOpen, PendingIntent.FLAG_IMMUTABLE)

        val intentAdd = Intent(this, QuickToolsReceiver::class.java).apply { action = "ACTION_QUICK_ADD" }
        val pIntentAdd = PendingIntent.getBroadcast(this, 1, intentAdd, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val intentStop = Intent(this, QuickToolsService::class.java).apply { action = "STOP_SERVICE" }
        val pIntentStop = PendingIntent.getService(this, 2, intentStop, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("NataSaku Quick Tools")
            .setContentText("Batas hari ini: $limit")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pIntentOpen)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, "Catat", pIntentAdd)
            .addAction(0, "Sembunyikan", pIntentStop)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Quick Tools",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Persistent notification for quick access"
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
""")

with open(os.path.join(kt_dir, "QuickToolsReceiver.kt"), "w") as f:
    f.write("""package com.natasaku.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class QuickToolsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "ACTION_QUICK_ADD") {
            val appIntent = Intent(context, MainActivity::class.java)
            appIntent.putExtra("action", "quick_add")
            appIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            context.startActivity(appIntent)
        }
    }
}
""")
