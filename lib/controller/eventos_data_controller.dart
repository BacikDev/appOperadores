import 'package:app_cabecera/models/get_events_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetEventsController extends GetxController {
  final isLoading = false.obs;
  final getEventsModel = GetEventsModel(results: []).obs;
  final hoy = DateTime.now().toIso8601String().split('T')[0];

  Future<void> getDataFromApi(int? deporteId) async {
    if (deporteId == null) {
      print('ERROR: deporteId llegó null');
      getEventsModel.value = GetEventsModel(results: []);
      return;
    }

    try {
      isLoading.value = true;

    final response = await Supabase.instance.client
    .from('evento')
    .select('''
      id,
      fecha,
      hora,
      deporte_evento,
      evento,
      senal,
      deporte_id,
      evento_canal (
        canal (
          id,
          nombre,
          logo
        )
      )
    ''')
    .eq('deporte_id', deporteId)
    .gte('fecha', hoy)
    .order('fecha')
    .order('hora');

      print('RESPUESTA EVENTOS: $response');

      final model = GetEventsModel.fromJson(response);

      model.results.sort((a, b) {
        final fechaA = parseFechaHora(a.fecha, a.hora);
        final fechaB = parseFechaHora(b.fecha, b.hora);
        return fechaA.compareTo(fechaB);
      });

      getEventsModel.value = model;
    } catch (e) {
      print('ERROR SUPABASE EVENTOS: $e');
      getEventsModel.value = GetEventsModel(results: []);
    } finally {
      isLoading.value = false;
    }
  }

  DateTime parseFechaHora(String fecha, String hora) {
    final ahora = DateTime.now();

    try {
      final fechaLimpia = fecha.trim().toLowerCase();
      final horaLimpia = hora.trim();

      int hour = 0;
      int minute = 0;

      if (horaLimpia.isNotEmpty) {
        final partesHora = horaLimpia.split(':');
        hour = int.tryParse(partesHora[0]) ?? 0;
        minute = partesHora.length > 1 ? int.tryParse(partesHora[1]) ?? 0 : 0;
      }

      if (fechaLimpia == 'hoy') {
        return DateTime(ahora.year, ahora.month, ahora.day, hour, minute);
      }

      if (fechaLimpia == 'mañana' || fechaLimpia == 'manana') {
        final manana = ahora.add(const Duration(days: 1));
        return DateTime(manana.year, manana.month, manana.day, hour, minute);
      }

      if (fechaLimpia.contains('-')) {
        final partes = fechaLimpia.split('-');

        if (partes.length == 3) {
          final year = int.tryParse(partes[0]) ?? ahora.year;
          final month = int.tryParse(partes[1]) ?? ahora.month;
          final day = int.tryParse(partes[2]) ?? ahora.day;

          return DateTime(year, month, day, hour, minute);
        }
      }

      if (fechaLimpia.contains('/')) {
        final partes = fechaLimpia.split('/');

        if (partes.length >= 2) {
          final day = int.tryParse(partes[0]) ?? ahora.day;
          final month = int.tryParse(partes[1]) ?? ahora.month;
          final year = partes.length == 3
              ? int.tryParse(partes[2]) ?? ahora.year
              : ahora.year;

          return DateTime(year, month, day, hour, minute);
        }
      }

      return DateTime(ahora.year, ahora.month, ahora.day, hour, minute);
    } catch (e) {
      print('ERROR PARSEANDO FECHA/HORA: $fecha - $hora');
      return ahora;
    }
  }
}