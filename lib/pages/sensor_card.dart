import 'package:app_cabecera/controller/sensor_controller.dart';
import 'package:app_cabecera/models/sensor_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensorDashboardPage extends StatefulWidget {
  const SensorDashboardPage({super.key});

  @override
  State<SensorDashboardPage> createState() => _SensorDashboardPageState();
}

class _SensorDashboardPageState extends State<SensorDashboardPage> {
  final SensorController sensorController = Get.put(SensorController());

  @override
  void initState() {
    super.initState();
    sensorController.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef7f6),
      appBar: AppBar(
        title: const Text('Temperatura Cabezal'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: sensorController.cargarDatos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (sensorController.isLoading.value &&
            sensorController.ultimaLectura.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final ultima = sensorController.ultimaLectura.value;

        if (ultima == null || sensorController.historial.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        final historial = sensorController.historial.reversed.toList();

        final temperaturas = historial.map((e) => e.temperatura).toList();
        final tempMin = temperaturas.reduce((a, b) => a < b ? a : b);
        final tempMax = temperaturas.reduce((a, b) => a > b ? a : b);
        final tempPromedio =
            temperaturas.reduce((a, b) => a + b) / temperaturas.length;

        return RefreshIndicator(
          onRefresh: sensorController.cargarDatos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _HeaderCard(lectura: ultima),
                const SizedBox(height: 18),
                _TemperatureChartCard(
                  historial: historial,
                  tempMin: tempMin,
                  tempMax: tempMax,
                  tempPromedio: tempPromedio,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Actual',
                        value: '${ultima.temperatura.toStringAsFixed(1)} °C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Humedad',
                        value: '${ultima.humedad.toStringAsFixed(1)} %',
                        icon: Icons.water_drop,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Mínima',
                        value: '${tempMin.toStringAsFixed(1)} °C',
                        icon: Icons.arrow_downward,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Máxima',
                        value: '${tempMax.toStringAsFixed(1)} °C',
                        icon: Icons.arrow_upward,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 46)
              ],
            ),
          ),
        );
      }),
      
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final SensorModel lectura;

  const _HeaderCard({required this.lectura});

  @override
  Widget build(BuildContext context) {
    final hora =
        '${lectura.createdAt.hour.toString().padLeft(2, '0')}:${lectura.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff009688),
            Color(0xff26a69a),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperatura actual',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${lectura.temperatura.toStringAsFixed(1)} °C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Humedad ${lectura.humedad.toStringAsFixed(1)} % · Actualizado $hora',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureChartCard extends StatelessWidget {
  final List<SensorModel> historial;
  final double tempMin;
  final double tempMax;
  final double tempPromedio;

  const _TemperatureChartCard({
    required this.historial,
    required this.tempMin,
    required this.tempMax,
    required this.tempPromedio,
  });

  @override
  Widget build(BuildContext context) {
    final minY = (tempMin - 2).floorToDouble();
    final maxY = (tempMax + 2).ceilToDouble();

    final bottomInterval =
        historial.length > 10 ? (historial.length / 5).ceilToDouble() : 1.0;

    return Container(
      height: 390,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico de temperatura',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos ${historial.length} registros',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.18),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
  getTooltipItems: (spots) {
    return spots.map((spot) {
      final item = historial[spot.x.toInt()];

      return LineTooltipItem(
        '${item.temperatura.toStringAsFixed(1)} °C',
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  },
),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: bottomInterval,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= historial.length) {
                          return const SizedBox();
                        }

                        final fecha = historial[index].createdAt;
                        final hora =
                            '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hora,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: tempPromedio,
                      color: Colors.orange.withOpacity(0.75),
                      strokeWidth: 1.5,
                      dashArray: [6, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) =>
                            'Prom. ${tempPromedio.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      historial.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        historial[index].temperatura,
                      ),
                    ),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    barWidth: 4,
                    color: Colors.teal,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: historial.length <= 12,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withOpacity(0.28),
                          Colors.teal.withOpacity(0.03),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}