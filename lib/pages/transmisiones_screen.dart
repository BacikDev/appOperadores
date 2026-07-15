import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum _StreamId {
  canal2,
  ecc,
}

class _StreamData {
  final _StreamId id;
  final String titulo;
  final String descripcion;
  final String url;
  final IconData icon;

  const _StreamData({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.icon,
  });
}

class TransmisionesScreen extends StatefulWidget {
  const TransmisionesScreen({super.key});

  @override
  State<TransmisionesScreen> createState() =>
      _TransmisionesScreenState();
}

class _TransmisionesScreenState extends State<TransmisionesScreen>
    with WidgetsBindingObserver {
  static const _StreamData _canal2 = _StreamData(
    id: _StreamId.canal2,
    titulo: 'SEÑAL 1 - CANAL 2',
    descripcion: 'Transmisión principal de Canal 2',
    url: 'http://192.168.194.143:8888/canal2/index.m3u8',
    icon: Icons.live_tv_rounded,
  );

  static const _StreamData _ecc = _StreamData(
    id: _StreamId.ecc,
    titulo: 'SEÑAL 2 - ECC',
    descripcion: 'Transmisión interna ECC',
    url: 'http://192.168.194.19:8888/ecc/index.m3u8',
    icon: Icons.connected_tv_rounded,
  );

  VideoPlayerController? _controller;
  _StreamData? _streamActivo;

  bool _estaCargando = false;
  bool _hayError = false;
  String? _mensajeError;

  Timer? _bufferingTimer;

  // Evita que una inicialización antigua modifique el estado
  // después de seleccionar otra señal.
  int _sesionActual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      controller.pause();
    }

    if (state == AppLifecycleState.resumed &&
        _streamActivo != null &&
        !_hayError) {
      controller.play();
    }
  }

  Future<void> _seleccionarTransmision(_StreamData stream) async {
    if (_streamActivo?.id == stream.id &&
        _controller?.value.isInitialized == true &&
        !_hayError) {
      await _controller?.play();
      return;
    }

    final int sesion = ++_sesionActual;

    await _liberarController();

    if (!mounted || sesion != _sesionActual) return;

    setState(() {
      _streamActivo = stream;
      _estaCargando = true;
      _hayError = false;
      _mensajeError = null;
    });

    final nuevoController = VideoPlayerController.networkUrl(
      Uri.parse(stream.url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
    );

    _controller = nuevoController;
    nuevoController.addListener(_escucharController);

    try {
      await nuevoController.initialize();

      if (!mounted || sesion != _sesionActual) {
        nuevoController.removeListener(_escucharController);
        await nuevoController.dispose();
        return;
      }

      await nuevoController.setLooping(false);
      await nuevoController.setVolume(1);
      await nuevoController.play();

      if (!mounted || sesion != _sesionActual) return;

      setState(() {
        _estaCargando = false;
        _hayError = false;
        _mensajeError = null;
      });
    } catch (error) {
      if (!mounted || sesion != _sesionActual) return;

      setState(() {
        _estaCargando = false;
        _hayError = true;
        _mensajeError = _limpiarMensajeError(error.toString());
      });
    }
  }

  void _escucharController() {
    final controller = _controller;

    if (controller == null || !mounted) return;

    final value = controller.value;

    if (value.hasError) {
      _bufferingTimer?.cancel();

      setState(() {
        _estaCargando = false;
        _hayError = true;
        _mensajeError =
            value.errorDescription ?? 'Se perdió la transmisión.';
      });

      return;
    }

    if (value.isBuffering && value.isInitialized) {
      _iniciarTemporizadorBuffering();
    } else {
      _bufferingTimer?.cancel();
    }

    setState(() {});
  }

  void _iniciarTemporizadorBuffering() {
    if (_bufferingTimer?.isActive == true) return;

    _bufferingTimer = Timer(
      const Duration(seconds: 12),
      () {
        if (!mounted) return;

        final controller = _controller;

        if (controller != null &&
            controller.value.isInitialized &&
            controller.value.isBuffering &&
            _streamActivo != null) {
          _reconectarTransmision();
        }
      },
    );
  }

  Future<void> _reconectarTransmision() async {
    final stream = _streamActivo;

    if (stream == null) return;

    await _seleccionarTransmision(stream);
  }

  Future<void> _detenerTransmision() async {
    ++_sesionActual;

    await _liberarController();

    if (!mounted) return;

    setState(() {
      _streamActivo = null;
      _estaCargando = false;
      _hayError = false;
      _mensajeError = null;
    });
  }

  Future<void> _liberarController() async {
    _bufferingTimer?.cancel();
    _bufferingTimer = null;

    final controllerAnterior = _controller;
    _controller = null;

    if (controllerAnterior != null) {
      controllerAnterior.removeListener(_escucharController);

      try {
        await controllerAnterior.pause();
      } catch (_) {}

      try {
        await controllerAnterior.dispose();
      } catch (_) {}
    }
  }

  Future<void> _actualizar() async {
    if (_streamActivo != null) {
      await _reconectarTransmision();
    }
  }

  void _abrirPantallaCompleta() {
    final controller = _controller;
    final stream = _streamActivo;

    if (controller == null ||
        stream == null ||
        !controller.value.isInitialized) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransmisionFullscreenScreen(
          titulo: stream.titulo,
          controller: controller,
        ),
      ),
    );
  }

  String _limpiarMensajeError(String mensaje) {
    return mensaje
        .replaceFirst('PlatformException(', '')
        .replaceFirst('VideoError, ', '')
        .trim();
  }

  bool _esStreamActivo(_StreamData stream) {
    return _streamActivo?.id == stream.id;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _bufferingTimer?.cancel();

    final controller = _controller;
    _controller = null;

    if (controller != null) {
      controller.removeListener(_escucharController);
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF030014),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 82,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF8B5CFF),
          ),
        ),
        title: const _AppLogo(),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF8B5CFF),
        backgroundColor: const Color(0xFF07192B),
        onRefresh: _actualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            const _ScreenHeader(),
            const SizedBox(height: 22),

            StreamCard(
              stream: _canal2,
              activo: _esStreamActivo(_canal2),
              controller:
                  _esStreamActivo(_canal2) ? _controller : null,
              estaCargando:
                  _esStreamActivo(_canal2) && _estaCargando,
              hayError: _esStreamActivo(_canal2) && _hayError,
              mensajeError:
                  _esStreamActivo(_canal2) ? _mensajeError : null,
              onPlay: () => _seleccionarTransmision(_canal2),
              onStop: _detenerTransmision,
              onRetry: _reconectarTransmision,
              onFullscreen: _abrirPantallaCompleta,
            ),

            const SizedBox(height: 18),

            StreamCard(
              stream: _ecc,
              activo: _esStreamActivo(_ecc),
              controller: _esStreamActivo(_ecc) ? _controller : null,
              estaCargando: _esStreamActivo(_ecc) && _estaCargando,
              hayError: _esStreamActivo(_ecc) && _hayError,
              mensajeError:
                  _esStreamActivo(_ecc) ? _mensajeError : null,
              onPlay: () => _seleccionarTransmision(_ecc),
              onStop: _detenerTransmision,
              onRetry: _reconectarTransmision,
              onFullscreen: _abrirPantallaCompleta,
            ),

            const SizedBox(height: 18),
            const _InformationCard(),
          ],
        ),
      ),
    );
  }
}

