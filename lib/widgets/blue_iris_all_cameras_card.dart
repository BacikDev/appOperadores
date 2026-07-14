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
    final previewCameras = cameras.take(4).toList();

    return GestureDetector(
      onTap: () {
        Get.to(() => BlueIrisAllCamerasFullscreen(cameras: cameras));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: previewCameras.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final cam = previewCameras[index];

                  return Image.network(
                    BlueIrisConfig.imageUrl(cam.shortName),
                    headers: BlueIrisConfig.authHeaders(),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) {
                      return Container(color: Colors.black87);
                    },
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Text(
                    '+All cameras · ${cameras.length} cámaras',
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
      ),
    );
  }
}