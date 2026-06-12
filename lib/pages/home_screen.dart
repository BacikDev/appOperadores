import 'package:app_cabecera/controller/get_data_controller.dart';
import 'package:app_cabecera/pages/carrusel.dart';
import 'package:app_cabecera/pages/details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_cabecera/pages/mini_sensor_card.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState()=> _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  final getDataController = Get.put(GetDataController());

  @override
  void initState(){
    getDataController.getDataFromApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    var width = MediaQuery.of(context).size.width;

    return Obx(()=> 
    Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[50],
        elevation: 0,
        centerTitle: true,
        title: Text('Eventos Deportivos',
        style: TextStyle(
          fontWeight: FontWeight.bold
      ),),
      ),
      body: SafeArea(child:!getDataController.isLoading.value ? Stack(
        children: [
          Carrusel(),
       
          Padding(
  padding: const EdgeInsets.only(top: 165, left: 20, right: 12),
  child: Row(
    children: [
      const Icon(
        Icons.live_tv,
        color: Colors.deepPurple,
        size: 28,
      ),
      const SizedBox(width: 5),
      const Text(
        'Grilla de Canales',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      const MiniSensorCard(),
    ],
  ),
),
          Positioned(
            top: 200,
            bottom: 0,
            width: width,
            child: Column(
              children: [
                Expanded(
                  child: 
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5), 
                    itemCount: getDataController.getDataModel.value.results.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5
                          ),
                        child: InkWell(
                          child: SafeArea(child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                              color: Colors.green
                            ),
                            child: Stack(
                              children: [
                                logoCanal(index),
                                numeroDigital(index),
                                numeroAnalogico(index),
                              ],
                            ),
                          )),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_)=> DetailsScreen(
                              heroTag: index, 
                              canalLogo: getDataController.getDataModel.value.results[index].logo,
                              deco: getDataController.getDataModel.value.results[index].marcaDeco,
                              serie: getDataController.getDataModel.value.results[index].serieDeco,
                              estante: getDataController.getDataModel.value.results[index].estante,
                              proveedorNumero: getDataController.getDataModel.value.results[index].proveedorNumero,
                              proveedorNombre: getDataController.getDataModel.value.results[index].proveedorNombre,
                              numeroAnalogico: getDataController.getDataModel.value.results[index].numeroAnalogico,
                              numeroDigital: getDataController.getDataModel.value.results[index].numeroDigital,
                              fotoDeco: getDataController.getDataModel.value.results[index].fotoDeco,
                              fotoInfo: getDataController.getDataModel.value.results[index].fotoInfo,
                            )));
                          },
                        ),
                        );
                    },
                  )
                )
              ],
            ),
          )
        ],
      ):Center(child: CircularProgressIndicator()),)));
  }

  Widget logoCanal(index){
  return Positioned(
  child: ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(25)),
  child: Hero(
    tag: index,
    child:CachedNetworkImage(
    imageUrl: getDataController.getDataModel.value.results[index].logo,
    height: 150,
    fit: BoxFit.cover,
    placeholder: (context, url)=> Center(
      child: CircularProgressIndicator(),
    ),
  ))));
  }

  Widget numeroDigital(index){
    return Positioned(
      bottom: 5, 
      left: 10,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.green
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
          child: Text(getDataController.getDataModel.value.results[index].numeroDigital.toString(),
          style: TextStyle(
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(2.0,2.0),
              ),
            ],
            fontWeight: FontWeight.bold,
            fontSize: 15,
        
      ),))));
  }

  Widget numeroAnalogico(index){
    return Positioned(
      bottom: 5, 
      left: 55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.purple
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
          child: Text(
          getDataController.getDataModel.value.results[index].numeroAnalogico.toString(),
          style: TextStyle(
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(2.0,2.0),
              ),
            ],
            fontWeight: FontWeight.bold,
            fontSize: 15,
        
      ),))));
  }
}