import 'package:app_cabecera/controller/WeatherController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.find<WeatherController>();

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050B18),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clima en El Colorado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8A5CFF)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.cargarClima,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentWeatherCard(controller: controller),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Pronóstico por hora'),
              const SizedBox(height: 10),
              _HourlyForecast(controller: controller),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Próximos 7 días'),
              const SizedBox(height: 10),
              _DailyForecast(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherController controller;

  const _CurrentWeatherCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'El Colorado, Pirané - Formosa',
            style: TextStyle(color: Color(0xFF9BA6C7), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Icon(
            controller.iconoClima,
            color: Colors.white,
            size: 72,
          ),
          const SizedBox(height: 12),
          Text(
            '${controller.temperatura.value.round()}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            controller.descripcion.value,
            style: const TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _WeatherInfoTile(
                  icon: Icons.water_drop_rounded,
                  title: 'Humedad',
                  value: '${controller.humedad.value}%',
                  color: Color(0xFF2997FF),
                ),
              ),
              Expanded(
                child: _WeatherInfoTile(
                  icon: Icons.air_rounded,
                  title: 'Viento',
                  value: '${controller.viento.value.toStringAsFixed(0)} km/h',
                  color: Color(0xFF20D489),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HourlyForecast extends StatelessWidget {
  final WeatherController controller;

  const _HourlyForecast({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.pronosticoHoras.isEmpty) {
      return const Text(
        'No hay datos por hora disponibles',
        style: TextStyle(color: Colors.white70),
      );
    }

    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.pronosticoHoras.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = controller.pronosticoHoras[index];

          return Container(
            width: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF101A2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.hora,
                  style: const TextStyle(
                    color: Color(0xFF9BA6C7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(
                  item.icono,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  '${item.temperatura.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.probabilidadLluvia}%',
                  style: const TextStyle(
                    color: Color(0xFF2997FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyForecast extends StatelessWidget {
  final WeatherController controller;

  const _DailyForecast({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.pronosticoDias.isEmpty) {
      return const Text(
        'No hay pronóstico extendido disponible',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: controller.pronosticoDias.map((dia) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF101A2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(dia.icono, color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dia.dia,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dia.descripcion,
                      style: const TextStyle(
                        color: Color(0xFF9BA6C7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${dia.min.round()}° / ${dia.max.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _WeatherInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _WeatherInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF9BA6C7), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF8A5CFF),
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}