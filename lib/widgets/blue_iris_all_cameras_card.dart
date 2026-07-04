import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/blue_iris_config.dart';
import '../models/blue_iris_camera_model.dart';
import '../pages/blue_iris_all_cameras_fullscreen.dart';

class BlueIrisAllCamerasCard extends StatelessWidget {
  final List<BlueIrisCameraModel> cameras;

  const BlueIrisAllCamerasCard({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => BlueIrisAllCamerasFullscreen(
            cameras: cameras,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                '+All cameras',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    BlueIrisConfig.allCamerasImageUrl(),
                    headers: BlueIrisConfig.authHeaders(),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.black87,
                        child: const Icon(
                          Icons.grid_view,
                          color: Colors.white,
                          size: 42,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      color: const Color(0xFF436B9A),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.black.withValues(alpha: 0.55),
                      child: Text(
                        '${cameras.length} cámaras',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
}