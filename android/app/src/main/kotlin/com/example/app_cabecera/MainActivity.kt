package com.example.app_cabecera

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL_NAME =
            "app_cabecera/rtsp_player"
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

                    val streamId =
                        call.argument<String>("streamId")
                            ?: ""

                    if (rtspUrl.isNullOrBlank()) {
                        result.error(
                            "missing-url",
                            "No se recibió la URL RTSP.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val intent = Intent(
                            this,
                            RtspPlayerActivity::class.java
                        ).apply {
                            putExtra(
                                RtspPlayerActivity.EXTRA_TITLE,
                                title
                            )

                            putExtra(
                                RtspPlayerActivity.EXTRA_RTSP_URL,
                                rtspUrl
                            )

                            putExtra(
                                RtspPlayerActivity.EXTRA_STREAM_ID,
                                streamId
                            )
                        }

                        startActivity(intent)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "open-player-error",
                            "No se pudo abrir el reproductor RTSP.",
                            error.message
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}