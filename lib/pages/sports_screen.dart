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
  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _cardSecondary = Color(0xFF101A2E);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _green = Color(0xFF20D489);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _pink = Color(0xFFFF4F81);
  static const Color _blue = Color(0xFF1296FF);
  static const Color _textSecondary = Color(0xFF9BA6C7);

  final GetEventsController getEventsController =
      Get.put(GetEventsController());

  late int deporteSeleccionado;
  late String nombreSeleccionado;

  final List<Map<String, dynamic>> deportes = [
    {
      'id': 1,
      'nombre': 'Fútbol',
      'imagen':
          'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=700',
    },
    {
      'id': 2,
      'nombre': 'Tenis',
      'imagen':
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=700',
    },
    {
      'id': 3,
      'nombre': 'F1',
      'imagen':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700',
    },
    {
      'id': 4,
      'nombre': 'Mundial',
      'imagen':
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=700',
    },
    {
      'id': 5,
      'nombre': 'Handball',
      'imagen':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=700',
    },
    {
      'id': 6,
      'nombre': 'Rugby',
      'imagen':
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=700',
    },
    {
      'id': 7,
      'nombre': 'Boxeo',
      'imagen':
          'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=700',
    },
    {
      'id': 10,
      'nombre': 'Vóley',
      'imagen':
          'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=700',
    },
    {
      'id': 14,
      'nombre': 'Básquet',
      'imagen':
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=700',
    },
  ];

  @override
  void initState() {
    super.initState();

    deporteSeleccionado = widget.deporteId ?? 1;
    nombreSeleccionado = widget.nombre ?? 'Fútbol';

    getEventsController.getDataFromApi(deporteSeleccionado);
  }

  Future<void> _actualizar() async {
    await getEventsController.getDataFromApi(deporteSeleccionado);
  }

  void _cambiarDeporte(Map<String, dynamic> deporte) {
    setState(() {
      deporteSeleccionado = deporte['id'] as int;
      nombreSeleccionado = deporte['nombre'].toString();
    });

    getEventsController.getDataFromApi(deporteSeleccionado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Eventos deportivos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _purple,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _purple,
          backgroundColor: _card,
          onRefresh: _actualizar,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildSportsSelector(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                sliver: SliverToBoxAdapter(
                  child: _buildEventsHeader(),
                ),
              ),
              Obx(() {
                if (getEventsController.isLoading.value) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  );
                }

                final eventos =
                    getEventsController.getEventsModel.value.results;

                if (eventos.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      sportName: nombreSeleccionado,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final evento = eventos[index];

                        return _EventCard(
                          fecha: evento.fecha?.toString() ?? '',
                          hora: evento.hora?.toString() ?? '',
                          evento: evento.evento?.toString() ??
                              'Evento sin nombre',
                          deporte: evento.deporteEvento?.toString() ??
                              nombreSeleccionado,
                          senal: evento.senal?.toString() ?? '',
                          canales: evento.canales,
                          obtenerEtiquetaFecha: _obtenerEtiquetaFecha,
                          obtenerColorFecha: _obtenerColorFecha,
                          obtenerDia: _obtenerDia,
                          obtenerMes: _obtenerMes,
                          obtenerHora: _obtenerHora,
                        );
                      },
                      childCount: eventos.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                color: _green,
                size: 29,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AGENDA DEPORTIVA',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Eventos de $nombreSeleccionado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Seleccioná un deporte para consultar su programación.',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsSelector() {
    return SizedBox(
      height: 142,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: deportes.length,
        itemBuilder: (context, index) {
          final deporte = deportes[index];
          final seleccionado =
              deporteSeleccionado == deporte['id'];

          return _SportCard(
            name: deporte['nombre'].toString(),
            imageUrl: deporte['imagen'].toString(),
            selected: seleccionado,
            onTap: () => _cambiarDeporte(deporte),
          );
        },
      ),
    );
  }

  Widget _buildEventsHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: _purple,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRÓXIMOS EVENTOS',
                style: TextStyle(
                  color: _purple,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                nombreSeleccionado,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _obtenerEtiquetaFecha(String fecha) {
    final fechaEvento = DateTime.tryParse(fecha);
    if (fechaEvento == null) return '';

    final hoy = DateTime.now();

    final hoySinHora = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    );

    final eventoSinHora = DateTime(
      fechaEvento.year,
      fechaEvento.month,
      fechaEvento.day,
    );

    final diferencia =
        eventoSinHora.difference(hoySinHora).inDays;

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

  Color _obtenerColorFecha(String fecha) {
    final etiqueta = _obtenerEtiquetaFecha(fecha);

    if (etiqueta == 'HOY') return _green;
    if (etiqueta == 'MAÑANA') return _orange;

    return _purple;
  }

  String _obtenerHora(String hora) {
    if (hora.trim().isEmpty) return 'Sin hora';
    if (hora.length >= 5) return hora.substring(0, 5);
    return hora;
  }

  String _obtenerDia(String fecha) {
    if (fecha.isEmpty) return '--';

    final fechaParseada = DateTime.tryParse(fecha);
    if (fechaParseada != null) {
      return fechaParseada.day.toString().padLeft(2, '0');
    }

    final partes = fecha.split('/');
    if (partes.isNotEmpty) return partes.first;

    return '--';
  }

  String _obtenerMes(String fecha) {
    const meses = [
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

    final fechaParseada = DateTime.tryParse(fecha);

    if (fechaParseada != null) {
      return meses[fechaParseada.month];
    }

    final partes = fecha.split('/');

    if (partes.length >= 2) {
      final mes = int.tryParse(partes[1]) ?? 0;

      if (mes > 0 && mes < meses.length) {
        return meses[mes];
      }
    }

    return '';
  }
}

class _SportCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _SportCard({
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A5CFF);
    const green = Color(0xFF20D489);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          width: 128,
          margin: const EdgeInsets.only(right: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected
                  ? purple
                  : Colors.white10,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.23),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: const Color(0xFF101A2E),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: purple,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF101A2E),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF9BA6C7),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xE8050B18),
                    ],
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 23,
                    height: 23,
                    decoration: const BoxDecoration(
                      color: green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF050B18),
                      size: 15,
                    ),
                  ),
                ),
              Positioned(
                left: 9,
                right: 9,
                bottom: 11,
                child: Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String fecha;
  final String hora;
  final String evento;
  final String deporte;
  final String senal;
  final dynamic canales;

  final String Function(String) obtenerEtiquetaFecha;
  final Color Function(String) obtenerColorFecha;
  final String Function(String) obtenerDia;
  final String Function(String) obtenerMes;
  final String Function(String) obtenerHora;

  const _EventCard({
    required this.fecha,
    required this.hora,
    required this.evento,
    required this.deporte,
    required this.senal,
    required this.canales,
    required this.obtenerEtiquetaFecha,
    required this.obtenerColorFecha,
    required this.obtenerDia,
    required this.obtenerMes,
    required this.obtenerHora,
  });

  @override
  Widget build(BuildContext context) {
    final colorFecha = obtenerColorFecha(fecha);

    final listaCanales = canales is List
        ? canales as List
        : const [];

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: colorFecha.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: colorFecha.withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              children: [
                Text(
                  obtenerEtiquetaFecha(fecha),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorFecha,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  obtenerDia(fecha),
                  style: TextStyle(
                    color: colorFecha,
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  obtenerMes(fecha),
                  style: const TextStyle(
                    color: Color(0xFF9BA6C7),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF8A5CFF),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      obtenerHora(hora),
                      style: const TextStyle(
                        color: Color(0xFF8A5CFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  evento,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.sports_rounded,
                      color: Color(0xFF9BA6C7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        deporte,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9BA6C7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Container(
            width: 82,
            constraints: const BoxConstraints(
              minHeight: 82,
            ),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 253, 254),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: listaCanales.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listaCanales.take(2).map<Widget>((canal) {
                      final logo = canal.logo?.toString() ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: SizedBox(
                          width: 68,
                          height: 30,
                          child: CachedNetworkImage(
                            imageUrl: logo,
                            fit: BoxFit.contain,
                            placeholder: (_, __) =>
                                const SizedBox.shrink(),
                            errorWidget: (_, __, ___) =>
                                const Icon(
                              Icons.tv_off_rounded,
                              color: Color(0xFF9BA6C7),
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text(
                      senal.trim().isEmpty
                          ? 'Sin señal'
                          : senal,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8A5CFF),
            strokeWidth: 3,
          ),
          SizedBox(height: 14),
          Text(
            'Cargando eventos...',
            style: TextStyle(
              color: Color(0xFF9BA6C7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String sportName;

  const _EmptyState({
    required this.sportName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF8A5CFF)
                    .withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFF8A5CFF),
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No hay eventos disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Todavía no hay eventos cargados para $sportName.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9BA6C7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
