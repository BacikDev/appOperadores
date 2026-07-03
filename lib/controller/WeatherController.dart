import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WeatherController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;

  final temperatura = 0.0.obs;
  final humedad = 0.obs;
  final viento = 0.0.obs;
  final codigoClima = 0.obs;
  final descripcion = 'Cargando...'.obs;
  final ultimaActualizacion = Rxn<DateTime>();

  final pronosticoHoras = <HourlyWeather>[].obs;
  final pronosticoDias = <DailyWeather>[].obs;

  Timer? _timer;

  static const double latitud = -26.309;
  static const double longitud = -59.372;

  @override
  void onInit() {
    super.onInit();
    cargarClima();

    _timer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => cargarClima(),
    );
  }

  Future<void> cargarClima() async {
    try {
      hasError.value = false;

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitud'
        '&longitude=$longitud'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,precipitation_probability,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&forecast_days=7'
        '&timezone=America%2FArgentina%2FCordoba',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Error al obtener clima');
      }

      final data = jsonDecode(response.body);

      final current = data['current'];

      temperatura.value = (current['temperature_2m'] as num).toDouble();
      humedad.value = current['relative_humidity_2m'] as int;
      viento.value = (current['wind_speed_10m'] as num).toDouble();
      codigoClima.value = current['weather_code'] as int;
      descripcion.value = descripcionClima(codigoClima.value);
      ultimaActualizacion.value = DateTime.now();

      _cargarPronosticoPorHora(data['hourly']);
      _cargarPronosticoDias(data['daily']);
    } catch (e) {
      hasError.value = true;
      descripcion.value = 'Clima no disponible';
    } finally {
      isLoading.value = false;
    }
  }

  void _cargarPronosticoPorHora(dynamic hourly) {
    final List tiempos = hourly['time'];
    final List temperaturas = hourly['temperature_2m'];
    final List lluvias = hourly['precipitation_probability'];
    final List codigos = hourly['weather_code'];

    final ahora = DateTime.now();

    final List<HourlyWeather> horas = [];

    for (int i = 0; i < tiempos.length; i++) {
      final fechaHora = DateTime.parse(tiempos[i]);

      if (fechaHora.isAfter(ahora) && horas.length < 12) {
        final hora =
            '${fechaHora.hour.toString().padLeft(2, '0')}:00';

        final code = codigos[i] as int;

        horas.add(
          HourlyWeather(
            hora: hora,
            temperatura: (temperaturas[i] as num).toDouble(),
            probabilidadLluvia: lluvias[i] as int,
            codigo: code,
            icono: iconoPorCodigo(code),
          ),
        );
      }
    }

    pronosticoHoras.assignAll(horas);
  }

  void _cargarPronosticoDias(dynamic daily) {
    final List tiempos = daily['time'];
    final List maximas = daily['temperature_2m_max'];
    final List minimas = daily['temperature_2m_min'];
    final List codigos = daily['weather_code'];

    final List<DailyWeather> dias = [];

    for (int i = 0; i < tiempos.length; i++) {
      final fecha = DateTime.parse(tiempos[i]);
      final code = codigos[i] as int;

      dias.add(
        DailyWeather(
          dia: nombreDia(fecha, i),
          max: (maximas[i] as num).toDouble(),
          min: (minimas[i] as num).toDouble(),
          codigo: code,
          descripcion: descripcionClima(code),
          icono: iconoPorCodigo(code),
        ),
      );
    }

    pronosticoDias.assignAll(dias);
  }

  String nombreDia(DateTime fecha, int index) {
    if (index == 0) return 'Hoy';
    if (index == 1) return 'Mañana';

    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return dias[fecha.weekday - 1];
  }

  String descripcionClima(int code) {
    if (code == 0) return 'Despejado';
    if (code == 1) return 'Mayormente despejado';
    if (code == 2) return 'Parcialmente nublado';
    if (code == 3) return 'Nublado';
    if (code == 45 || code == 48) return 'Niebla';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Llovizna';
    if ([61, 63, 65, 66, 67].contains(code)) return 'Lluvia';
    if ([80, 81, 82].contains(code)) return 'Chaparrones';
    if ([95, 96, 99].contains(code)) return 'Tormenta';
    return 'Clima actual';
  }

  IconData get iconoClima => iconoPorCodigo(codigoClima.value);

  IconData iconoPorCodigo(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return Icons.water_drop_rounded;
    }
    if ([95, 96, 99].contains(code)) {
      return Icons.thunderstorm_rounded;
    }

    return Icons.cloud_queue_rounded;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class HourlyWeather {
  final String hora;
  final double temperatura;
  final int probabilidadLluvia;
  final int codigo;
  final IconData icono;

  HourlyWeather({
    required this.hora,
    required this.temperatura,
    required this.probabilidadLluvia,
    required this.codigo,
    required this.icono,
  });
}

class DailyWeather {
  final String dia;
  final double max;
  final double min;
  final int codigo;
  final String descripcion;
  final IconData icono;

  DailyWeather({
    required this.dia,
    required this.max,
    required this.min,
    required this.codigo,
    required this.descripcion,
    required this.icono,
  });
}