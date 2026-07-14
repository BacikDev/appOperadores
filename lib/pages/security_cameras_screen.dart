import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SecurityCamerasScreen extends StatefulWidget {
  const SecurityCamerasScreen({super.key});

  @override
  State<SecurityCamerasScreen> createState() =>
      _SecurityCamerasScreenState();
}

class _SecurityCamerasScreenState extends State<SecurityCamerasScreen> {
  static const String dvrIp = '192.168.1.210';
  static const int httpPort = 80;
  static const int rtspPort = 554;

  static const String dvrUser = 'admin';
  static const String dvrPassword = 'admin2021';

  late final List<HikCamera> cameras;

  @override
  void initState() {
    super.initState();

    cameras = List.generate(16, (index) {
      final channel = index + 1;

      // 102 = cámara 1, substream.
      // 202 = cámara 2, substream.
      final substreamId = '${channel}02';

      // 101 = cámara 1, stream principal.
      // 201 = cámara 2, stream principal.
      final mainStreamId = '${channel}01';

      return HikCamera(
        id: channel,
        name: 'Cámara $channel',
        substreamId: substreamId,
        mainStreamId: mainStreamId,
        snapshotUrl:
            'http://$dvrIp:$httpPort/'
            'ISAPI/Streaming/channels/$substreamId/picture',
        substreamRtspUrl:
            'rtsp://$dvrUser:$dvrPassword@'
            '$dvrIp:$rtspPort/Streaming/Channels/$substreamId',
        mainStreamRtspUrl:
            'rtsp://$dvrUser:$dvrPassword@'
            '$dvrIp:$rtspPort/Streaming/Channels/$mainStreamId',
      );
    });
  }

