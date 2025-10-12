package ch.joshuahemmings.wodreplog

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val overlayExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != METHOD_APPLY_OVERLAY) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val videoPath = call.argument<String>("videoPath")
                val overlayPath = call.argument<String>("overlayPath")
                val outputPath = call.argument<String>("outputPath")
                val marginLeft = call.argument<Int>("marginLeft") ?: 0
                val marginBottom = call.argument<Int>("marginBottom") ?: 0

                if (videoPath.isNullOrBlank() || overlayPath.isNullOrBlank() || outputPath.isNullOrBlank()) {
                    result.error(
                        "invalid_arguments",
                        "Video, overlay, and output paths are required.",
                        null
                    )
                    return@setMethodCallHandler
                }

                overlayExecutor.execute {
                    try {
                        val composedPath = VideoOverlayComposer(applicationContext).compose(
                            videoPath = videoPath,
                            overlayPath = overlayPath,
                            outputPath = outputPath,
                            marginLeftPx = marginLeft,
                            marginBottomPx = marginBottom
                        )
                        mainHandler.post { result.success(composedPath) }
                    } catch (e: Exception) {
                        mainHandler.post {
                            result.error(
                                "overlay_failed",
                                e.message ?: "Overlay composition failed.",
                                e.stackTraceToString()
                            )
                        }
                    }
                }
            }
    }

    override fun detachFromFlutterEngine() {
        super.detachFromFlutterEngine()
        overlayExecutor.shutdownNow()
    }

    companion object {
        private const val CHANNEL = "wodreplog/video_overlay"
        private const val METHOD_APPLY_OVERLAY = "applyOverlay"
    }
}
