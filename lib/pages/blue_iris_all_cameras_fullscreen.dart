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
  int _refresh = 0;
  BlueIrisCameraModel? _selectedCamera;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isNotEmpty) {
      _selectedCamera = widget.cameras.first;
    }

    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!mounted) return;
        setState(() => _refresh++);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _url(String shortName) {
    return '${BlueIrisConfig.imageUrl(shortName)}&all=$_refresh';
  }

  int _calcularColumnas(int total, double width, double height) {
    if (total <= 4) return 2;
    if (total <= 9) return 3;
    if (total <= 16) return 4;
    if (total <= 25) return 5;
    if (total <= 36) return 6;
    if (total <= 49) return 7;
    return 8;
  }

  Future<void> _confirmarAccion({
    required String titulo,
    required Future<void> Function(BlueIrisCameraModel camera) accion,
  }) async {
    final camera = _selectedCamera;

    if (camera == null) {
      Get.snackbar('Blue Iris', 'Seleccioná una cámara primero');
      return;
    }

    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: Text(titulo),
        content: Text('Cámara seleccionada:\n${camera.nombre}'),
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
      await accion(camera);
      setState(() => _refresh++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameras = widget.cameras;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('+All cameras'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final total = cameras.length;
                final columns = _calcularColumnas(
                  total,
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                final rows = (total / columns).ceil();
                final itemWidth = constraints.maxWidth / columns;
                final itemHeight = constraints.maxHeight / rows;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: cameras.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: itemWidth / itemHeight,
                  ),
                  itemBuilder: (context, index) {
                    final camera = cameras[index];
                    final selected =
                        _selectedCamera?.shortName == camera.shortName;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCamera = camera;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected
                                ? Colors.amber
                                : Colors.black,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _url(camera.shortName),
                              headers: BlueIrisConfig.authHeaders(),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: Colors.black87,
                                  child: const Icon(
                                    Icons.videocam_off,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                color: Colors.black.withValues(alpha: 0.55),
                                child: Text(
                                  camera.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFF111827),
            padding: const EdgeInsets.all(10),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text(
                    _selectedCamera == null
                        ? 'Seleccioná una cámara'
                        : 'Seleccionada: ${_selectedCamera!.nombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.settings_power,
                        label: 'Habilitar',
                        color: Colors.green,
                        onTap: () {
                          _confirmarAccion(
                            titulo: 'Habilitar cámara',
                            accion: controller.habilitarCamara,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.videocam_off,
                        label: 'Deshabilitar',
                        color: Colors.redAccent,
                        onTap: () {
                          _confirmarAccion(
                            titulo: 'Deshabilitar cámara',
                            accion: controller.deshabilitarCamara,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.restart_alt,
                        label: 'Reset',
                        color: Colors.orange,
                        onTap: () {
                          _confirmarAccion(
                            titulo: 'Resetear cámara',
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}