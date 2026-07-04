import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/blue_iris_config.dart';
import '../controller/blue_iris_controller.dart';
import '../models/blue_iris_camera_model.dart';

class BlueIrisFullscreen extends StatefulWidget {
  final BlueIrisCameraModel camera;

  const BlueIrisFullscreen({
    super.key,
    required this.camera,
  });

  @override
  State<BlueIrisFullscreen> createState() => _BlueIrisFullscreenState();
}

class _BlueIrisFullscreenState extends State<BlueIrisFullscreen> {
  final BlueIrisController controller = Get.find<BlueIrisController>();

  Timer? _timer;
  late String _url;

  @override
  void initState() {
    super.initState();

    _url = BlueIrisConfig.imageUrl(widget.camera.shortName);

    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) {
        if (!mounted) return;

        setState(() {
          _url = BlueIrisConfig.imageUrl(widget.camera.shortName);
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
      _url = BlueIrisConfig.imageUrl(widget.camera.shortName);
    });
  }

  Future<void> _confirmarAccion({
    required String titulo,
    required String mensaje,
    required Future<void> Function() accion,
  }) async {
    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await accion();
      _recargar();
    }
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final camera = widget.camera;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(camera.nombre),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
            child: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(
                  _url,
                  headers: BlueIrisConfig.authHeaders(),
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 80,
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF111827),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _controlButton(
                    icon: Icons.settings_power,
                    label: 'Habilitar',
                    color: Colors.green,
                    onTap: () {
                      _confirmarAccion(
                        titulo: 'Habilitar cámara',
                        mensaje: '¿Querés habilitar ${camera.nombre}?',
                        accion: () => controller.habilitarCamara(camera),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _controlButton(
                    icon: Icons.videocam_off,
                    label: 'Deshabilitar',
                    color: Colors.redAccent,
                    onTap: () {
                      _confirmarAccion(
                        titulo: 'Deshabilitar cámara',
                        mensaje: '¿Querés deshabilitar ${camera.nombre}?',
                        accion: () => controller.deshabilitarCamara(camera),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _controlButton(
                    icon: Icons.restart_alt,
                    label: 'Reset',
                    color: Colors.orange,
                    onTap: () {
                      _confirmarAccion(
                        titulo: 'Resetear cámara',
                        mensaje: '¿Querés resetear ${camera.nombre}?',
                        accion: () => controller.resetearCamara(camera),
                      );
                    },
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