import 'package:app_cabecera/models/get_events_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetEventsController extends GetxController{
  RxBool isLoading = true.obs;

  Rx<GetEventsModel> getEventsModel =
  GetEventsModel(results: []).obs;

  Future<void> getDataFromApi(int deporte_id)async{
    try{
      isLoading(true);

      final response =
      await Supabase.instance.client
      .from('evento')
      .select()
      .eq('deporte_id', deporte_id)
      .order('fecha', ascending: true);

      getEventsModel.value =
      GetEventsModel.fromJson(response);
    }catch(e){
      print('ERROR SUPABASE: $e');
    }finally{
      isLoading(false);
    }
  }
}