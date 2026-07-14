import 'package:flutter/material.dart';

class ReclamosScreen extends StatefulWidget {
  const ReclamosScreen({super.key});

  @override
  State<ReclamosScreen> createState() => _ReclamosScreenState();
}

class _ReclamosScreenState extends State<ReclamosScreen> {
  static const Color backgroundColor = Color(0xFF020016);
  static const Color cardColor = Color(0xFF061D31);
  static const Color cardSecondaryColor = Color(0xFF07172B);
  static const Color borderColor = Color(0xFF234158);

  static const Color purpleColor = Color(0xFF8A5CFF);
  static const Color pinkColor = Color(0xFFFF4F81);
  static const Color blueColor = Color(0xFF1296FF);
  static const Color greenColor = Color(0xFF20D489);
  static const Color orangeColor = Color(0xFFFFA726);
  static const Color textSecondaryColor = Color(0xFF9BA6C7);

  String filtroSeleccionado = 'Todos';
  String busqueda = '';
  String ordenSeleccionado = 'Más recientes';

  final TextEditingController buscarController = TextEditingController();

  final List<ReclamoModel> reclamos = [
    ReclamoModel(
      id: '#2024-0056',
      titulo: 'Sin señal en Canal 2',
      barrio: 'Barrio Centro',
      fecha: '01/07/2025',
      hora: '10:15',
      estado: EstadoReclamo.sinTratar,
      tipo: ReclamoTipo.senal,
    ),
    ReclamoModel(
      id: '#2024-0055',
      titulo: 'Pixelado en Canal 5',
      barrio: 'Barrio 25 de Mayo',
      fecha: '01/07/2025',
      hora: '09:40',
      estado: EstadoReclamo.tratando,
      responsable: 'Juan P.',
      tipo: ReclamoTipo.imagen,
    ),
    ReclamoModel(
      id: '#2024-0054',
      titulo: 'Problemas de audio en Canal 7',
      barrio: 'Barrio San Martín',
      fecha: '30/06/2025',
      hora: '18:30',
      estado: EstadoReclamo.finalizado,
      responsable: 'María G.',
      tipo: ReclamoTipo.audio,
    ),
    ReclamoModel(
      id: '#2024-0053',
      titulo: 'Intermitencia de señal',
      barrio: 'Barrio San Cayetano',
      fecha: '30/06/2025',
      hora: '17:20',
      estado: EstadoReclamo.sinTratar,
      tipo: ReclamoTipo.senal,
    ),
    ReclamoModel(
      id: '#2024-0052',
      titulo: 'Sin imagen en Canal 10',
      barrio: 'Barrio Eva Perón',
      fecha: '30/06/2025',
      hora: '16:05',
      estado: EstadoReclamo.tratando,
      responsable: 'Luis A.',
      tipo: ReclamoTipo.imagen,
    ),
  ];

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  List<ReclamoModel> get reclamosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    final lista = reclamos.where((reclamo) {
      final coincideFiltro = filtroSeleccionado == 'Todos' ||
          reclamo.estado.texto == filtroSeleccionado;

      final coincideBusqueda = texto.isEmpty ||
          reclamo.titulo.toLowerCase().contains(texto) ||
          reclamo.barrio.toLowerCase().contains(texto) ||
          reclamo.id.toLowerCase().contains(texto) ||
          (reclamo.responsable ?? '').toLowerCase().contains(texto);

      return coincideFiltro && coincideBusqueda;
    }).toList();

    if (ordenSeleccionado == 'Más antiguos') {
      return lista.reversed.toList();
    }

