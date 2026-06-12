import 'package:app_cabecera/models/sensor_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorController extends GetxController {
  final supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  Rxn<SensorModel> ultimaLectura = Rxn<SensorModel>();
  RxList<SensorModel> historial = <SensorModel>[].obs;

  Future<void> getUltimaLectura() async {
    final response = await supabase
        .from('lecturas_sensor')
        .select()
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      ultimaLectura.value = SensorModel.fromJson(response.first);
    }
  }

  Future<void> getHistorial() async {
    final response = await supabase
        .from('lecturas_sensor')
        .select()
        .order('created_at', ascending: false)
        .limit(2000);

    historial.value = response
        .map<SensorModel>((json) => SensorModel.fromJson(json))
        .toList();
  }

  Future<void> cargarDatos() async {
    isLoading.value = true;
    await getUltimaLectura();
    await getHistorial();
    isLoading.value = false;
  }
}