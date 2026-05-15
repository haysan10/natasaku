package com.natasaku.app.domain.model

import android.net.Uri
import java.time.Instant

data class ExportedFileUiModel(
    val fileName: String,
    val uri: Uri,
    val mimeType: String,
    val fileSizeBytes: Long,
    val createdAt: Instant,
)
