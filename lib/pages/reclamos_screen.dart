import 'package:flutter/material.dart';

class ReclamosScreen extends StatefulWidget {
  const ReclamosScreen({super.key});

  @override
  State<ReclamosScreen> createState() => _ReclamosScreenState();
}

class _ReclamosScreenState extends State<ReclamosScreen> {
  String filtroSeleccionado = 'Todos';
  String busqueda = '';

  final List<ReclamoModel> reclamos = [
    ReclamoModel(
      id: '#2024-0056',
      titulo: 'Sin señal en Canal 2',
      barrio: 'Barrio Centro',
      fecha: '01/07/2025',
      hora: '10:15',
      estado: 'Sin tratar',
      tipo: ReclamoTipo.senal,
    ),
    ReclamoModel(
      id: '#2024-0055',
      titulo: 'Pixelado en Canal 5',
      barrio: 'Barrio 25 de Mayo',
      fecha: '01/07/2025',
      hora: '09:40',
      estado: 'Tratando',
      responsable: 'Juan P.',
      tipo: ReclamoTipo.imagen,
    ),
    ReclamoModel(
      id: '#2024-0054',
      titulo: 'Problemas de audio en Canal 7',
      barrio: 'Barrio San Martín',
      fecha: '30/06/2025',
      hora: '18:30',
      estado: 'Finalizado',
      responsable: 'María G.',
      tipo: ReclamoTipo.audio,
    ),
    ReclamoModel(
      id: '#2024-0053',
      titulo: 'Intermitencia de señal',
      barrio: 'Barrio San Cayetano',
      fecha: '30/06/2025',
      hora: '17:20',
      estado: 'Sin tratar',
      tipo: ReclamoTipo.senal,
    ),
    ReclamoModel(
      id: '#2024-0052',
      titulo: 'Sin imagen en Canal 10',
      barrio: 'Barrio Eva Perón',
      fecha: '30/06/2025',
      hora: '16:05',
      estado: 'Tratando',
      responsable: 'Luis A.',
      tipo: ReclamoTipo.imagen,
    ),
  ];

  List<ReclamoModel> get reclamosFiltrados {
    return reclamos.where((reclamo) {
      final coincideFiltro =
          filtroSeleccionado == 'Todos' || reclamo.estado == filtroSeleccionado;

      final coincideBusqueda = reclamo.titulo
              .toLowerCase()
              .contains(busqueda.toLowerCase()) ||
          reclamo.barrio.toLowerCase().contains(busqueda.toLowerCase()) ||
          reclamo.id.toLowerCase().contains(busqueda.toLowerCase());

      return coincideFiltro && coincideBusqueda;
    }).toList();
  }

  int contarEstado(String estado) {
    return reclamos.where((r) => r.estado == estado).length;
  }

  @override
  Widget build(BuildContext context) {
    final sinTratar = contarEstado('Sin tratar');
    final tratando = contarEstado('Tratando');
    final finalizados = contarEstado('Finalizado');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3D35A8),
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo reclamo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resumenGeneral(
                    sinTratar: sinTratar,
                    tratando: tratando,
                    finalizados: finalizados,
                    total: reclamos.length,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Filtros y búsqueda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111936),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buscador(),
                  const SizedBox(height: 14),
                  _tabsEstado(
                    sinTratar: sinTratar,
                    tratando: tratando,
                    finalizados: finalizados,
                  ),
                  const SizedBox(height: 16),
                  ...reclamosFiltrados.map((reclamo) {
                    return _reclamoCard(reclamo);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 145,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF101735),
            Color(0xFF2E2A78),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: 18,
              top: 18,
              child: Icon(Icons.menu, color: Colors.white, size: 34),
            ),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RECLAMOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Gestión de reclamos del sistema',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: Stack(
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 30),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _resumenGeneral({
    required int sinTratar,
    required int tratando,
    required int finalizados,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen general',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111936),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _resumenItem(
                  icon: Icons.access_time,
                  cantidad: sinTratar,
                  texto: 'Sin tratar',
                  color: const Color(0xFFEFA700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumenItem(
                  icon: Icons.build,
                  cantidad: tratando,
                  texto: 'Tratando',
                  color: const Color(0xFF1F73E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _resumenItem(
                  icon: Icons.check,
                  cantidad: finalizados,
                  texto: 'Finalizados',
                  color: const Color(0xFF38A852),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _resumenItem(
                  icon: Icons.assignment,
                  cantidad: total,
                  texto: 'Total reclamos',
                  color: const Color(0xFF7B3FE4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumenItem({
    required IconData icon,
    required int cantidad,
    required String texto,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            cantidad.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111936),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buscador() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                busqueda = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar reclamo...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: _smallButtonDecoration(),
          child: const Row(
            children: [
              Icon(Icons.filter_list),
              SizedBox(width: 6),
              Text('Filtros'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabsEstado({
    required int sinTratar,
    required int tratando,
    required int finalizados,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _tabItem('Todos', reclamos.length, const Color(0xFF3D35A8)),
          _tabItem('Sin tratar', sinTratar, const Color(0xFFEFA700)),
          _tabItem('Tratando', tratando, const Color(0xFF1F73E8)),
          _tabItem('Finalizado', finalizados, const Color(0xFF38A852)),
        ],
      ),
    );
  }

  Widget _tabItem(String titulo, int cantidad, Color color) {
    final activo = filtroSeleccionado == titulo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            filtroSeleccionado = titulo;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: activo
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 11,
                backgroundColor: color.withOpacity(0.14),
                child: Text(
                  cantidad.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _reclamoCard(ReclamoModel reclamo) {
    final color = _estadoColor(reclamo.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: color.withOpacity(0.13),
            child: Icon(
              _iconoTipo(reclamo.tipo),
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reclamo.id,
                      style: const TextStyle(
                        color: Color(0xFF697087),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reclamo.estado,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reclamo.titulo,
                  style: const TextStyle(
                    color: Color(0xFF111936),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 17, color: Color(0xFF697087)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reclamo.barrio,
                        style: const TextStyle(color: Color(0xFF697087)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Color(0xFF697087)),
                    const SizedBox(width: 5),
                    Text(
                      '${reclamo.fecha}  •  ${reclamo.hora}',
                      style: const TextStyle(color: Color(0xFF697087)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (reclamo.responsable != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                reclamo.responsable!,
                style: const TextStyle(
                  color: Color(0xFF697087),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Icon(Icons.chevron_right, color: Color(0xFF697087)),
        ],
      ),
    );
  }

  

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 5),
        )
      ],
    );
  }

  BoxDecoration _smallButtonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Sin tratar':
        return const Color(0xFFEFA700);
      case 'Tratando':
        return const Color(0xFF1F73E8);
      case 'Finalizado':
        return const Color(0xFF38A852);
      default:
        return const Color(0xFF3D35A8);
    }
  }

  IconData _iconoTipo(ReclamoTipo tipo) {
    switch (tipo) {
      case ReclamoTipo.senal:
        return Icons.wifi;
      case ReclamoTipo.imagen:
        return Icons.tv;
      case ReclamoTipo.audio:
        return Icons.volume_up;
    }
  }
}



class ReclamoModel {
  final String id;
  final String titulo;
  final String barrio;
  final String fecha;
  final String hora;
  final String estado;
  final String? responsable;
  final ReclamoTipo tipo;

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

enum ReclamoTipo {
  senal,
  imagen,
  audio,
}