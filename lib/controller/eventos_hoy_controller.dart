import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventosHoyController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var eventos = <Map<String, dynamic>>[].obs;

  Timer? _timer;

  Future<void> getEventosHoy({int? deporteId}) async {
    try {
      isLoading.value = true;

      dynamic query = supabase
          .from('eventos_de_hoy_con_logo')
          .select();

      if (deporteId != null) {
        query = query.eq('deporte_id', deporteId);
      }

      final response = await query
          .order('fecha', ascending: true)
          .order('hora', ascending: true);

      eventos.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print('Error cargando eventos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualiza automáticamente cada 30 segundos
  void iniciarActualizacionAutomatica({int? deporteId}) {
    _timer?.cancel();

    getEventosHoy(deporteId: deporteId);

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => getEventosHoy(deporteId: deporteId),
    );
  }

  void detenerActualizacionAutomatica() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    detenerActualizacionAutomatica();
    super.onClose();
  }
}