  void openCamera(HikCamera camera) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraFullscreenScreen(camera: camera),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () => Navigator.of(context).pop(),
            ),
            _StatsPanel(
              total: cameras.length,
              dvrIp: dvrIp,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Color(0xFF2F80ED),
                    size: 10,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'CÁMARAS DEL DVR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: cameras.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final camera = cameras[index];

                  return CameraSnapshotCard(
                    camera: camera,
                    username: dvrUser,
                    password: dvrPassword,

                    // Evita que las 16 cámaras consulten al DVR
                    // exactamente al mismo tiempo.
                    initialDelay: Duration(
                      milliseconds: index * 350,
                    ),
                    onTap: () => openCamera(camera),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HikCamera {
  final int id;
  final String name;

  final String substreamId;
  final String mainStreamId;

  final String snapshotUrl;
  final String substreamRtspUrl;
  final String mainStreamRtspUrl;

  const HikCamera({
    required this.id,
    required this.name,
    required this.substreamId,
    required this.mainStreamId,
    required this.snapshotUrl,
    required this.substreamRtspUrl,
    required this.mainStreamRtspUrl,
  });
}

// -----------------------------------------------------------------------------
// AUTENTICACIÓN DIGEST PARA HIKVISION
// -----------------------------------------------------------------------------

class HikvisionDigestClient {
  final String username;
  final String password;

  final http.Client _client = http.Client();

  HikvisionDigestClient({
    required this.username,
    required this.password,
  });

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final initialResponse = await _client
        .get(
          uri,
          headers: {
            'Accept': 'image/jpeg,image/*',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            ...?headers,
          },
        )
        .timeout(const Duration(seconds: 8));

    if (initialResponse.statusCode != 401) {
      return initialResponse;
    }

    final authenticationHeader =
        initialResponse.headers['www-authenticate'];

    if (authenticationHeader == null ||
        !authenticationHeader.toLowerCase().startsWith('digest')) {
      throw HikvisionAuthException(
        'El DVR respondió 401, pero no envió un desafío Digest.',
      );
    }

    final challenge = _parseDigestChallenge(authenticationHeader);

    final realm = challenge['realm'];
    final nonce = challenge['nonce'];

    if (realm == null || nonce == null) {
      throw HikvisionAuthException(
        'El desafío Digest del DVR está incompleto.',
      );
    }

    final algorithm =
        (challenge['algorithm'] ?? 'MD5').toUpperCase();

    if (algorithm != 'MD5' && algorithm != 'MD5-SESS') {
      throw HikvisionAuthException(
        'Algoritmo Digest no compatible: $algorithm',
      );
    }

    final opaque = challenge['opaque'];
    final qop = _selectQop(challenge['qop']);

    const method = 'GET';
    const nonceCount = '00000001';

    final cnonce = _generateCnonce();

    // En Digest debe utilizarse solamente path + query,
    // no la URL completa.
    final digestUri = uri.hasQuery
        ? '${uri.path}?${uri.query}'
        : uri.path;

    final ha1Initial = _md5(
      '$username:$realm:$password',
    );

    final ha1 = algorithm == 'MD5-SESS'
        ? _md5('$ha1Initial:$nonce:$cnonce')
        : ha1Initial;

    final ha2 = _md5('$method:$digestUri');

    final responseHash = qop == null
        ? _md5('$ha1:$nonce:$ha2')
        : _md5(
            '$ha1:$nonce:$nonceCount:$cnonce:$qop:$ha2',
          );

    final authorizationParts = <String>[
      'Digest username="${_escape(username)}"',
      'realm="${_escape(realm)}"',
      'nonce="${_escape(nonce)}"',
      'uri="${_escape(digestUri)}"',
      'response="$responseHash"',
      'algorithm=$algorithm',
    ];

    if (opaque != null && opaque.isNotEmpty) {
      authorizationParts.add(
        'opaque="${_escape(opaque)}"',
      );
    }

    if (qop != null) {
      authorizationParts.add('qop=$qop');
      authorizationParts.add('nc=$nonceCount');
      authorizationParts.add('cnonce="$cnonce"');
    }

    final authorizationHeader =
        authorizationParts.join(', ');

    return _client
        .get(
          uri,
          headers: {
            'Authorization': authorizationHeader,
            'Accept': 'image/jpeg,image/*',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            ...?headers,
          },
        )
        .timeout(const Duration(seconds: 8));
  }

  Map<String, String> _parseDigestChallenge(
    String header,
  ) {
    final value = header.replaceFirst(
      RegExp(
        r'^Digest\s+',
        caseSensitive: false,
      ),
      '',
    );

    final result = <String, String>{};

    final expression = RegExp(
      r'(\w+)\s*=\s*(?:"([^"]*)"|([^,\s]+))',
    );

    for (final match in expression.allMatches(value)) {
      final key = match.group(1)?.toLowerCase();
      final quotedValue = match.group(2);
      final plainValue = match.group(3);

      if (key != null) {
        result[key] = quotedValue ?? plainValue ?? '';
      }
    }

    return result;
  }

  String? _selectQop(String? qopHeader) {
    if (qopHeader == null || qopHeader.trim().isEmpty) {
      return null;
    }

    final values = qopHeader
        .split(',')
        .map((value) => value.trim().toLowerCase())
        .toList();

    if (values.contains('auth')) {
      return 'auth';
    }

    return values.isEmpty ? null : values.first;
  }

  String _md5(String value) {
    return md5.convert(utf8.encode(value)).toString();
  }

  String _generateCnonce() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );

    return md5.convert(bytes).toString();
  }

  String _escape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
  }

  void close() {
    _client.close();
  }
}

class HikvisionAuthException implements Exception {
  final String message;

  const HikvisionAuthException(this.message);

  @override
  String toString() => message;
}

// -----------------------------------------------------------------------------
// TARJETA DE CÁMARA
// -----------------------------------------------------------------------------

class CameraSnapshotCard extends StatefulWidget {
  final HikCamera camera;
  final String username;
  final String password;
  final Duration initialDelay;
  final VoidCallback onTap;

  const CameraSnapshotCard({
    super.key,
    required this.camera,
    required this.username,
    required this.password,
    required this.initialDelay,
    required this.onTap,
  });

  @override
  State<CameraSnapshotCard> createState() =>
      _CameraSnapshotCardState();
}

