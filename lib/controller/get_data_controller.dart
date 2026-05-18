import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/get_data_model.dart';

class GetDataController extends GetxController {

  RxBool isLoading = true.obs;

  Rx<GetDataModel> getDataModel =
      GetDataModel(results: []).obs;

  Future<void> getDataFromApi() async {

    try {

      isLoading(true);

      final response =
          await Supabase.instance.client
              .from('canal')
              .select();

      getDataModel.value =
          GetDataModel.fromJson(response);

    } catch (e) {

      print('ERROR SUPABASE: $e');

    } finally {

      isLoading(false);
    }
  }
}