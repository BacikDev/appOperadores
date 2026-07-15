import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityCamerasScreen extends StatefulWidget {
  const SecurityCamerasScreen({super.key});

  @override
  State<SecurityCamerasScreen> createState() =>
      _SecurityCamerasScreenState();
}

class _SecurityCamerasScreenState
    extends State<SecurityCamerasScreen> {
  static const MethodChannel _rtspChannel =
      MethodChannel('app_cabecera/rtsp_player');

  static const String dvrIp = '192.168.1.210';
  static const int rtspPort = 554;

  static const String dvrUser = 'admin';
  static const String dvrPassword = 'admin2021';

  late final List<HikCamera> cameras;

  bool _openingCamera = false;
  int? _openingCameraId;

  @override
  void initState() {
    super.initState();

    cameras = List.generate(
      16,
      (index) {
        final cameraNumber = index + 1;
        final streamId = '${cameraNumber}02';

        return HikCamera(
          id: cameraNumber,
          name: 'Cámara $cameraNumber',
          streamId: streamId,
          rtspUrl:
              'rtsp://$dvrUser:$dvrPassword@'
              '$dvrIp:$rtspPort/'
              'Streaming/Channels/$streamId',
        );
      },
    );
  }

  Future<void> _openCamera(HikCamera camera) async {
    if (_openingCamera) return;

    setState(() {
      _openingCamera = true;
      _openingCameraId = camera.id;
    });

    try {
      await _rtspChannel.invokeMethod<void>(
        'openRtspPlayer',
        {
          'title': camera.name,
          'rtspUrl': camera.rtspUrl,
          'streamId': camera.streamId,
        },
      );
    } on PlatformException catch (error) {
      if (!mounted) return;

      _showError(
        'No se pudo abrir ${camera.name}.\n'
        '${error.message ?? error.code}',
      );
    } catch (error) {
      if (!mounted) return;

      _showError(
        'Error abriendo ${camera.name}.\n$error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingCamera = false;
          _openingCameraId = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
            _DvrInformationPanel(
              totalCameras: cameras.length,
              dvrIp: dvrIp,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 12),
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
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  20,
                ),
                itemCount: cameras.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final camera = cameras[index];
                  final isOpening =
                      _openingCameraId == camera.id;

                  return CameraRtspCard(
                    camera: camera,
                    isOpening: isOpening,
                    onTap: () => _openCamera(camera),
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
  final String streamId;
  final String rtspUrl;

  const HikCamera({
    required this.id,
    required this.name,
    required this.streamId,
    required this.rtspUrl,
  });
}

class CameraRtspCard extends StatelessWidget {
  final HikCamera camera;
  final bool isOpening;
  final VoidCallback onTap;

  const CameraRtspCard({
    super.key,
    required this.camera,
    required this.isOpening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOpening ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101C2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOpening
                  ? const Color(0xFF4EA1FF)
                  : Colors.white10,
              width: isOpening ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF142B45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        color: Color(0xFF4EA1FF),
                        size: 23,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF123A2C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.greenAccent,
                            size: 7,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'RTSP',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  camera.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Canal ${camera.streamId}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142236),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: isOpening
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4EA1FF),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Abriendo...',
                              style: TextStyle(
                                color: Color(0xFF4EA1FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFF4EA1FF),
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Ver en vivo',
                              style: TextStyle(
                                color: Color(0xFF4EA1FF),
                                fontSize: 12,
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
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        6,
        10,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1626),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF142B45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Color(0xFF4EA1FF),
              size: 27,
            ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'DVR Hikvision · Transmisión RTSP',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
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

class _DvrInformationPanel extends StatelessWidget {
  final int totalCameras;
  final String dvrIp;

  const _DvrInformationPanel({
    required this.totalCameras,
    required this.dvrIp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101C2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          _InformationItem(
            icon: Icons.videocam_rounded,
            value: '$totalCameras',
            label: 'Cámaras',
          ),
          _InformationItem(
            icon: Icons.dns_rounded,
            value: dvrIp,
            label: 'DVR',
          ),
          const _InformationItem(
            icon: Icons.wifi_tethering_rounded,
            value: 'RTSP',
            label: 'Protocolo',
          ),
        ],
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InformationItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF142236),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4EA1FF),
              size: 21,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}