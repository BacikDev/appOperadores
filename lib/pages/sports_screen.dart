import 'package:app_cabecera/controller/eventos_data_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({
    super.key,
    this.deporteId,
    this.nombre,
    this.fondo,
  });

  final int? deporteId;
  final String? nombre;
  final String? fondo;

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  final GetEventsController getEventsController = Get.put(GetEventsController());

  late int deporteSeleccionado;
  late String nombreSeleccionado;

  final List<Map<String, dynamic>> deportes = [
    {
      'id': 1,
      'nombre': 'Fútbol',
      'imagen':
          'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=500',
    },
    {
      'id': 2,
      'nombre': 'Tenis',
      'imagen':
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=500',
    },
    {
      'id': 3,
      'nombre': 'F1',
      'imagen':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500',
    },
    {
      'id': 4,
      'nombre': 'Mundial',
      'imagen':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=500',
    },
    {
      'id': 5,
      'nombre': 'Handball',
      'imagen':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=500',
    },
    {
      'id': 6,
      'nombre': 'Rugby',
      'imagen':
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=500',
    },
    {
      'id': 7,
      'nombre': 'Boxeo',
      'imagen':
          'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=500',
    },
    {
      'id': 10,
      'nombre': 'Vóley',
      'imagen':
          'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=500',
    },
    {
      'id': 14,
      'nombre': 'Básquet',
      'imagen':
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500',
    },
  ];
  String obtenerEtiquetaFecha(String fecha) {
  final fechaEvento = DateTime.tryParse(fecha);
  if (fechaEvento == null) return '';

  final hoy = DateTime.now();

  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  final eventoSinHora = DateTime(
    fechaEvento.year,
    fechaEvento.month,
    fechaEvento.day,
  );

  final diferencia = eventoSinHora.difference(hoySinHora).inDays;

  if (diferencia == 0) return 'HOY';
  if (diferencia == 1) return 'MAÑANA';

  const dias = [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO',
    'DOMINGO',
  ];

  return dias[fechaEvento.weekday - 1];
}

Color obtenerColorFecha(String fecha) {
  final etiqueta = obtenerEtiquetaFecha(fecha);

  if (etiqueta == 'HOY') {
    return const Color(0xFF22C55E);
  }

  if (etiqueta == 'MAÑANA') {
    return const Color(0xFFF97316);
  }

  return const Color(0xFF6D3DF5);
}

String obtenerHora(String hora) {
  if (hora.isEmpty) return 'Sin hora';
  if (hora.length >= 5) return hora.substring(0, 5);
  return hora;
}

  @override
  void initState() {
    super.initState();

    deporteSeleccionado = widget.deporteId ?? 1;
    nombreSeleccionado = widget.nombre ?? 'Fútbol';

    getEventsController.getDataFromApi(deporteSeleccionado);
  }

  void cambiarDeporte(Map<String, dynamic> deporte) {
    setState(() {
      deporteSeleccionado = deporte['id'];
      nombreSeleccionado = deporte['nombre'];
    });

    getEventsController.getDataFromApi(deporteSeleccionado);
  }

  String obtenerDia(String fecha) {
    if (fecha.isEmpty) return '';

    final partesGuion = fecha.split('-');
    if (partesGuion.length == 3) {
      return partesGuion[2];
    }

    final partesBarra = fecha.split('/');
    if (partesBarra.length >= 2) {
      return partesBarra[0];
    }

    return fecha;
  }

  String obtenerMes(String fecha) {
    final meses = [
      '',
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];

    final partesGuion = fecha.split('-');
    if (partesGuion.length == 3) {
      final mes = int.tryParse(partesGuion[1]) ?? 0;
      return mes > 0 && mes < meses.length ? meses[mes] : '';
    }

    final partesBarra = fecha.split('/');
    if (partesBarra.length >= 2) {
      final mes = int.tryParse(partesBarra[1]) ?? 0;
      return mes > 0 && mes < meses.length ? meses[mes] : '';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text(
              'Eventos Deportivos',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 22),

            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: deportes.length,
                itemBuilder: (context, index) {
                  final deporte = deportes[index];
                  final seleccionado = deporteSeleccionado == deporte['id'];

                  return GestureDetector(
                    onTap: () => cambiarDeporte(deporte),
                    child: Container(
                      width: 145,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: seleccionado
                            ? Border.all(
                                color: const Color(0xFF6D3DF5),
                                width: 4,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: deporte['imagen'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade300,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 13,
                              child: Text(
                                deporte['nombre'].toString().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 18,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Obx(() {
                  if (getEventsController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final eventos =
                      getEventsController.getEventsModel.value.results;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF6D3DF5),
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Eventos del día',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                nombreSeleccionado,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: eventos.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay eventos disponibles',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: eventos.length,
                                itemBuilder: (context, index) {
                                  final e = eventos[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Column(
                                            children: [
                                               Text(
                                                 obtenerEtiquetaFecha(e.fecha),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: obtenerColorFecha(e.fecha),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                obtenerDia(e.fecha),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: obtenerColorFecha(e.fecha),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 32,
                                                ),
                                              ),
                                              Text(
                                                obtenerMes(e.fecha),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          width: 1,
                                          height: 75,
                                          color: Colors.grey.shade200,
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                               obtenerHora(e.hora),
                                                style: const TextStyle(
                                                  color: Color(0xFF6D3DF5),
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                e.evento,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF111827),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                e.deporteEvento,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Container(
                                          width: 88,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Center(
                                              child: e.canales.isNotEmpty
                                                  ? Wrap(
                                                      spacing: 6,
                                                      runSpacing: -10,
                                                      alignment: WrapAlignment.center,
                                                      children: e.canales.map((canal) {
                                                        return SizedBox(
                                                          width: 100,
                                                          height: 40,
                                                          child: CachedNetworkImage(
                                                            imageUrl: canal.logo,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        );
                                                      }).toList(),
                                                    )
                                                  : Text(
                                                      e.senal,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w900,
                                                        color: Color(0xFF111827),
                                                      ),
                                                    ),
                                            ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}