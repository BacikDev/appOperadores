import 'package:app_cabecera/models/farmacia_turno_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmaciasController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final farmaciaActual = Rxn<FarmaciaTurnoModel>();
  final turnos = <FarmaciaTurnoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    cargarFarmacias();
  }

  DateTime fechaTurnoActual() {
    final ahora = DateTime.now();

    final corteDeTurno = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      8,
    );

    if (ahora.isBefore(corteDeTurno)) {
      return ahora.subtract(const Duration(days: 1));
    }

    return ahora;
  }

  Future<void> cargarFarmacias() async {
    try {
      isLoading.value = true;

      final fechaActual = fechaTurnoActual();

      final hoy = DateFormat('yyyy-MM-dd').format(fechaActual);
      final fin = DateFormat('yyyy-MM-dd')
          .format(fechaActual.add(const Duration(days: 3)));

      final response = await supabase
          .from('farmacias_turno')
          .select('''
            fecha,
            farmacias (
              nombre,
              direccion,
              telefono,
              latitud,
              longitud,
              observaciones
            )
          ''')
          .gte('fecha', hoy)
          .lte('fecha', fin)
          .order('fecha', ascending: true);

      final lista = (response as List)
          .map((item) => FarmaciaTurnoModel.fromMap(item))
          .toList();

      turnos.assignAll(lista);

      farmaciaActual.value = lista.isNotEmpty ? lista.first : null;
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las farmacias');
    } finally {
      isLoading.value = false;
    }
  }
}