import 'package:app_cabecera/controller/get_data_events.dart';
import 'package:app_cabecera/models/get_events_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carrusel extends StatefulWidget {
  const Carrusel({super.key});

  @override
  State<Carrusel> createState() => _CarruselState();
}

class _CarruselState extends State<Carrusel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          CarouselSlider.builder(itemCount: carruselImages.length, itemBuilder: (context, index, realIndex){
            final carruselImage = carruselImages[index];
            return CardImages(carruselImages: carruselImages[index],);
          }, options: CarouselOptions(
            height: 150.0,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            autoPlayInterval: Duration(seconds: 5),
            scrollDirection: Axis.horizontal,
          ))
        ],
      ),
    );
  }
}

class CardImages extends StatelessWidget {
  final Event carruselImages;

  const CardImages({super.key, required this.carruselImages});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: (){},
          child: FadeInImage(
  placeholder: const AssetImage('images/loading1.gif'),
  image: NetworkImage(carruselImages.image),
  fit: BoxFit.cover,
),
        ),
      ),
    );
  }
}