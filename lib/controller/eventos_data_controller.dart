import 'package:app_cabecera/models/get_events_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetEventsController extends GetxController{
  RxBool isLoading = true.obs;

  Rx<GetEventsModel> getEventsModel =
  GetEventsModel(results: []).obs;

  DateTime parseFechaHora(String fecha, String hora){

    final partesFecha = fecha.split(' ');
    final partesHora = hora.split(':');

    return DateTime(
      int.parse(partesFecha[1]),
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );
  }

  Future<void> getDataFromApi(int deporte_id)async{
    try{
      isLoading(true);

      final response =
      await Supabase.instance.client
      .from('evento')
      .select()
      .eq('deporte_id', deporte_id);

      final model = GetEventsModel.fromJson(response);

      model.results.sort((a,b){
        final fechaA = parseFechaHora(a.fecha, a.hora);

        final fechaB = parseFechaHora(b.fecha, b.hora);

        return fechaA.compareTo(fechaB);
      });

      getEventsModel.value =
      model;
    }catch(e){
      print('ERROR SUPABASE: $e');
    }finally{
      isLoading(false);
    }
  }
}