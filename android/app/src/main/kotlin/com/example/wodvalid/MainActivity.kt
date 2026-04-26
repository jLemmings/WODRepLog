package ch.joshuahemmings.wodreplog

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.media.AudioManager
import android.media.MediaMetadataRetriever
import android.media.ToneGenerator
import android.net.Uri
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import kotlin.math.max
import kotlin.math.min

class MainActivity : FlutterActivity() {
    private var toneGenerator: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ch.joshuahemmings.wodreplog/beep",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playBeep" -> {
                    val durationMs = call.argument<Int>("durationMs") ?: 180
                    playBeep(durationMs)
                    result.success(null)
                }
                "stopBeep" -> {
                    stopBeep()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ch.joshuahemmings.wodreplog/app_info",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVersionName" -> result.success(readVersionName())
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ch.joshuahemmings.wodreplog/video_overlay",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "embedOverlay" -> embedOverlay(call.arguments as? Map<*, *>, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun playBeep(durationMs: Int) {
        stopBeep()
        toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 100).also {
            it.startTone(ToneGenerator.TONE_DTMF_9, durationMs)
        }
    }

    private fun stopBeep() {
        toneGenerator?.stopTone()
        toneGenerator?.release()
        toneGenerator = null
    }

    override fun onDestroy() {
        stopBeep()
        super.onDestroy()
    }

    private fun readVersionName(): String {
        return packageManager.getPackageInfo(packageName, 0).versionName ?: ""
    }

    @UnstableApi
    private fun embedOverlay(arguments: Map<*, *>?, result: MethodChannel.Result) {
        val inputPath = arguments?.get("inputPath") as? String
        val outputPath = arguments?.get("outputPath") as? String

        if (inputPath.isNullOrBlank() || outputPath.isNullOrBlank()) {
            result.error("invalid_args", "Missing inputPath or outputPath", null)
            return
        }

        val inputFile = File(inputPath)
        if (!inputFile.exists()) {
            result.error("missing_input", "Input video does not exist", inputPath)
            return
        }

        File(outputPath).delete()

        val videoSize = readVideoDisplaySize(inputPath)
        val overlay = ProofOverlay(
            width = videoSize.first,
            height = videoSize.second,
            athleteName = arguments["athleteName"] as? String ?: "",
            eventName = arguments["eventName"] as? String ?: "",
            workoutTitle = arguments["workoutTitle"] as? String ?: "",
            timerType = arguments["timerType"] as? String,
            timerIntervalSeconds = arguments["timerIntervalSeconds"] as? Int,
            timerRounds = arguments["timerRounds"] as? Int,
            timerTotalSeconds = arguments["timerTotalSeconds"] as? Int,
            countdownSeconds = arguments["countdownSeconds"] as? Int ?: 0,
            eventLabel = arguments["eventLabel"] as? String ?: "Event",
            athleteLabel = arguments["athleteLabel"] as? String ?: "Athlete",
            workoutLabel = arguments["workoutLabel"] as? String ?: "Workout",
            roundLabel = arguments["roundLabel"] as? String ?: "Round",
            countdownLabel = arguments["countdownLabel"] as? String ?: "Countdown",
            startsInLabel = arguments["startsInLabel"] as? String ?: "Starts in",
            nextStartLabel = arguments["nextStartLabel"] as? String ?: "Next start",
            elapsedLabel = arguments["elapsedLabel"] as? String ?: "Elapsed",
            remainingLabel = arguments["remainingLabel"] as? String ?: "Remaining",
            remainingSuffix = arguments["remainingSuffix"] as? String ?: "remaining",
            elapsedSuffix = arguments["elapsedSuffix"] as? String ?: "elapsed",
        )

        val effects = Effects(
            emptyList(),
            listOf<Effect>(OverlayEffect(listOf(overlay))),
        )
        val mediaItem = MediaItem.fromUri(Uri.fromFile(inputFile))
        val editedMediaItem = EditedMediaItem.Builder(mediaItem)
            .setEffects(effects)
            .build()

        val transformer = Transformer.Builder(this)
            .setVideoMimeType(MimeTypes.VIDEO_H264)
            .setAudioMimeType(MimeTypes.AUDIO_AAC)
            .addListener(
                object : Transformer.Listener {
                    override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                        result.success(outputPath)
                    }

                    override fun onError(
                        composition: Composition,
                        exportResult: ExportResult,
                        exportException: ExportException,
                    ) {
                        result.error(
                            "overlay_export_failed",
                            exportException.message ?: "Failed to embed overlay",
                            exportException.stackTraceToString(),
                        )
                    }
                },
            )
            .build()

        transformer.start(editedMediaItem, outputPath)
    }

    private fun readVideoDisplaySize(inputPath: String): Pair<Int, Int> {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(inputPath)
            val width = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                ?.toIntOrNull() ?: 1920
            val height = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                ?.toIntOrNull() ?: 1080
            val rotation = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                ?.toIntOrNull() ?: 0
            if (rotation == 90 || rotation == 270) {
                Pair(height, width)
            } else {
                Pair(width, height)
            }
        } finally {
            retriever.release()
        }
    }
}

