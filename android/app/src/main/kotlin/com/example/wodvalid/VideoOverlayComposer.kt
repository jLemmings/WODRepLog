@file:OptIn(UnstableApi::class)

package ch.joshuahemmings.wodreplog

import android.content.Context
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.OverlaySettings
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.TransformationException
import androidx.media3.transformer.TransformationRequest
import androidx.media3.transformer.TransformationResult
import androidx.media3.transformer.Transformer
import com.google.common.collect.ImmutableList
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference
import kotlin.math.max

class VideoOverlayComposer(private val context: Context) {

    fun compose(
        videoPath: String,
        overlayPath: String,
        outputPath: String,
        marginLeftPx: Int,
        marginBottomPx: Int
    ): String {
        val videoFile = File(videoPath)
        require(videoFile.exists()) { "Recorded video not found at $videoPath." }
        val overlayFile = File(overlayPath)
        require(overlayFile.exists()) { "Overlay image not found at $overlayPath." }

        val dimensions = resolveVideoDimensions(videoPath)
        val overlayBitmap = BitmapFactory.decodeFile(overlayPath)
            ?: throw IllegalStateException("Unable to decode overlay bitmap.")

        val scaleX = (overlayBitmap.width.toFloat() / dimensions.width).coerceIn(0f, 1f)
        val scaleY = (overlayBitmap.height.toFloat() / dimensions.height).coerceIn(0f, 1f)
        val anchorX = (marginLeftPx.toFloat() / dimensions.width).coerceIn(0f, 1f)
        val anchorY = (1f - marginBottomPx.toFloat() / dimensions.height).coerceIn(0f, 1f)

        val overlaySettings = OverlaySettings.Builder()
            .setAlphaScale(1f)
            .setOverlayFrameAnchor(0f, 1f)
            .setBackgroundFrameAnchor(anchorX, anchorY)
            .setScale(max(scaleX, 0.0001f), max(scaleY, 0.0001f))
            .build()

        val textureOverlay = BitmapOverlay.createStaticBitmapOverlay(overlayBitmap, overlaySettings)
        val overlayEffect = OverlayEffect(ImmutableList.of(textureOverlay))

        val effects = Effects(emptyList(), listOf(overlayEffect))
        val mediaItem = MediaItem.fromUri(Uri.fromFile(videoFile))
        val editedMediaItem = EditedMediaItem.Builder(mediaItem)
            .setEffects(effects)
            .build()

        val transformer = Transformer.Builder(context).build()
        val latch = CountDownLatch(1)
        val errorRef = AtomicReference<Exception?>()

        val listener = VideoOverlayListener(object : VideoOverlayListener.Callback {
            override fun onCompleted() {
                latch.countDown()
            }

            override fun onError(exception: Exception) {
                errorRef.set(exception)
                latch.countDown()
            }
        })

        transformer.addListener(listener)

        try {
            transformer.start(editedMediaItem, outputPath)
            if (!latch.await(180, TimeUnit.SECONDS)) {
                transformer.cancel()
                throw IllegalStateException("Overlay composition timed out.")
            }
            errorRef.get()?.let { throw it }
            return outputPath
        } finally {
            overlayBitmap.recycle()
            transformer.removeListener(listener)
        }
    }

    private fun resolveVideoDimensions(path: String): VideoDimensions {
        val retriever = MediaMetadataRetriever()
        retriever.setDataSource(path)
        val width = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull()
            ?: throw IllegalStateException("Unable to read video width.")
        val height = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull()
            ?: throw IllegalStateException("Unable to read video height.")
        val rotation = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
        retriever.release()

        return if (rotation == 90 || rotation == 270) {
            VideoDimensions(width = height.toFloat(), height = width.toFloat())
        } else {
            VideoDimensions(width.toFloat(), height.toFloat())
        }
    }

    private data class VideoDimensions(val width: Float, val height: Float)
}

private class VideoOverlayListener(
    private val callback: Callback,
) : Transformer.Listener {

    interface Callback {
        fun onCompleted()
        fun onError(exception: Exception)
    }

    override fun onTransformationCompleted(mediaItem: MediaItem) {
        callback.onCompleted()
    }

    override fun onTransformationCompleted(
        mediaItem: MediaItem,
        transformationResult: TransformationResult,
    ) {
        callback.onCompleted()
    }

    override fun onTransformationError(mediaItem: MediaItem, exception: Exception) {
        callback.onError(exception)
    }

    override fun onTransformationError(
        mediaItem: MediaItem,
        transformationResult: TransformationResult,
        exception: TransformationException,
    ) {
        callback.onError(exception)
    }

    override fun onFallbackApplied(
        mediaItem: MediaItem,
        originalTransformationRequest: TransformationRequest,
        fallbackTransformationRequest: TransformationRequest,
    ) = Unit

    override fun onFallbackApplied(
        composition: Composition,
        originalTransformationRequest: TransformationRequest,
        fallbackTransformationRequest: TransformationRequest,
    ) = Unit
}
