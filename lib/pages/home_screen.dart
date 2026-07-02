import 'package:app_cabecera/controller/eventos_hoy_controller.dart';
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
  final eventosHoyController = Get.put(EventosHoyController());

  @override
  void initState() {
    getDataController.getDataFromApi();
    eventosHoyController.getEventosHoy();
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
        title: Text('El Líder Junto a vos',
        style: TextStyle(
          fontWeight: FontWeight.bold
      ),),
      ),
      body: SafeArea(child:!getDataController.isLoading.value ? Stack(
        children: [
          Carrusel(),
          Padding(
  padding: const EdgeInsets.only(top: 105, left: 20, right: 12),
  child: Row(
    children: [
      const Icon(
        Icons.live_tv,
        color: Colors.deepPurple,
        size: 20,
      ),
      const SizedBox(width: 5),
      const Text(
        'Grilla de Canales',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      const MiniSensorCard(),
    ],
  ),
),
          Positioned(
            top: 140,
            bottom: 220,
            width: width,
            child: Column(
              children: [
                Expanded(
                  child: 
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.5), 
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
                ),
              ],
            ),
          ),
              Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  height: 230,
  child: eventosDelDiaContainer(),
),
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
  Widget eventosDelDiaContainer() {
  return Obx(() {
    if (eventosHoyController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventosHoyController.eventos.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Text(
            'No hay eventos próximos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.deepPurple, size: 22),
              SizedBox(width: 8),
              Text(
                'Eventos próximos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff17172F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: eventosHoyController.eventos.length,
              itemBuilder: (context, index) {
                final evento = eventosHoyController.eventos[index];

                return _eventoProximoItem(evento);
              },
            ),
          ),
        ],
      ),
    );
  });
}

Widget _eventoProximoItem(Map<String, dynamic> evento) {
  final fecha = evento['fecha']?.toString() ?? '';
  final hora = evento['hora']?.toString() ?? '';
  final titulo = evento['evento']?.toString() ?? '';
  final deporteEvento = evento['deporte_evento']?.toString() ?? '';
  final logoCanal = evento['logo_canal']?.toString() ?? '';

  final fechaFormateada = _formatearFechaEvento(fecha);

  return Container(
    height: 70,
    margin: const EdgeInsets.only(bottom: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.withOpacity(0.22),
      ),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fechaFormateada['diaTexto']!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 107, 74, 255),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                fechaFormateada['diaNumero']!,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                fechaFormateada['mes']!,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 1,
          height: double.infinity,
          color: Colors.grey.withOpacity(0.20),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hora,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff111122),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                deporteEvento,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 64,
          height: 67,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.25),
            ),
          ),
          child: logoCanal.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: logoCanal,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.live_tv,
                    color: Colors.deepPurple,
                  ),
                )
              : const Icon(
                  Icons.live_tv,
                  color: Colors.deepPurple,
                ),
        ),
      ],
    ),
  );
}

Map<String, String> _formatearFechaEvento(String fecha) {
  try {
    final date = DateTime.parse(fecha);
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    String diaTexto;

    if (_mismaFecha(date, today)) {
      diaTexto = 'HOY';
    } else if (_mismaFecha(date, tomorrow)) {
      diaTexto = 'MAÑANA';
    } else {
      diaTexto = _nombreDia(date.weekday);
    }

    return {
      'diaTexto': diaTexto,
      'diaNumero': date.day.toString(),
      'mes': _nombreMes(date.month),
    };
  } catch (e) {
    return {
      'diaTexto': fecha,
      'diaNumero': '',
      'mes': '',
    };
  }
}

bool _mismaFecha(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _nombreDia(int weekday) {
  switch (weekday) {
    case 1:
      return 'LUN';
    case 2:
      return 'MAR';
    case 3:
      return 'MIÉ';
    case 4:
      return 'JUE';
    case 5:
      return 'VIE';
    case 6:
      return 'SÁB';
    case 7:
      return 'DOM';
    default:
      return '';
  }
}

String _nombreMes(int month) {
  switch (month) {
    case 1:
      return 'ENE';
    case 2:
      return 'FEB';
    case 3:
      return 'MAR';
    case 4:
      return 'ABR';
    case 5:
      return 'MAY';
    case 6:
      return 'JUN';
    case 7:
      return 'JUL';
    case 8:
      return 'AGO';
    case 9:
      return 'SEP';
    case 10:
      return 'OCT';
    case 11:
      return 'NOV';
    case 12:
      return 'DIC';
    default:
      return '';
  }
}
}