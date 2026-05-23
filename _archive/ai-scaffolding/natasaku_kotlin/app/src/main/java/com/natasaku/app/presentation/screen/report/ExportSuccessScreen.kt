package com.natasaku.app.presentation.screen.report

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.natasaku.app.presentation.component.NataPrimaryButton
import com.natasaku.app.presentation.component.NataSecondaryButton

@Composable
fun ExportSuccessRoute(
    fileName: String,
    mimeType: String,
    uri: String,
    onBack: () -> Unit,
) {
    val context = LocalContext.current
    val parsedUri = Uri.parse(uri)

    Scaffold { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text("Export berhasil", style = MaterialTheme.typography.headlineSmall)
            Text("File berhasil dibuat.")
            Text(fileName, style = MaterialTheme.typography.titleMedium)
            NataPrimaryButton(
                text = "Bagikan File",
                onClick = {
                    val i = Intent(Intent.ACTION_SEND).apply {
                        type = mimeType
                        putExtra(Intent.EXTRA_STREAM, parsedUri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    ContextCompat.startActivity(context, Intent.createChooser(i, "Bagikan File"), null)
                },
                modifier = Modifier.fillMaxWidth(),
            )
            NataPrimaryButton(
                text = "Buka File",
                onClick = {
                    val i = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(parsedUri, mimeType)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    ContextCompat.startActivity(context, i, null)
                },
                modifier = Modifier.fillMaxWidth(),
            )
            NataSecondaryButton(
                text = "Kembali",
                onClick = onBack,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}
