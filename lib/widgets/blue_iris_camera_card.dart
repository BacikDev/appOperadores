import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/blue_iris_config.dart';
import '../models/blue_iris_camera_model.dart';
import '../pages/blue_iris_fullscreen.dart';

class BlueIrisCameraCard extends StatelessWidget {
  final BlueIrisCameraModel camera;

  const BlueIrisCameraCard({
    super.key,
    required this.camera,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BlueIrisFullscreen(camera: camera));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              BlueIrisConfig.imageUrl(camera.shortName),
              headers: BlueIrisConfig.authHeaders(),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withValues(alpha: 0.60),
                child: Text(
                  camera.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}