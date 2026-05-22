import 'package:app_cabecera/controller/eventos_data_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get.dart';

class MostrarEventos extends StatefulWidget {
  final fecha;
  final hora;
  final deporte_evento;
  final evento;
  final senal;
  final fondo;
  final nombre;
  final deporteId;

  const MostrarEventos({super.key, this.fecha,this.hora, this.deporteId,this.deporte_evento,this.evento,this.senal,this.fondo, this.nombre,});

  @override
  State<MostrarEventos> createState() => _MostrarEventosState();
}

class _MostrarEventosState extends State<MostrarEventos>{

  final getEventsController = Get.put(GetEventsController());

  @override
  void initState(){
    getEventsController.getDataFromApi(widget.deporteId);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Obx(() {
  if (getEventsController.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }

  return ListView.builder(
    itemCount: getEventsController.getEventsModel.value.results.length,
    itemBuilder: (context, index) {
      final e = getEventsController.getEventsModel.value.results[index];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔷 HEADER
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.fecha,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.hora,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.senal,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // 🔽 CONTENIDO
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    e.deporte_evento ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(e.evento),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
});
  }

  Widget flechaAtras(){
    return Positioned(
      top: 40,
      left: 5,
      child: IconButton(
        icon: Icon(Icons.arrow_back), 
        color: const Color.fromARGB(255, 255, 255, 255),
        iconSize: 35,
        onPressed: (){
          Navigator.pop(context);
        },
      )            
    );
  }
}