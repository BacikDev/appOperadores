import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/blue_iris_controller.dart';
import '../widgets/blue_iris_all_cameras_card.dart';
import '../widgets/blue_iris_camera_card.dart';

class BlueIrisScreen extends StatelessWidget {
  BlueIrisScreen({super.key});

  final BlueIrisController controller = Get.put(BlueIrisController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Cámaras Blue Iris'),
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: controller.cargarCamaras,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: controller.buscar,
              decoration: InputDecoration(
                hintText: 'Buscar cámara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final cameras = controller.camerasFiltradas;

              if (cameras.isEmpty) {
                return const Center(
                  child: Text('No hay cámaras disponibles'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: cameras.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return BlueIrisAllCamerasCard(
                      cameras: cameras,
                    );
                  }

                  final camera = cameras[index - 1];

                  return BlueIrisCameraCard(
                    camera: camera,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}