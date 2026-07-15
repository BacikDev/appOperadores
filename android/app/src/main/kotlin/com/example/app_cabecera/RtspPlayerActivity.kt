package com.example.app_cabecera

import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.rtsp.RtspMediaSource
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView

class RtspPlayerActivity : ComponentActivity() {

    companion object {
        const val EXTRA_TITLE = "title"
        const val EXTRA_RTSP_URL = "rtspUrl"
        const val EXTRA_STREAM_ID = "streamId"
    }

    private lateinit var playerView: PlayerView
    private lateinit var progressBar: ProgressBar
    private lateinit var statusText: TextView
    private lateinit var titleText: TextView
    private lateinit var playPauseButton: Button
    private lateinit var reconnectButton: Button

    private var player: ExoPlayer? = null

    private var cameraTitle = "Cámara"
    private var rtspUrl = ""
    private var streamId = ""

    private var isPlayerReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        cameraTitle =
            intent.getStringExtra(EXTRA_TITLE) ?: "Cámara"

        rtspUrl =
            intent.getStringExtra(EXTRA_RTSP_URL) ?: ""

        streamId =
            intent.getStringExtra(EXTRA_STREAM_ID) ?: ""

        if (rtspUrl.isBlank()) {
            Toast.makeText(
                this,
                "No se recibió la URL RTSP.",
                Toast.LENGTH_LONG
            ).show()

            finish()
            return
        }

        setContentView(createContentView())

