package com.example.app_cabecera

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val RTSP_CHANNEL =
            "app_cabecera/rtsp_player"

        private const val SYSTEM_STATUS_CHANNEL =
            "app_cabecera/system_status"

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

        configureRtspChannel(flutterEngine)
        configureSystemStatusChannel(flutterEngine)
    }

    private fun configureSystemStatusChannel(
        flutterEngine: FlutterEngine
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SYSTEM_STATUS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasInternet" -> result.success(hasInternet())
                "isVpnActive" -> result.success(isVpnActive())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasInternet(): Boolean {
        val manager = getSystemService(
            Context.CONNECTIVITY_SERVICE
        ) as ConnectivityManager

        val network = manager.activeNetwork ?: return false
        val capabilities =
            manager.getNetworkCapabilities(network) ?: return false

        return capabilities.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_INTERNET
        ) && capabilities.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_VALIDATED
        )
    }

    private fun isVpnActive(): Boolean {
        val manager = getSystemService(
            Context.CONNECTIVITY_SERVICE
        ) as ConnectivityManager

        return manager.allNetworks.any { network ->
            manager.getNetworkCapabilities(network)
                ?.hasTransport(
                    NetworkCapabilities.TRANSPORT_VPN
                ) == true
        }
    }

    private fun configureRtspChannel(
        flutterEngine: FlutterEngine
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RTSP_CHANNEL
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