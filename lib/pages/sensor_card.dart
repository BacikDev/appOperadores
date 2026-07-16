import 'package:app_cabecera/controller/sensor_controller.dart';
import 'package:app_cabecera/models/sensor_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensorDashboardPage extends StatefulWidget {
  const SensorDashboardPage({super.key});

  @override
  State<SensorDashboardPage> createState() =>
      _SensorDashboardPageState();
}

class _SensorDashboardPageState extends State<SensorDashboardPage> {
  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _cardSecondary = Color(0xFF101A2E);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _green = Color(0xFF20D489);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _pink = Color(0xFFFF4F81);
  static const Color _blue = Color(0xFF2997FF);
  static const Color _textSecondary = Color(0xFF9BA6C7);

  final SensorController sensorController =
      Get.put(SensorController());

  @override
  void initState() {
    super.initState();
    sensorController.cargarDatos();
  }

  Future<void> _actualizar() async {
    await sensorController.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Estado de cabecera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _purple,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final ultima = sensorController.ultimaLectura.value;

          if (sensorController.isLoading.value && ultima == null) {
            return const _LoadingState();
          }

          if (ultima == null || sensorController.historial.isEmpty) {
            return _EmptyState(
              onRefresh: _actualizar,
            );
          }

          final historial =
              sensorController.historial.reversed.toList();

          final temperaturas =
              historial.map((item) => item.temperatura).toList();

          final tempMin =
              temperaturas.reduce((a, b) => a < b ? a : b);

          final tempMax =
              temperaturas.reduce((a, b) => a > b ? a : b);

          final tempPromedio =
              temperaturas.reduce((a, b) => a + b) /
                  temperaturas.length;

          final estadoCritico = ultima.temperatura >= 23;

          return RefreshIndicator(
            color: _purple,
            backgroundColor: _card,
            onRefresh: _actualizar,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _HeaderCard(
                          lectura: ultima,
                          estadoCritico: estadoCritico,
                        ),
                        const SizedBox(height: 16),
                        _StatusMessage(
                          estadoCritico: estadoCritico,
                          temperatura: ultima.temperatura,
                        ),
                        const SizedBox(height: 18),
                        _SectionTitle(
                          icon: Icons.monitor_heart_rounded,
                          title: 'RESUMEN ACTUAL',
                        ),
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Temperatura',
                                value:
                                    '${ultima.temperatura.toStringAsFixed(1)}°',
                                unit: 'C',
                                icon: Icons.thermostat_rounded,
                                color: estadoCritico
                                    ? _pink
                                    : _orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Humedad',
                                value:
                                    '${ultima.humedad.toStringAsFixed(1)}',
                                unit: '%',
                                icon: Icons.water_drop_rounded,
                                color: _blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Mínima',
                                value:
                                    '${tempMin.toStringAsFixed(1)}°',
                                unit: 'C',
                                icon: Icons.south_rounded,
                                color: _green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                title: 'Máxima',
                                value:
                                    '${tempMax.toStringAsFixed(1)}°',
                                unit: 'C',
                                icon: Icons.north_rounded,
                                color: _pink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _TemperatureChartCard(
                          historial: historial,
                          tempMin: tempMin,
                          tempMax: tempMax,
                          tempPromedio: tempPromedio,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final SensorModel lectura;
  final bool estadoCritico;

  const _HeaderCard({
    required this.lectura,
    required this.estadoCritico,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A5CFF);
    const green = Color(0xFF20D489);
    const orange = Color(0xFFFFA726);
    const pink = Color(0xFFFF4F81);
    const cardSecondary = Color(0xFF101A2E);
    const textSecondary = Color(0xFF9BA6C7);

    final hora =
        '${lectura.createdAt.hour.toString().padLeft(2, '0')}:'
        '${lectura.createdAt.minute.toString().padLeft(2, '0')}';

    final colorEstado = estadoCritico ? pink : green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorEstado.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorEstado.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -38,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colorEstado,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorEstado,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    estadoCritico
                        ? 'TEMPERATURA ELEVADA'
                        : 'ESTADO NORMAL',
                    style: TextStyle(
                      color: colorEstado,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: (estadoCritico ? pink : orange)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.thermostat_rounded,
                      color: estadoCritico ? pink : orange,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temperatura actual',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${lectura.temperatura.toStringAsFixed(1)} °C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: cardSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF2997FF),
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Humedad ${lectura.humedad.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.schedule_rounded,
                      color: textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Actualizado $hora',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final bool estadoCritico;
  final double temperatura;

  const _StatusMessage({
    required this.estadoCritico,
    required this.temperatura,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF20D489);
    const orange = Color(0xFFFFA726);

    final color = estadoCritico ? orange : green;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        children: [
          Icon(
            estadoCritico
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            color: color,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              estadoCritico
                  ? 'La temperatura alcanzó '
                      '${temperatura.toStringAsFixed(1)} °C. '
                      'Se recomienda prender el extractor.'
                  : 'La temperatura de la cabecera se encuentra '
                      'dentro del rango operativo.',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8A5CFF),
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8A5CFF),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
    const card = Color(0xFF0D172A);
    const purple = Color(0xFF8A5CFF);
    const orange = Color(0xFFFFA726);
    const textSecondary = Color(0xFF9BA6C7);

    final minY = (tempMin - 2).floorToDouble();
    final maxY = (tempMax + 2).ceilToDouble();

    final bottomInterval = historial.length > 10
        ? (historial.length / 5).ceilToDouble()
        : 1.0;

    return Container(
      height: 390,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: purple,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'HISTÓRICO DE TEMPERATURA',
                style: TextStyle(
                  color: purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos ${historial.length} registros',
            style: const TextStyle(
              color: textSecondary,
              fontSize: 11,
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
                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.07),
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
                        final index = spot.x.toInt();

                        if (index < 0 ||
                            index >= historial.length) {
                          return null;
                        }

                        final item = historial[index];

                        return LineTooltipItem(
                          '${item.temperatura.toStringAsFixed(1)} °C\n'
                          '${item.createdAt.hour.toString().padLeft(2, '0')}:'
                          '${item.createdAt.minute.toString().padLeft(2, '0')}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 33,
                      interval: bottomInterval,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 ||
                            index >= historial.length) {
                          return const SizedBox.shrink();
                        }

                        final fecha = historial[index].createdAt;

                        final hora =
                            '${fecha.hour.toString().padLeft(2, '0')}:'
                            '${fecha.minute.toString().padLeft(2, '0')}';

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hora,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 9,
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
                      color: orange.withValues(alpha: 0.82),
                      strokeWidth: 1.4,
                      dashArray: [6, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) =>
                            'Prom. ${tempPromedio.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
                    barWidth: 3.2,
                    color: purple,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: historial.length <= 12,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          purple.withValues(alpha: 0.30),
                          purple.withValues(alpha: 0.01),
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
  final String unit;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8A5CFF),
            strokeWidth: 3,
          ),
          SizedBox(height: 14),
          Text(
            'Cargando sensores...',
            style: TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF8A5CFF),
      backgroundColor: const Color(0xFF0D172A),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 130),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.sensors_off_rounded,
                  color: Color(0xFF8A5CFF),
                  size: 50,
                ),
                SizedBox(height: 14),
                Text(
                  'No hay datos disponibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Deslizá hacia abajo para volver a consultar '
                  'las lecturas del sensor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9BA6C7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
