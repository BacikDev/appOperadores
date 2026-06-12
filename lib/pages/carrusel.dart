import 'package:app_cabecera/controller/carrusel_data_controller.dart';
import 'package:app_cabecera/pages/details_events.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class Carrusel extends StatefulWidget {
  const Carrusel({super.key});

  @override
  State<Carrusel> createState() => _CarruselState();
}

class _CarruselState extends State<Carrusel> {
  final getCarruselController = Get.put(GetCarruselController());

  @override
  void initState(){
    getCarruselController.getDataFromApi('banner');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Obx(()=>
    Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(child: !getCarruselController.isLoading.value ? Stack(
        children: [
          CarouselSlider.builder(itemCount: getCarruselController.getCarruselModel.value.results.length, itemBuilder: (context, index, realIndex){
            final carruselImage = getCarruselController.getCarruselModel.value.results[index];
            return CardImages(carruselImage: carruselImage);
          }, options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            autoPlayInterval: Duration(seconds: 5),
            scrollDirection: Axis.horizontal,
          )),
        ],
      ):Center(child: CircularProgressIndicator()),),
    ));
  }
}

class CardImages extends StatelessWidget {
  final carruselImage;

  const CardImages({super.key, required this.carruselImage,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: (){
            Navigator.push(context,
            MaterialPageRoute(builder: (_) => MostrarEventos(
              deporteId: carruselImage.id,
              nombre: carruselImage.name, 
              fondo: carruselImage.fondo, 
            )));
          },
          child: CachedNetworkImage(
  imageUrl: carruselImage.fondo,
  fit: BoxFit.cover,
),
        ),
      ),
    );
  }

}