class StreamCard extends StatefulWidget {
  final _StreamData stream;
  final bool activo;
  final VideoPlayerController? controller;
  final bool estaCargando;
  final bool hayError;
  final String? mensajeError;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onRetry;
  final VoidCallback onFullscreen;

  const StreamCard({
    super.key,
    required this.stream,
    required this.activo,
    required this.controller,
    required this.estaCargando,
    required this.hayError,
    required this.mensajeError,
    required this.onPlay,
    required this.onStop,
    required this.onRetry,
    required this.onFullscreen,
  });

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final inicializado = controller?.value.isInitialized == true;
    final reproduciendo = controller?.value.isPlaying == true;
    final silenciado = controller?.value.volume == 0;
    final buffering = controller?.value.isBuffering == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: const Color(0xFF06182A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.activo
              ? const Color(0xFF8B5CFF)
              : const Color(0xFF1E3D54),
          width: widget.activo ? 1.7 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.activo
                ? const Color(0xFF8B5CFF).withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
              child: Row(
                children: [
                  Icon(
                    widget.stream.icon,
                    color: const Color(0xFF8B5CFF),
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.stream.titulo,
                      style: const TextStyle(
                        color: Color(0xFF9A63FF),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StreamStatus(
                    activo: widget.activo,
                    cargando: widget.estaCargando || buffering,
                    error: widget.hayError,
                  ),
                ],
              ),
            ),

            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildContenidoVideo(),

                    if (widget.activo &&
                        inicializado &&
                        !widget.hayError)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE72C3B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.white,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'EN VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (widget.activo &&
                        buffering &&
                        !widget.hayError)
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF8B5CFF),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Recuperando transmisión...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (widget.activo && inicializado && controller != null)
  Container(
    height: 58,
    decoration: const BoxDecoration(
      color: Color(0xFF071321),
      border: Border(
        top: BorderSide(
          color: Color(0xFF1B2D3E),
        ),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        IconButton(
          tooltip: reproduciendo ? 'Pausar' : 'Reproducir',
          onPressed: () async {
            final activeController = widget.controller;

            if (activeController == null) return;

            if (activeController.value.isPlaying) {
              await activeController.pause();
            } else {
              await activeController.play();
            }

            if (mounted) {
              setState(() {});
            }
          },
          icon: Icon(
            reproduciendo
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 31,
          ),
        ),

        IconButton(
          tooltip: silenciado
              ? 'Activar sonido'
              : 'Silenciar',
          onPressed: () async {
            final activeController = widget.controller;

            if (activeController == null) return;

            final estaSilenciado =
                activeController.value.volume == 0;

            await activeController.setVolume(
              estaSilenciado ? 1 : 0,
            );

            if (mounted) {
              setState(() {});
            }
          },
          icon: Icon(
            silenciado
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),

        const SizedBox(width: 4),

        const CircleAvatar(
          radius: 4,
          backgroundColor: Color(0xFFFF4054),
        ),

        const SizedBox(width: 7),

        const Text(
          'EN VIVO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        const Spacer(),

        IconButton(
          tooltip: 'Reconectar',
          onPressed: widget.onRetry,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Color(0xFF9AA8BB),
          ),
        ),

        IconButton(
          tooltip: 'Pantalla completa',
          onPressed: widget.onFullscreen,
          icon: const Icon(
            Icons.fullscreen_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),

        IconButton(
          tooltip: 'Cerrar transmisión',
          onPressed: widget.onStop,
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFFFF5A72),
            size: 26,
          ),
        ),
      ],
    ),
  ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF06182A),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF1B2D3E),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.stream.descripcion,
                      style: const TextStyle(
                        color: Color(0xFF9AA4B7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!widget.activo)
                    FilledButton.icon(
                      onPressed: widget.onPlay,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 22,
                      ),
                      label: const Text(
                        'Ver',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: widget.onStop,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5A72),
                        side: const BorderSide(
                          color: Color(0xFFFF5A72),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.stop_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        'Detener',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoVideo() {
    if (!widget.activo) {
      return _StreamPlaceholder(
        icon: widget.stream.icon,
        onPlay: widget.onPlay,
      );
    }

    if (widget.hayError) {
      return _StreamError(
        message: widget.mensajeError,
        onRetry: widget.onRetry,
      );
    }

    if (widget.estaCargando ||
        widget.controller?.value.isInitialized != true) {
      return const _StreamLoading();
    }

    final controller = widget.controller!;

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class TransmisionFullscreenScreen extends StatefulWidget {
  final String titulo;
  final VideoPlayerController controller;

  const TransmisionFullscreenScreen({
    super.key,
    required this.titulo,
    required this.controller,
  });

  @override
  State<TransmisionFullscreenScreen> createState() =>
      _TransmisionFullscreenScreenState();
}

class _TransmisionFullscreenScreenState
    extends State<TransmisionFullscreenScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_actualizar);
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_actualizar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final reproduciendo = value.isPlaying;
    final silenciado = value.volume == 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio > 0
                    ? value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(widget.controller),
              ),
            ),

            if (value.isBuffering)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Color(0xFF8B5CFF),
                ),
              ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.6),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (reproduciendo) {
                          await widget.controller.pause();
                        } else {
                          await widget.controller.play();
                        }
                      },
                      icon: Icon(
                        reproduciendo
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await widget.controller.setVolume(
                          silenciado ? 1 : 0,
                        );
                      },
                      icon: Icon(
                        silenciado
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFFF4054),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'EN VIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.fullscreen_exit_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamPlaceholder extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPlay;

  const _StreamPlaceholder({
    required this.icon,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07192B),
            Color(0xFF030814),
          ],
        ),
      ),
      child: Center(
        child: InkWell(
          onTap: onPlay,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF8B5CFF).withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 45,
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamStatus extends StatelessWidget {
  final bool activo;
  final bool cargando;
  final bool error;

  const _StreamStatus({
    required this.activo,
    required this.cargando,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String texto;
    IconData icon;

    if (error) {
      color = const Color(0xFFFF5A72);
      texto = 'SIN SEÑAL';
      icon = Icons.error_outline_rounded;
    } else if (cargando) {
      color = const Color(0xFFFFC857);
      texto = 'CARGANDO';
      icon = Icons.sync_rounded;
    } else if (activo) {
      color = const Color(0xFF20D99A);
      texto = 'EN VIVO';
      icon = Icons.circle;
    } else {
      color = const Color(0xFF7C879B);
      texto = 'DETENIDA';
      icon = Icons.stop_circle_outlined;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: activo && !cargando && !error ? 10 : 17,
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.tv_rounded,
          color: Color(0xFF8B5CFF),
          size: 35,
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EL LÍDER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'J u n t o   a   V o s',
              style: TextStyle(
                color: Color(0xFF9AA0B5),
                fontSize: 9,
                letterSpacing: 1.7,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.sensors_rounded,
            color: Color(0xFF8B5CFF),
            size: 31,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSMISIONES EN VIVO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Seleccioná una señal para comenzar',
                style: TextStyle(
                  color: Color(0xFF929BB0),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreamLoading extends StatelessWidget {
  const _StreamLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020812),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8B5CFF),
          ),
          SizedBox(height: 14),
          Text(
            'Conectando con MediaMTX...',
            style: TextStyle(
              color: Color(0xFFAAB2C2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _StreamError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020812),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.signal_wifi_connected_no_internet_4_rounded,
            color: Color(0xFFFF4669),
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'No se pudo cargar la señal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message ?? 'Verificá OBS, MediaMTX y la conexión.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8E98A9),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CFF),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reconectar'),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF06182A),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFF1E3D54),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF8B5CFF),
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF090316),
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Una señal a la vez',
                  style: TextStyle(
                    color: Color(0xFF9A63FF),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Al seleccionar otra señal, la transmisión actual '
                  'se cierra automáticamente. Si permanece cargando, '
                  'la app intentará reconectarse.',
                  style: TextStyle(
                    color: Color(0xFF9AA4B7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}