@UnstableApi
private class ProofOverlay(
    private val width: Int,
    private val height: Int,
    private val athleteName: String,
    private val eventName: String,
    private val workoutTitle: String,
    private val timerType: String?,
    private val timerIntervalSeconds: Int?,
    private val timerRounds: Int?,
    private val timerTotalSeconds: Int?,
    private val countdownSeconds: Int,
    private val eventLabel: String,
    private val athleteLabel: String,
    private val workoutLabel: String,
    private val roundLabel: String,
    private val countdownLabel: String,
    private val startsInLabel: String,
    private val nextStartLabel: String,
    private val elapsedLabel: String,
    private val remainingLabel: String,
    private val remainingSuffix: String,
    private val elapsedSuffix: String,
) : BitmapOverlay() {
    private var cachedSecond = -1
    private var cachedBitmap: Bitmap? = null

    override fun getBitmap(presentationTimeUs: Long): Bitmap {
        val second = max(0, (presentationTimeUs / 1_000_000L).toInt())
        if (cachedBitmap == null || cachedSecond != second) {
            cachedSecond = second
            cachedBitmap = drawOverlay(second)
        }
        return cachedBitmap!!
    }

    private fun drawOverlay(elapsedSeconds: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val scale = max(0.62f, min(width, height) / 1080f * 0.84f)
        val margin = 24f * scale
        val panelGap = 16f * scale
        val panelWidth = min(width * 0.38f, 480f * scale)
        val metadataLines = buildList {
            if (eventName.isNotBlank()) add(eventLabel to eventName)
            if (athleteName.isNotBlank()) add(athleteLabel to athleteName)
            if (workoutTitle.isNotBlank()) add(workoutLabel to workoutTitle)
        }
        val timerLines = buildTimerLines(elapsedSeconds)

        if (timerLines.isNotEmpty()) {
            val timerHeight = measurePanelHeight(timerLines, panelWidth, scale)
            drawPanel(
                canvas = canvas,
                left = width - panelWidth - margin,
                top = height - timerHeight - margin,
                width = panelWidth,
                lines = timerLines,
                scale = scale,
            )
        }

        if (metadataLines.isNotEmpty()) {
            val metadataHeight = measurePanelHeight(metadataLines, panelWidth, scale)
            val rightReserve = if (timerLines.isNotEmpty()) panelWidth + panelGap else 0f
            val availableWidth = width - (margin * 2) - rightReserve
            val metadataWidth = min(panelWidth, max(280f * scale, availableWidth))
            drawPanel(
                canvas = canvas,
                left = margin,
                top = height - metadataHeight - margin,
                width = metadataWidth,
                lines = metadataLines,
                scale = scale,
            )
        }

        return bitmap
    }

    private fun measurePanelHeight(
        lines: List<Pair<String, String>>,
        width: Float,
        scale: Float,
    ): Float {
        val padding = 18f * scale
        val labelPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = 12f * scale
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            letterSpacing = 0.08f
        }
        val valuePaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = 19f * scale
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        val contentWidth = (width - padding * 2).toInt()
        var contentHeight = padding
        lines.forEach { (label, value) ->
            val labelLayout = staticLayout(label.uppercase(Locale.US), labelPaint, contentWidth)
            val valueLayout = staticLayout(value, valuePaint, contentWidth)
            contentHeight += labelLayout.height + 4f * scale + valueLayout.height + 10f * scale
        }
        return contentHeight + padding - 10f * scale
    }

    private fun drawPanel(
        canvas: Canvas,
        left: Float,
        top: Float,
        width: Float,
        lines: List<Pair<String, String>>,
        scale: Float,
    ) {
        val padding = 18f * scale
        val labelPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(170, 255, 255, 255)
            textSize = 12f * scale
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            letterSpacing = 0.08f
        }
        val valuePaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 19f * scale
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        val contentWidth = (width - padding * 2).toInt()
        var contentHeight = padding
        val layouts = lines.map { (label, value) ->
            val labelLayout = staticLayout(label.uppercase(Locale.US), labelPaint, contentWidth)
            val valueLayout = staticLayout(value, valuePaint, contentWidth)
            contentHeight += labelLayout.height + 4f * scale + valueLayout.height + 10f * scale
            labelLayout to valueLayout
        }
        contentHeight += padding - 10f * scale

        val background = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(150, 0, 0, 0)
        }
        val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(55, 255, 255, 255)
            style = Paint.Style.STROKE
            strokeWidth = 1.5f * scale
        }
        val rect = RectF(left, top, left + width, top + contentHeight)
        canvas.drawRoundRect(rect, 16f * scale, 16f * scale, background)
        canvas.drawRoundRect(rect, 16f * scale, 16f * scale, stroke)

        var y = top + padding
        layouts.forEach { (labelLayout, valueLayout) ->
            canvas.save()
            canvas.translate(left + padding, y)
            labelLayout.draw(canvas)
            canvas.restore()
            y += labelLayout.height + 4f * scale
            canvas.save()
            canvas.translate(left + padding, y)
            valueLayout.draw(canvas)
            canvas.restore()
            y += valueLayout.height + 10f * scale
        }
    }

    private fun staticLayout(text: String, paint: TextPaint, width: Int): StaticLayout {
        return StaticLayout.Builder
            .obtain(text, 0, text.length, paint, width)
            .setAlignment(Layout.Alignment.ALIGN_NORMAL)
            .setLineSpacing(0f, 1.05f)
            .setIncludePad(false)
            .build()
    }

    private fun buildTimerLines(elapsedSeconds: Int): List<Pair<String, String>> {
        if (countdownSeconds > 0 && elapsedSeconds < countdownSeconds) {
            val remaining = countdownSeconds - elapsedSeconds
            return listOf(
                countdownLabel to startsInLabel,
                remainingLabel to "${remaining}s",
            )
        }

        val workoutElapsedSeconds = max(elapsedSeconds - countdownSeconds, 0)
        return when (timerType) {
            "emom" -> {
                val interval = timerIntervalSeconds ?: 60
                val rounds = timerRounds ?: 0
                val roundIndex = workoutElapsedSeconds / interval + 1
                val currentRound = if (rounds > 0) min(roundIndex, rounds) else roundIndex
                val primary = if (rounds > 0) {
                    "$roundLabel $currentRound/$rounds"
                } else {
                    "$roundLabel $currentRound"
                }
                val remaining = interval - (workoutElapsedSeconds % interval)
                listOf(
                    "EMOM" to primary,
                    nextStartLabel to formatSeconds(remaining),
                    elapsedLabel to formatSeconds(workoutElapsedSeconds),
                )
            }
            "amrap" -> {
                val total = timerTotalSeconds ?: 0
                val remaining = max(total - workoutElapsedSeconds, 0)
                listOf(
                    "AMRAP" to "${formatSeconds(remaining)} $remainingSuffix",
                    elapsedLabel to formatSeconds(workoutElapsedSeconds),
                )
            }
            "forTime" -> {
                val total = timerTotalSeconds ?: 0
                val remaining = max(total - workoutElapsedSeconds, 0)
                listOf(
                    "For Time" to "${formatSeconds(workoutElapsedSeconds)} $elapsedSuffix",
                    remainingLabel to formatSeconds(remaining),
                )
            }
            else -> emptyList()
        }
    }

    private fun formatSeconds(totalSeconds: Int): String {
        val minutes = totalSeconds / 60
        val seconds = totalSeconds % 60
        return "%02d:%02d".format(Locale.US, minutes, seconds)
    }
}