        openRtspStream()
    }

    private fun createContentView(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.rgb(7, 17, 31))
        }

        val header = createHeader()
        val videoContainer = createVideoContainer()
        val controls = createControls()

        root.addView(
            header,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        )

        root.addView(
            videoContainer,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0,
                1f
            )
        )

        root.addView(
            controls,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        )

        return root
    }

    private fun createHeader(): View {
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(
                10.dp,
                8.dp,
                14.dp,
                8.dp
            )
            setBackgroundColor(Color.rgb(11, 22, 38))
        }

        val backButton = Button(this).apply {
            text = "‹"
            textSize = 30f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.TRANSPARENT)
            isAllCaps = false

            setOnClickListener {
                finish()
            }
        }

        titleText = TextView(this).apply {
            setTextColor(Color.WHITE)
            textSize = 17f
            gravity = Gravity.CENTER_VERTICAL

            text = if (streamId.isBlank()) {
                cameraTitle
            } else {
                "$cameraTitle\nCanal $streamId"
            }
        }

        val liveBadge = TextView(this).apply {
            text = "● EN VIVO"
            textSize = 12f
            setTextColor(Color.rgb(76, 255, 139))
            gravity = Gravity.CENTER
            setPadding(
                12.dp,
                8.dp,
                12.dp,
                8.dp
            )
            setBackgroundColor(Color.rgb(18, 58, 44))
        }

        header.addView(
            backButton,
            LinearLayout.LayoutParams(
                54.dp,
                54.dp
            )
        )

        header.addView(
            titleText,
            LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        )

        header.addView(
            liveBadge,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        )

        return header
    }

    private fun createVideoContainer(): View {
        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.BLACK)
        }

        playerView = PlayerView(this).apply {
            useController = false
            resizeMode =
                AspectRatioFrameLayout.RESIZE_MODE_FIT

            setBackgroundColor(Color.BLACK)
        }

        progressBar = ProgressBar(this).apply {
            isIndeterminate = true
            visibility = View.VISIBLE
        }

        statusText = TextView(this).apply {
            text = "Conectando con el DVR..."
            setTextColor(Color.WHITE)
            textSize = 14f
            gravity = Gravity.CENTER
            setPadding(
                14.dp,
                9.dp,
                14.dp,
                9.dp
            )
            setBackgroundColor(
                Color.argb(
                    175,
                    0,
                    0,
                    0
                )
            )
        }

        container.addView(
            playerView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        container.addView(
            progressBar,
            FrameLayout.LayoutParams(
                56.dp,
                56.dp,
                Gravity.CENTER
            )
        )

        container.addView(
            statusText,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER_HORIZONTAL or Gravity.BOTTOM
            ).apply {
                bottomMargin = 24.dp
            }
        )

        return container
    }

    private fun createControls(): View {
        val controls = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(
                10.dp,
                10.dp,
                10.dp,
                10.dp
            )
            setBackgroundColor(Color.rgb(16, 28, 45))
        }

        playPauseButton = createControlButton(
            "Pausar"
        ) {
            togglePlayPause()
        }

        reconnectButton = createControlButton(
            "Reconectar"
        ) {
            openRtspStream()
        }

        controls.addView(
            playPauseButton,
            weightedButtonParams()
        )

        controls.addView(
            reconnectButton,
            weightedButtonParams()
        )

        return controls
    }

    private fun createControlButton(
        label: String,
        action: () -> Unit
    ): Button {
        return Button(this).apply {
            text = label
            isAllCaps = false
            textSize = 14f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.rgb(20, 43, 69))

            setOnClickListener {
                action()
            }
        }
    }

    private fun weightedButtonParams():
        LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(
            0,
            LinearLayout.LayoutParams.WRAP_CONTENT,
            1f
        ).apply {
            marginStart = 5.dp
            marginEnd = 5.dp
        }
    }

    private fun openRtspStream() {
        showLoading(
            "Conectando con el DVR..."
        )

        releasePlayer()

        val newPlayer =
            ExoPlayer.Builder(this).build()

        player = newPlayer
        playerView.player = newPlayer

        newPlayer.addListener(
            object : Player.Listener {

                override fun onPlaybackStateChanged(
                    playbackState: Int
                ) {
                    when (playbackState) {
                        Player.STATE_IDLE -> {
                            isPlayerReady = false
                        }

                        Player.STATE_BUFFERING -> {
                            isPlayerReady = false

                            showLoading(
                                "Cargando video..."
                            )
                        }

                        Player.STATE_READY -> {
                            isPlayerReady = true

                            progressBar.visibility =
                                View.GONE

                            statusText.text =
                                "EN VIVO"

                            statusText.visibility =
                                View.VISIBLE

                            playPauseButton.text =
                                if (newPlayer.isPlaying) {
                                    "Pausar"
                                } else {
                                    "Reproducir"
                                }
                        }

                        Player.STATE_ENDED -> {
                            isPlayerReady = false

                            progressBar.visibility =
                                View.GONE

                            statusText.text =
                                "La transmisión finalizó."

                            statusText.visibility =
                                View.VISIBLE

                            playPauseButton.text =
                                "Reproducir"
                        }
                    }
                }

                override fun onIsPlayingChanged(
                    isPlaying: Boolean
                ) {
                    playPauseButton.text =
                        if (isPlaying) {
                            "Pausar"
                        } else {
                            "Reproducir"
                        }

                    if (
                        isPlayerReady &&
                        !isPlaying
                    ) {
                        statusText.text =
                            "Transmisión pausada"

                        statusText.visibility =
                            View.VISIBLE
                    }

                    if (
                        isPlayerReady &&
                        isPlaying
                    ) {
                        statusText.text =
                            "EN VIVO"

                        statusText.visibility =
                            View.VISIBLE
                    }
                }

                override fun onPlayerError(
                    error: PlaybackException
                ) {
                    isPlayerReady = false

                    progressBar.visibility =
                        View.GONE

                    statusText.text =
                        "No se pudo abrir la transmisión.\n" +
                        getReadableError(error)

                    statusText.visibility =
                        View.VISIBLE

                    playPauseButton.text =
                        "Reproducir"
                }
            }
        )

        try {
            val mediaItem =
                MediaItem.fromUri(rtspUrl)

            val mediaSource =
                RtspMediaSource.Factory()
                    .setForceUseRtpTcp(true)
                    .setTimeoutMs(20_000)
                    .createMediaSource(mediaItem)

            newPlayer.setMediaSource(
                mediaSource
            )

            newPlayer.prepare()
            newPlayer.playWhenReady = true
        } catch (error: Exception) {
            progressBar.visibility =
                View.GONE

            statusText.text =
                "Error preparando el reproductor.\n" +
                (error.message ?: "Error desconocido")

            statusText.visibility =
                View.VISIBLE
        }
    }

    private fun togglePlayPause() {
        val currentPlayer = player ?: return

        if (currentPlayer.isPlaying) {
            currentPlayer.pause()
        } else {
            if (
                currentPlayer.playbackState ==
                Player.STATE_ENDED
            ) {
                currentPlayer.seekTo(0)
            }

            currentPlayer.play()
        }
    }

    private fun showLoading(
        message: String
    ) {
        progressBar.visibility =
            View.VISIBLE

        statusText.text =
            message

        statusText.visibility =
            View.VISIBLE
    }

    private fun getReadableError(
        error: PlaybackException
    ): String {
        return when (
            error.errorCode
        ) {
            PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED ->
                "No se pudo conectar con el DVR."

            PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT ->
                "La conexión con el DVR agotó el tiempo de espera."

            PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS ->
                "El DVR rechazó la conexión."

            PlaybackException.ERROR_CODE_PARSING_CONTAINER_UNSUPPORTED ->
                "Formato de transmisión no compatible."

            PlaybackException.ERROR_CODE_DECODING_FAILED ->
                "El dispositivo no pudo decodificar el video."

            else ->
                error.message ?: "Error RTSP desconocido."
        }
    }

    private fun releasePlayer() {
        playerView.player = null

        player?.run {
            stop()
            clearMediaItems()
            release()
        }

        player = null
        isPlayerReady = false
    }

    override fun onStart() {
        super.onStart()

        if (
            player == null &&
            rtspUrl.isNotBlank()
        ) {
            openRtspStream()
        }
    }

    override fun onStop() {
        player?.pause()
        super.onStop()
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }

    private val Int.dp: Int
        get() = (
            this *
            resources.displayMetrics.density
        ).toInt()
}