package com.example.app_cabecera

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME = "app_cabecera/rtsp_player"

        private const val RTSP_ACTIVITY_CLASS =
            "com.example.app_cabecera.RtspPlayerActivity"

        private const val EXTRA_TITLE = "title"
        private const val EXTRA_RTSP_URL = "rtspUrl"
        private const val EXTRA_STREAM_ID = "streamId"
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "openRtspPlayer" -> {
                    val title =
                        call.argument<String>("title")
                            ?: "Cámara"

                    val rtspUrl =
                        call.argument<String>("rtspUrl")
                            ?.trim()
                            .orEmpty()

                    val streamId =
                        call.argument<String>("streamId")
                            ?.trim()
                            .orEmpty()

                    if (rtspUrl.isBlank()) {
                        result.error(
                            "INVALID_RTSP_URL",
                            "La URL RTSP está vacía.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val intent = Intent().apply {
                            setClassName(
                                this@MainActivity,
                                RTSP_ACTIVITY_CLASS
                            )

                            putExtra(EXTRA_TITLE, title)
                            putExtra(EXTRA_RTSP_URL, rtspUrl)
                            putExtra(EXTRA_STREAM_ID, streamId)
                        }

                        startActivity(intent)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error(
                            "OPEN_RTSP_ERROR",
                            error.message
                                ?: "No se pudo abrir el reproductor RTSP.",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}