class _CameraSnapshotCardState
    extends State<CameraSnapshotCard>
    with AutomaticKeepAliveClientMixin {
  late final HikvisionDigestClient _digestClient;

  Timer? _initialTimer;
  Timer? _snapshotTimer;

  Uint8List? _imageBytes;

  bool _isLoading = true;
  bool _isOnline = false;
  bool _requestInProgress = false;

  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _digestClient = HikvisionDigestClient(
      username: widget.username,
      password: widget.password,
    );

    _initialTimer = Timer(
      widget.initialDelay,
      () {
        _loadSnapshot();

        _snapshotTimer = Timer.periodic(
          const Duration(seconds: 10),
          (_) => _loadSnapshot(),
        );
      },
    );
  }

  Future<void> _loadSnapshot() async {
    if (_requestInProgress) return;

    _requestInProgress = true;

    try {
      final uri = Uri.parse(widget.camera.snapshotUrl);

      final response = await _digestClient.get(uri);

      debugPrint(
        'Cámara ${widget.camera.id}: '
        'HTTP ${response.statusCode}',
      );

      if (!mounted) return;

      final contentType =
          response.headers['content-type']?.toLowerCase() ?? '';

      final validImage =
          response.statusCode == 200 &&
          response.bodyBytes.isNotEmpty &&
          (contentType.contains('image') ||
              _looksLikeJpeg(response.bodyBytes));

      if (validImage) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
          _isOnline = true;
          _errorMessage = null;
        });

        return;
      }

      setState(() {
        _isLoading = false;
        _isOnline = false;

        if (response.statusCode == 401) {
          _errorMessage = 'Usuario o contraseña rechazados';
        } else {
          _errorMessage = 'HTTP ${response.statusCode}';
        }
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isOnline = false;
        _errorMessage = 'Sin respuesta';
      });
    } on HikvisionAuthException catch (error) {
      debugPrint(
        'Error de autenticación cámara '
        '${widget.camera.id}: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isOnline = false;
        _errorMessage = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'Error cámara ${widget.camera.id}: '
        '${error.runtimeType} - $error',
      );

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isOnline = false;
        _errorMessage = 'Error de conexión';
      });
    } finally {
      _requestInProgress = false;
    }
  }

  bool _looksLikeJpeg(Uint8List bytes) {
    return bytes.length >= 2 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8;
  }

  Future<void> _retrySnapshot() async {
    if (_requestInProgress) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadSnapshot();
  }

  @override
  void dispose() {
    _initialTimer?.cancel();
    _snapshotTimer?.cancel();
    _digestClient.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101C2D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isOnline
                  ? const Color(0xFF1B4652)
                  : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  10,
                  10,
                  8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.camera.id.toString().padLeft(2, '0')}'
                        ' - ${widget.camera.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildSnapshotContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _isOnline
                      ? 'Tocar para ver en vivo'
                      : (_errorMessage ?? 'Cámara sin conexión'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isOnline
                        ? Colors.white54
                        : Colors.redAccent.shade100,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotContent() {
    if (_imageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) {
              return _buildUnavailableView();
            },
          ),
          if (_isLoading)
            const Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF4EA1FF),
        ),
      );
    }

    return _buildUnavailableView();
  }

  Widget _buildUnavailableView() {
    return Center(
      child: IconButton(
        onPressed: _retrySnapshot,
        tooltip: 'Reintentar',
        icon: const Icon(
          Icons.refresh_rounded,
          color: Colors.white54,
          size: 38,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA COMPLETA RTSP
// -----------------------------------------------------------------------------

class CameraFullscreenScreen extends StatefulWidget {
  final HikCamera camera;

  const CameraFullscreenScreen({
    super.key,
    required this.camera,
  });

  @override
  State<CameraFullscreenScreen> createState() =>
      _CameraFullscreenScreenState();
}

class _CameraFullscreenScreenState
    extends State<CameraFullscreenScreen> {
  late final Player _player;
  late final VideoController _videoController;

  StreamSubscription<String>? _errorSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _bufferingSubscription;

  Timer? _connectionTimeout;

  bool _isLoading = true;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _usingMainStream = false;

  String? _errorMessage;

  String get _selectedUrl {
    return _usingMainStream
        ? widget.camera.mainStreamRtspUrl
        : widget.camera.substreamRtspUrl;
  }

  @override
  void initState() {
    super.initState();

    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 8 * 1024 * 1024,
      ),
    );

    _videoController = VideoController(_player);

    _configureListeners();
    _openStream();
  }

  void _configureListeners() {
    _errorSubscription = _player.stream.error.listen(
      (error) {
        debugPrint(
          'Error RTSP cámara '
          '${widget.camera.id}: $error',
        );

        if (!mounted) return;

        _connectionTimeout?.cancel();

        setState(() {
          _hasError = true;
          _isLoading = false;
          _isPlaying = false;
          _errorMessage = error;
        });
      },
    );

    _playingSubscription = _player.stream.playing.listen(
      (playing) {
        if (!mounted) return;

        if (playing) {
          _connectionTimeout?.cancel();
        }

        setState(() {
          _isPlaying = playing;

          if (playing) {
            _isLoading = false;
            _hasError = false;
            _errorMessage = null;
          }
        });
      },
    );

    _bufferingSubscription = _player.stream.buffering.listen(
      (buffering) {
        if (!mounted || _hasError) return;

        setState(() {
          _isLoading = buffering && !_isPlaying;
        });
      },
    );
  }

  Future<void> _openStream() async {
    _connectionTimeout?.cancel();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _isPlaying = false;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      await _player.open(
        Media(_selectedUrl),
        play: true,
      );

      _connectionTimeout = Timer(
        const Duration(seconds: 15),
        () {
          if (!mounted || _isPlaying) return;

          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage =
                'El DVR no respondió al flujo RTSP.';
          });
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'No se pudo abrir el RTSP: $error',
      );

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _reconnect() async {
    _connectionTimeout?.cancel();

    try {
      await _player.stop();

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      await _openStream();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _changeStreamQuality() async {
    setState(() {
      _usingMainStream = !_usingMainStream;
    });

    await _reconnect();
  }

  Future<void> _play() async {
    try {
      await _player.play();
    } catch (error) {
      debugPrint('Error al reproducir: $error');
    }
  }

  Future<void> _pause() async {
    try {
      await _player.pause();
    } catch (error) {
      debugPrint('Error al pausar: $error');
    }
  }

  @override
  void dispose() {
    _connectionTimeout?.cancel();

    _errorSubscription?.cancel();
    _playingSubscription?.cancel();
    _bufferingSubscription?.cancel();

    _player.dispose();

    super.dispose();
  }

  Widget _buildVideo() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.signal_wifi_off_rounded,
                color: Colors.redAccent,
                size: 58,
              ),
              const SizedBox(height: 14),
              const Text(
                'No se pudo abrir la transmisión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _reconnect,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Video(
          controller: _videoController,
          controls: NoVideoControls,
          fit: BoxFit.contain,
          fill: Colors.black,
        ),
        if (_isLoading)
          Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF4EA1FF),
                ),
                SizedBox(height: 14),
                Text(
                  'Conectando con el DVR...',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _isPlaying
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  _isPlaying ? 'EN VIVO' : 'CONECTANDO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamId = _usingMainStream
        ? widget.camera.mainStreamId
        : widget.camera.substreamId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.camera.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Canal $streamId · '
              '${_usingMainStream ? 'Calidad principal' : 'Substream'}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _changeStreamQuality,
            icon: Icon(
              _usingMainStream
                  ? Icons.hd_rounded
                  : Icons.sd_rounded,
              color: const Color(0xFF4EA1FF),
            ),
            label: Text(
              _usingMainStream ? 'HD' : 'SD',
              style: const TextStyle(
                color: Color(0xFF4EA1FF),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildVideo()),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF101C2D),
              child: Row(
                children: [
                  Expanded(
                    child: _CameraButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Reproducir',
                      color: const Color(0xFF4EA1FF),
                      onTap: _play,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CameraButton(
                      icon: Icons.pause_rounded,
                      label: 'Pausar',
                      color: Colors.redAccent,
                      onTap: _pause,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CameraButton(
                      icon: Icons.restart_alt_rounded,
                      label: 'Reconectar',
                      color: Colors.amber,
                      onTap: _reconnect,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  const _CameraButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await onTap();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 11,
        ),
        backgroundColor: color.withOpacity(0.18),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CABECERA Y ESTADÍSTICAS
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1626),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            color: Colors.white,
          ),
          const Icon(
            Icons.videocam_rounded,
            color: Color(0xFF4EA1FF),
            size: 34,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CÁMARAS DE SEGURIDAD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'DVR Hikvision · Substream H.264',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
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

class _StatsPanel extends StatelessWidget {
  final int total;
  final String dvrIp;

  const _StatsPanel({
    required this.total,
    required this.dvrIp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101C2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.videocam_rounded,
            value: '$total',
            label: 'Cámaras',
          ),
          _StatCard(
            icon: Icons.dns_rounded,
            value: dvrIp,
            label: 'DVR',
          ),
          const _StatCard(
            icon: Icons.hd_rounded,
            value: 'H.264',
            label: 'Substream',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF142236),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4EA1FF),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}