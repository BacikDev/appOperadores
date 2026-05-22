import 'package:flutter/material.dart';

class MostrarEventos extends StatefulWidget {
  final fecha;
  final hora;
  final deporte_evento;
  final evento;
  final senal;
  final fondo;

  const MostrarEventos({super.key, this.fecha,this.hora,this.deporte_evento,this.evento,this.senal,this.fondo});

  @override
  State<MostrarEventos> createState() => _MostrarEventosState();
}

class _MostrarEventosState extends State<MostrarEventos>{
  get eventos => null;

  @override
  Widget build(BuildContext context){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.8,
              padding:EdgeInsetsDirectional.only(top: 20, bottom: 100),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
              ),
              child: Expanded(
  child: ListView.builder(
    itemCount: 10, // 👈 datos desde Supabase
    itemBuilder: (context, index) {
      final item = 20;

      return  Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 HEADER
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
  children: [
    Expanded(
      flex: 2, // 👈 menos espacio
      child: Text(
        "Fecha: DOM 22",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
    Expanded(
      flex: 2, // 👈 menos espacio
      child: Text(
        "Hora: 21:30",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
    Expanded(
      flex: 3, // 👈 más espacio para señal
      child: Text(
        "Señal: ESPN PREMIUM",
        textAlign: TextAlign.end,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
  ],
)
            ),

            // 🔽 CONTENIDO
            Padding(
  padding: EdgeInsets.all(10),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center, // 👈 centra horizontal
    children: [
      Text(
        'FUTBOL DE PRIMERA',
        textAlign: TextAlign.center, // 👈 por las dudas
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Boca Vs River',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    ],
  ),
)
          ],
        ),
      );
    },
  ),
)
            )
          )
        ],
      )
    );
  }
}