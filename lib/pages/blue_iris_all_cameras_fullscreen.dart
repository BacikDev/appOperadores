import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/blue_iris_config.dart';
import '../controller/blue_iris_controller.dart';
import '../models/blue_iris_camera_model.dart';

class BlueIrisAllCamerasFullscreen extends StatefulWidget {
  final List<BlueIrisCameraModel> cameras;

  const BlueIrisAllCamerasFullscreen({
    super.key,
    required this.cameras,
  });

  @override
  State<BlueIrisAllCamerasFullscreen> createState() =>
      _BlueIrisAllCamerasFullscreenState();
}

class _BlueIrisAllCamerasFullscreenState
    extends State<BlueIrisAllCamerasFullscreen> {
  final BlueIrisController controller = Get.find<BlueIrisController>();

  Timer? _timer;
  late String _url;

  @override
  void initState() {
    super.initState();

    _url = BlueIrisConfig.allCamerasImageUrl();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _url = BlueIrisConfig.allCamerasImageUrl();
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _url = BlueIrisConfig.allCamerasImageUrl();
    });
  }

  void _mostrarSelector({
    required String titulo,
    required Future<void> Function(BlueIrisCameraModel camera) accion,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cameras.length,
                    itemBuilder: (context, index) {
                      final camera = widget.cameras[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.videocam,
                          color: Colors.white70,
                        ),
                        title: Text(
                          camera.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          camera.shortName,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () async {
                          Get.back();
                          await accion(camera);
                          _recargar();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.80),
            size: 34,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('+All cameras Live View'),
        backgroundColor: const Color(0xFF9E9E9E),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.network(
                    _url,
                    headers: BlueIrisConfig.authHeaders(),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.grid_view,
                        color: Colors.white,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF789096),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 18,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _controlButton(
                        icon: Icons.refresh,
                        label: 'Recargar',
                        onTap: _recargar,
                      ),
                      _controlButton(
                        icon: Icons.settings_power,
                        label: 'Habilitar',
                        onTap: () {
                          _mostrarSelector(
                            titulo: 'Seleccioná cámara para habilitar',
                            accion: controller.habilitarCamara,
                          );
                        },
                      ),
                      _controlButton(
                        icon: Icons.videocam_off,
                        label: 'Deshabilitar',
                        onTap: () {
                          _mostrarSelector(
                            titulo: 'Seleccioná cámara para deshabilitar',
                            accion: controller.deshabilitarCamara,
                          );
                        },
                      ),
                      _controlButton(
                        icon: Icons.restart_alt,
                        label: 'Reset',
                        onTap: () {
                          _mostrarSelector(
                            titulo: 'Seleccioná cámara para resetear',
                            accion: controller.resetearCamara,
                          );
                        },
                      ),
                    ],
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