    return lista;
  }

  int contarEstado(EstadoReclamo estado) {
    return reclamos.where((reclamo) => reclamo.estado == estado).length;
  }

  @override
  Widget build(BuildContext context) {
    final sinTratar = contarEstado(EstadoReclamo.sinTratar);
    final tratando = contarEstado(EstadoReclamo.tratando);
    final finalizados = contarEstado(EstadoReclamo.finalizado);

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: purpleColor,
        foregroundColor: Colors.white,
        elevation: 10,
        onPressed: _mostrarFormularioNuevoReclamo,
        icon: const Icon(Icons.add_rounded, size: 27),
        label: const Text(
          'Nuevo reclamo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RESUMEN GENERAL',
                      style: TextStyle(
                        color: purpleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _resumenGeneral(
                      sinTratar: sinTratar,
                      tratando: tratando,
                      finalizados: finalizados,
                      total: reclamos.length,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'FILTROS Y BÚSQUEDA',
                      style: TextStyle(
                        color: purpleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buscadorYOrden(),
                    const SizedBox(height: 12),
                    _filtrosEstado(
                      sinTratar: sinTratar,
                      tratando: tratando,
                      finalizados: finalizados,
                    ),
                    const SizedBox(height: 14),
                    if (reclamosFiltrados.isEmpty)
                      _estadoVacio()
                    else
                      ...reclamosFiltrados.map(_reclamoCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF151A38),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Volver',
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.report_problem_rounded,
                      color: pinkColor,
                      size: 31,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'RECLAMOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  'Gestión de reclamos del sistema',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notificaciones',
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (contarEstado(EstadoReclamo.sinTratar) > 0)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      color: pinkColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      contarEstado(EstadoReclamo.sinTratar).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumenGeneral({
    required int sinTratar,
    required int tratando,
    required int finalizados,
    required int total,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: ancho,
              child: _resumenItem(
                icon: Icons.access_time_rounded,
                cantidad: sinTratar,
                texto: 'Sin tratar',
                color: orangeColor,
              ),
            ),
            SizedBox(
              width: ancho,
              child: _resumenItem(
                icon: Icons.build_rounded,
                cantidad: tratando,
                texto: 'Tratando',
                color: blueColor,
              ),
            ),
            SizedBox(
              width: ancho,
              child: _resumenItem(
                icon: Icons.check_rounded,
                cantidad: finalizados,
                texto: 'Finalizados',
                color: greenColor,
              ),
            ),
            SizedBox(
              width: ancho,
              child: _resumenItem(
                icon: Icons.assignment_rounded,
                cantidad: total,
                texto: 'Total reclamos',
                color: purpleColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resumenItem({
    required IconData icon,
    required int cantidad,
    required String texto,
    required Color color,
  }) {
    return Container(
      height: 145,
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.25),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cantidad.toString(),
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            texto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buscadorYOrden() {
    return Column(
      children: [
        TextField(
          controller: buscarController,
          onChanged: (value) {
            setState(() {
              busqueda = value;
            });
          },
          style: const TextStyle(
            color: Colors.white,
          ),
          cursorColor: purpleColor,
          decoration: InputDecoration(
            hintText: 'Buscar reclamo...',
            hintStyle: const TextStyle(
              color: textSecondaryColor,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: textSecondaryColor,
            ),
            suffixIcon: busqueda.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      buscarController.clear();

                      setState(() {
                        busqueda = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: textSecondaryColor,
                    ),
                  )
                : null,
            filled: true,
            fillColor: cardSecondaryColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(
              color: purpleColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.filter_list_rounded,
                texto: 'Filtros',
                onTap: _mostrarFiltros,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PopupMenuButton<String>(
                color: cardColor,
                initialValue: ordenSeleccionado,
                onSelected: (value) {
                  setState(() {
                    ordenSeleccionado = value;
                  });
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'Más recientes',
                      child: Text(
                        'Más recientes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'Más antiguos',
                      child: Text(
                        'Más antiguos',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ];
                },
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cardSecondaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          ordenSeleccionado,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: cardSecondaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtrosEstado({
    required int sinTratar,
    required int tratando,
    required int finalizados,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cardSecondaryColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filtroItem(
              titulo: 'Todos',
              cantidad: reclamos.length,
              color: purpleColor,
            ),
            _filtroItem(
              titulo: EstadoReclamo.sinTratar.texto,
              cantidad: sinTratar,
              color: orangeColor,
            ),
            _filtroItem(
              titulo: EstadoReclamo.tratando.texto,
              cantidad: tratando,
              color: blueColor,
            ),
            _filtroItem(
              titulo: EstadoReclamo.finalizado.texto,
              cantidad: finalizados,
              color: greenColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroItem({
    required String titulo,
    required int cantidad,
    required Color color,
  }) {
    final seleccionado = filtroSeleccionado == titulo;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSeleccionado = titulo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            bottom: BorderSide(
              color: seleccionado ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: seleccionado ? color : textSecondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),
              child: Text(
                cantidad.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reclamoCard(ReclamoModel reclamo) {
    final color = reclamo.estado.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            _mostrarDetalleReclamo(reclamo);
          },
          onLongPress: () {
            _mostrarOpcionesReclamo(reclamo);
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.25),
                    ),
                  ),
                  child: Icon(
                    reclamo.tipo.icono,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 5,
                        children: [
                          Text(
                            reclamo.id,
                            style: const TextStyle(
                              color: textSecondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _estadoBadge(reclamo.estado),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reclamo.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: textSecondaryColor,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reclamo.barrio,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: textSecondaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            reclamo.fecha,
                            style: const TextStyle(
                              color: textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            '  •  ',
                            style: TextStyle(
                              color: textSecondaryColor,
                            ),
                          ),
                          Text(
                            reclamo.hora,
                            style: const TextStyle(
                              color: textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (reclamo.responsable != null) ...[
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              color: purpleColor,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              reclamo.responsable!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondaryColor,
                  size: 29,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoBadge(EstadoReclamo estado) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: estado.color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estado.color.withOpacity(0.25),
        ),
      ),
      child: Text(
        estado.texto,
        style: TextStyle(
          color: estado.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 46,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: purpleColor,
            size: 58,
          ),
          SizedBox(height: 14),
          Text(
            'No se encontraron reclamos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Probá cambiando el filtro o la búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder({
    Color color = borderColor,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: color,
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Filtrar reclamos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 17),
                ...[
                  'Todos',
                  EstadoReclamo.sinTratar.texto,
                  EstadoReclamo.tratando.texto,
                  EstadoReclamo.finalizado.texto,
                ].map(
                  (filtro) => RadioListTile<String>(
                    value: filtro,
                    groupValue: filtroSeleccionado,
                    activeColor: purpleColor,
                    title: Text(
                      filtro,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        filtroSeleccionado = value;
                      });

                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetalleReclamo(ReclamoModel reclamo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(bottomSheetContext).viewInsets.bottom + 25,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: reclamo.estado.color.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        reclamo.tipo.icono,
                        color: reclamo.estado.color,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reclamo.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detalleFila('Número', reclamo.id),
                _detalleFila('Estado', reclamo.estado.texto),
                _detalleFila('Ubicación', reclamo.barrio),
                _detalleFila(
                  'Fecha y hora',
                  '${reclamo.fecha} - ${reclamo.hora}',
                ),
                _detalleFila(
                  'Responsable',
                  reclamo.responsable ?? 'Sin asignar',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cambiar estado',
                  style: TextStyle(
                    color: purpleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EstadoReclamo.values.map((estado) {
                    return ChoiceChip(
                      selected: reclamo.estado == estado,
                      selectedColor: estado.color.withOpacity(0.25),
                      backgroundColor: cardSecondaryColor,
                      side: BorderSide(
                        color: estado.color.withOpacity(0.5),
                      ),
                      label: Text(
                        estado.texto,
                        style: TextStyle(
                          color: estado.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          reclamo.estado = estado;
                        });

                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalleFila(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              titulo,
              style: const TextStyle(
                color: textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesReclamo(ReclamoModel reclamo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_rounded,
                    color: blueColor,
                  ),
                  title: const Text(
                    'Cambiar estado',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _mostrarDetalleReclamo(reclamo);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: pinkColor,
                  ),
                  title: const Text(
                    'Eliminar reclamo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _confirmarEliminar(reclamo);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(ReclamoModel reclamo) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Eliminar reclamo',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Deseás eliminar el reclamo ${reclamo.id}?',
            style: const TextStyle(
              color: textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: textSecondaryColor,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: pinkColor,
              ),
              onPressed: () {
                setState(() {
                  reclamos.remove(reclamo);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormularioNuevoReclamo() {
    final tituloController = TextEditingController();
    final barrioController = TextEditingController();
    final responsableController = TextEditingController();

    ReclamoTipo tipoSeleccionado = ReclamoTipo.senal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textSecondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: purpleColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Nuevo reclamo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _campoFormulario(
                        controller: tituloController,
                        label: 'Título del reclamo',
                        icon: Icons.report_problem_outlined,
                      ),
                      const SizedBox(height: 12),
                      _campoFormulario(
                        controller: barrioController,
                        label: 'Barrio o ubicación',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _campoFormulario(
                        controller: responsableController,
                        label: 'Responsable (opcional)',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 17),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tipo de reclamo',
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReclamoTipo.values.map((tipo) {
                          return ChoiceChip(
                            selected: tipoSeleccionado == tipo,
                            selectedColor: purpleColor.withOpacity(0.25),
                            backgroundColor: cardSecondaryColor,
                            side: BorderSide(
                              color: tipoSeleccionado == tipo
                                  ? purpleColor
                                  : borderColor,
                            ),
                            avatar: Icon(
                              tipo.icono,
                              color: tipoSeleccionado == tipo
                                  ? purpleColor
                                  : textSecondaryColor,
                              size: 18,
                            ),
                            label: Text(
                              tipo.texto,
                              style: TextStyle(
                                color: tipoSeleccionado == tipo
                                    ? Colors.white
                                    : textSecondaryColor,
                              ),
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                tipoSeleccionado = tipo;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: purpleColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          onPressed: () {
                            final titulo = tituloController.text.trim();
                            final barrio = barrioController.text.trim();

                            if (titulo.isEmpty || barrio.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Completá el título y la ubicación.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final ahora = DateTime.now();

                            setState(() {
                              reclamos.insert(
                                0,
                                ReclamoModel(
                                  id: _generarNuevoId(),
                                  titulo: titulo,
                                  barrio: barrio,
                                  fecha:
                                      '${ahora.day.toString().padLeft(2, '0')}/'
                                      '${ahora.month.toString().padLeft(2, '0')}/'
                                      '${ahora.year}',
                                  hora:
                                      '${ahora.hour.toString().padLeft(2, '0')}:'
                                      '${ahora.minute.toString().padLeft(2, '0')}',
                                  estado: EstadoReclamo.sinTratar,
                                  responsable:
                                      responsableController.text.trim().isEmpty
                                          ? null
                                          : responsableController.text.trim(),
                                  tipo: tipoSeleccionado,
                                ),
                              );
                            });

                            Navigator.pop(bottomSheetContext);
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text(
                            'Guardar reclamo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _campoFormulario({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      cursorColor: purpleColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: textSecondaryColor,
        ),
        prefixIcon: Icon(
          icon,
          color: purpleColor,
        ),
        filled: true,
        fillColor: cardSecondaryColor,
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(
          color: purpleColor,
        ),
      ),
    );
  }

  String _generarNuevoId() {
    final numero = 57 + reclamos.length;

    return '#2024-${numero.toString().padLeft(4, '0')}';
  }
}

class ReclamoModel {
  final String id;
  final String titulo;
  final String barrio;
  final String fecha;
  final String hora;
  final ReclamoTipo tipo;

  EstadoReclamo estado;
  String? responsable;

  ReclamoModel({
    required this.id,
    required this.titulo,
    required this.barrio,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.tipo,
    this.responsable,
  });
}

enum EstadoReclamo {
  sinTratar,
  tratando,
  finalizado,
}

extension EstadoReclamoExtension on EstadoReclamo {
  String get texto {
    switch (this) {
      case EstadoReclamo.sinTratar:
        return 'Sin tratar';
      case EstadoReclamo.tratando:
        return 'Tratando';
      case EstadoReclamo.finalizado:
        return 'Finalizado';
    }
  }

  Color get color {
    switch (this) {
      case EstadoReclamo.sinTratar:
        return const Color(0xFFFFA726);
      case EstadoReclamo.tratando:
        return const Color(0xFF1296FF);
      case EstadoReclamo.finalizado:
        return const Color(0xFF20D489);
    }
  }
}

enum ReclamoTipo {
  senal,
  imagen,
  audio,
}

extension ReclamoTipoExtension on ReclamoTipo {
  String get texto {
    switch (this) {
      case ReclamoTipo.senal:
        return 'Señal';
      case ReclamoTipo.imagen:
        return 'Imagen';
      case ReclamoTipo.audio:
        return 'Audio';
    }
  }

  IconData get icono {
    switch (this) {
      case ReclamoTipo.senal:
        return Icons.wifi_rounded;
      case ReclamoTipo.imagen:
        return Icons.tv_rounded;
      case ReclamoTipo.audio:
        return Icons.volume_up_rounded;
    }
  }
}