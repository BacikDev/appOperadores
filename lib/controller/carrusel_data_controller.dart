import 'package:app_cabecera/models/get_carrusel_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetCarruselController extends GetxController{
  RxBool isLoading = true.obs;

  Rx<GetCarruselModel> getCarruselModel =
  GetCarruselModel(results: []).obs;

  Future<void> getDataFromApi()async{
    try{
      isLoading(true);

      final response =
      await Supabase.instance.client
      .from('banner')
      .select();

      getCarruselModel.value =
      GetCarruselModel.fromJson(response);
    }catch(e){
      print('ERROR SUPABASE: $e');
    }finally{
      isLoading(false);
    }
  }
}
