import 'package:app_cabecera/controller/sensor_controller.dart';
import 'package:app_cabecera/pages/sensor_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiniSensorCard extends StatefulWidget {
  const MiniSensorCard({super.key});

  @override
  State<MiniSensorCard> createState() => _MiniSensorCardState();
}

class _MiniSensorCardState extends State<MiniSensorCard> {
  final SensorController sensorController = Get.put(SensorController());

  @override
  void initState() {
    super.initState();
    sensorController.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lectura = sensorController.ultimaLectura.value;

      if (lectura == null) {
        return const SizedBox(
          height: 30,
          width: 105,
          child: Center(
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Get.to(() => const SensorDashboardPage());
        },
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.teal.withOpacity(0.25),
            ),
          ), 
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.thermostat,
                color: Colors.teal,
                size: 22,
              ),
              const SizedBox(width: 5),
              Text(
                '${lectura.temperatura.toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.water_drop,
                color: Colors.blue[400],
                size: 16,
              ),
              Text(
                '${lectura.humedad.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}