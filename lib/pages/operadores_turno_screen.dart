import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OperadoresTurnoScreen extends StatefulWidget {
  const OperadoresTurnoScreen({super.key});

  @override
  State<OperadoresTurnoScreen> createState() =>
      _OperadoresTurnoScreenState();
}

enum _TipoVista { diaria, semanal }

enum _EstadoTurno { enTurno, proximo, finalizado }

class _OperadoresTurnoScreenState extends State<OperadoresTurnoScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const Color _background = Color(0xFF050B18);
  static const Color _card = Color(0xFF0D172A);
  static const Color _cardSecondary = Color(0xFF101A2E);
  static const Color _purple = Color(0xFF8A5CFF);
  static const Color _green = Color(0xFF20D489);
  static const Color _orange = Color(0xFFFFA726);
  static const Color _pink = Color(0xFFFF4F81);
  static const Color _textSecondary = Color(0xFF9BA6C7);

  final List<_TurnoOperador> _turnos = [];

  _TipoVista _vista = _TipoVista.diaria;
  DateTime _fechaSeleccionada = DateTime.now();

  Timer? _timer;
  bool _cargando = true;
  bool _actualizando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTurnos();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted && _esHoy(_fechaSeleccionada)) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime get _inicioSemana {
    final base = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
    );

    return base.subtract(Duration(days: base.weekday - 1));
  }

  DateTime get _finSemana =>
      _inicioSemana.add(const Duration(days: 6));

  List<_TurnoOperador> get _turnosDelDia {
    final resultado = _turnos.where((turno) {
      return _mismaFecha(turno.fecha, _fechaSeleccionada);
    }).toList();

    resultado.sort((a, b) => a.inicio.compareTo(b.inicio));
    return resultado;
  }

  _TurnoOperador? get _operadorActual {
    if (!_esHoy(_fechaSeleccionada)) return null;

    final ahora = DateTime.now();

    for (final turno in _turnosDelDia) {
      if (!ahora.isBefore(turno.inicio) && ahora.isBefore(turno.fin)) {
        return turno;
      }
    }

    return null;
  }

  _TurnoOperador? get _proximoOperador {
    final turnos = _turnosDelDia;

    if (turnos.isEmpty) return null;

    if (!_esHoy(_fechaSeleccionada)) {
      return turnos.first;
    }

    final ahora = DateTime.now();

    for (final turno in turnos) {
      if (turno.inicio.isAfter(ahora)) {
        return turno;
      }
    }

    return null;
  }

  Future<void> _cargarTurnos({
    bool actualizacionManual = false,
  }) async {
    try {
      if (mounted) {
        setState(() {
          _error = null;

          if (actualizacionManual) {
            _actualizando = true;
          } else {
            _cargando = true;
          }
        });
      }

      final desde = _vista == _TipoVista.diaria
          ? _fechaSeleccionada
          : _inicioSemana;

      final hasta = _vista == _TipoVista.diaria
          ? _fechaSeleccionada
          : _finSemana;

      final respuesta = await _supabase
          .from('operador_turno')
          .select(
            'id, fecha, nombre, hora_inicio, hora_fin, activo',
          )
          .eq('activo', true)
          .gte('fecha', _fechaSql(desde))
          .lte('fecha', _fechaSql(hasta))
          .order('fecha', ascending: true)
          .order('hora_inicio', ascending: true);

      final nuevosTurnos = (respuesta as List)
          .map(
            (fila) => _TurnoOperador.fromMap(
              Map<String, dynamic>.from(fila as Map),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _turnos
          ..clear()
          ..addAll(nuevosTurnos);

        _cargando = false;
        _actualizando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _actualizando = false;
        _error = 'No se pudieron cargar los turnos.';
      });
    }
  }

  Future<void> _cambiarVista(_TipoVista nuevaVista) async {
    if (_vista == nuevaVista) return;

    setState(() {
      _vista = nuevaVista;
    });

    await _cargarTurnos();
  }

  Future<void> _cambiarPeriodo(int direccion) async {
    final dias = _vista == _TipoVista.diaria
        ? direccion
        : direccion * 7;

    setState(() {
      _fechaSeleccionada =
          _fechaSeleccionada.add(Duration(days: dias));
    });

    await _cargarTurnos();
  }

  Future<void> _irAHoy() async {
    setState(() {
      _fechaSeleccionada = DateTime.now();
    });

    await _cargarTurnos();
  }

  Future<void> _abrirSelectorFecha() async {
    DateTime temporal = _fechaSeleccionada;

    final seleccion = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final diasMes = _generarDiasMes(temporal);
            final primerDia = DateTime(temporal.year, temporal.month, 1);
            final espaciosIniciales = primerDia.weekday - 1;

            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              temporal = DateTime(
                                temporal.year,
                                temporal.month - 1,
                                1,
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: _purple,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${_mesCapitalizado(temporal.month)} '
                            '${temporal.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              temporal = DateTime(
                                temporal.year,
                                temporal.month + 1,
                                1,
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: _purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        _DiaSemanaLabel('Lun'),
                        _DiaSemanaLabel('Mar'),
                        _DiaSemanaLabel('Mié'),
                        _DiaSemanaLabel('Jue'),
                        _DiaSemanaLabel('Vie'),
                        _DiaSemanaLabel('Sáb'),
                        _DiaSemanaLabel('Dom'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: espaciosIniciales + diasMes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                        if (index < espaciosIniciales) {
                          return const SizedBox.shrink();
                        }

                        final fecha = diasMes[index - espaciosIniciales];
                        final seleccionada =
                            _mismaFecha(fecha, _fechaSeleccionada);
                        final hoy = _esHoy(fecha);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () => Navigator.pop(context, fecha),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: seleccionada
                                    ? _purple
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: hoy && !seleccionada
                                    ? Border.all(
                                        color: _green,
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: Text(
                                '${fecha.day}',
                                style: TextStyle(
                                  color: seleccionada
                                      ? Colors.white
                                      : hoy
                                          ? _green
                                          : Colors.white,
                                  fontWeight:
                                      seleccionada || hoy
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, DateTime.now());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _purple,
                          side: const BorderSide(color: _purple),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        icon: const Icon(Icons.today_rounded),
                        label: const Text('Ir a hoy'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (seleccion == null) return;

    setState(() {
      _fechaSeleccionada = seleccion;
    });

    await _cargarTurnos();
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
          'Operadores de turno',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Hoy',
            onPressed: _irAHoy,
            icon: const Icon(
              Icons.today_rounded,
              color: _textSecondary,
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizando
                ? null
                : () => _cargarTurnos(
                      actualizacionManual: true,
                    ),
            icon: _actualizando
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      color: _purple,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: _purple,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _purple,
          backgroundColor: _card,
          onRefresh: () => _cargarTurnos(
            actualizacionManual: true,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
            children: [
              _buildSelectorVista(),
              const SizedBox(height: 12),
              if (_vista == _TipoVista.diaria) ...[
                _buildSelectorDiario(),
                const SizedBox(height: 16),
              ],
              if (_cargando)
                _buildLoading()
              else if (_error != null)
                _buildError()
              else if (_vista == _TipoVista.diaria)
                _buildVistaDiaria()
              else
                _buildVistaSemanal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorVista() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BotonVista(
              texto: 'Vista diaria',
              icono: Icons.view_day_rounded,
              seleccionado: _vista == _TipoVista.diaria,
              onTap: () => _cambiarVista(_TipoVista.diaria),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _BotonVista(
              texto: 'Vista semanal',
              icono: Icons.calendar_view_week_rounded,
              seleccionado: _vista == _TipoVista.semanal,
              onTap: () => _cambiarVista(_TipoVista.semanal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorDiario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _cambiarPeriodo(-1),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: _textSecondary,
              size: 31,
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _abrirSelectorFecha,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: _purple,
                        size: 24,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _fechaVisible(_fechaSeleccionada),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tocá para elegir una fecha',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _cambiarPeriodo(1),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: _textSecondary,
              size: 31,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaDiaria() {
    final actual = _operadorActual;
    final siguiente = _proximoOperador;
    final turnos = _turnosDelDia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_esHoy(_fechaSeleccionada)) ...[
          _buildOperadorActual(
            actual: actual,
            siguiente: siguiente,
          ),
          const SizedBox(height: 22),
        ],
        _buildTituloSeccion(
          icono: Icons.schedule_rounded,
          titulo: 'CRONOGRAMA DEL DÍA',
        ),
        const SizedBox(height: 12),
        if (turnos.isEmpty)
          _buildSinTurnos(
            'No hay operadores asignados para esta fecha.',
          )
        else
          ...turnos.map(_buildTurnoDiario),
      ],
    );
  }

  Widget _buildVistaSemanal() {
    final seleccionados = _turnosDelDia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEncabezadoSemanal(),
        const SizedBox(height: 14),
        _buildCalendarioSemanal(),
        const SizedBox(height: 18),
        if (seleccionados.isNotEmpty) ...[
          _buildRangoHorario(seleccionados),
          const SizedBox(height: 18),
        ],
        _buildTituloSeccion(
          icono: Icons.event_note_rounded,
          titulo: _tituloTurnosFecha(_fechaSeleccionada),
        ),
        const SizedBox(height: 12),
        if (seleccionados.isEmpty)
          _buildSinTurnos(
            'No hay operadores asignados para el día seleccionado.',
          )
        else
          ...seleccionados.asMap().entries.map(
                (entry) => _buildTurnoAgenda(
                  entry.value,
                  index: entry.key,
                ),
              ),
      ],
    );
  }

  Widget _buildEncabezadoSemanal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _cambiarPeriodo(-1),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _purple,
              size: 18,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_mesCapitalizado(_fechaSeleccionada.month)} '
                  '${_fechaSeleccionada.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_fechaCorta(_inicioSemana)} · '
                  '${_fechaCorta(_finSemana)}',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _abrirSelectorFecha,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: _purple,
                size: 21,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _cambiarPeriodo(1),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _purple,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarioSemanal() {
    final dias = List.generate(
      7,
      (index) => _inicioSemana.add(Duration(days: index)),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: dias.map((fecha) {
              return Expanded(
                child: Center(
                  child: Text(
                    _diaCorto(fecha),
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 13),
          Row(
            children: dias.map((fecha) {
              final seleccionado =
                  _mismaFecha(fecha, _fechaSeleccionada);
              final hoy = _esHoy(fecha);
              final tieneTurnos = _turnos.any(
                (turno) => _mismaFecha(turno.fecha, fecha),
              );

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      setState(() {
                        _fechaSeleccionada = fecha;
                      });
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 39,
                          height: 39,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? _purple
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: hoy && !seleccionado
                                ? Border.all(
                                    color: _green,
                                    width: 1.5,
                                  )
                                : null,
                            boxShadow: seleccionado
                                ? [
                                    BoxShadow(
                                      color: _purple.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            '${fecha.day}',
                            style: TextStyle(
                              color: seleccionado
                                  ? Colors.white
                                  : hoy
                                      ? _green
                                      : Colors.white,
                              fontWeight: seleccionado || hoy
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: tieneTurnos
                                ? seleccionado
                                    ? _green
                                    : _purple
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRangoHorario(List<_TurnoOperador> turnos) {
    final primero = turnos.first;
    final ultimo = turnos.last;

    return Row(
      children: [
        Expanded(
          child: _buildHorarioChip(
            icono: Icons.login_rounded,
            titulo: 'Inicio',
            hora: primero.horaInicio,
            color: _purple,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _cardSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: _textSecondary,
              size: 16,
            ),
          ),
        ),
        Expanded(
          child: _buildHorarioChip(
            icono: Icons.logout_rounded,
            titulo: 'Final',
            hora: ultimo.horaFin,
            color: _green,
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioChip({
    required IconData icono,
    required String titulo,
    required String hora,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '$hora hs',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperadorActual({
    required _TurnoOperador? actual,
    required _TurnoOperador? siguiente,
  }) {
    if (actual == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _orange.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_rounded,
                color: _orange,
                size: 35,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'SIN OPERADOR EN TURNO',
              style: TextStyle(
                color: _orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'No hay un operador asignado en este horario.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
              ),
            ),
            if (siguiente != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _cardSecondary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.next_plan_rounded,
                      color: _green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Próximo: ${siguiente.nombre} · '
                        '${siguiente.horaInicio} hs',
                        style: const TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _purple.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.13),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _PuntoActivo(),
              SizedBox(width: 8),
              Text(
                'EN TURNO AHORA',
                style: TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Container(
                width: 69,
                height: 69,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: _purple, width: 2),
                ),
                child: Text(
                  actual.iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Operador responsable',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      actual.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${actual.horaInicio} - ${actual.horaFin} hs',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: _cardSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timelapse_rounded,
                  color: _orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _tiempoRestante(actual),
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.verified_rounded,
                  color: _green,
                  size: 21,
                ),
              ],
            ),
          ),
          if (siguiente != null) ...[
            const SizedBox(height: 11),
            Text(
              'Siguiente: ${siguiente.nombre} · '
              '${siguiente.horaInicio} hs',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTurnoDiario(_TurnoOperador turno) {
    final visual = _visualEstado(_obtenerEstado(turno));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: visual.estado == _EstadoTurno.enTurno
            ? _purple.withValues(alpha: 0.12)
            : _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: visual.estado == _EstadoTurno.enTurno
              ? _purple.withValues(alpha: 0.55)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          _AvatarIniciales(
            iniciales: turno.iniciales,
            color: visual.color,
            size: 51,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turno.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${turno.horaInicio} - ${turno.horaFin} hs',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _BadgeEstado(visual: visual),
        ],
      ),
    );
  }

  Widget _buildTurnoAgenda(
    _TurnoOperador turno, {
    required int index,
  }) {
    final visual = _visualEstado(_obtenerEstado(turno));

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: visual.estado == _EstadoTurno.enTurno
              ? _green.withValues(alpha: 0.40)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 63,
            decoration: BoxDecoration(
              color: index.isEven ? _purple : _green,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turno.horaInicio,
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  turno.horaFin,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white10,
          ),
          const SizedBox(width: 12),
          _AvatarIniciales(
            iniciales: turno.iniciales,
            color: visual.color,
            size: 43,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  turno.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      visual.icono,
                      color: visual.color,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      visual.texto,
                      style: TextStyle(
                        color: visual.color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSeccion({
    required IconData icono,
    required String titulo,
  }) {
    return Row(
      children: [
        Icon(icono, color: _purple, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: _purple,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: _purple,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Cargando turnos...',
                style: TextStyle(color: _textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _pink.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: _pink,
            size: 45,
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Ocurrió un error.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _cargarTurnos,
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSinTurnos(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: _purple,
              size: 32,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Sin turnos programados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _VisualEstado _visualEstado(_EstadoTurno estado) {
    switch (estado) {
      case _EstadoTurno.enTurno:
        return const _VisualEstado(
          estado: _EstadoTurno.enTurno,
          texto: 'EN TURNO',
          color: _green,
          icono: Icons.radio_button_checked_rounded,
        );
      case _EstadoTurno.proximo:
        return const _VisualEstado(
          estado: _EstadoTurno.proximo,
          texto: 'PROGRAMADO',
          color: _orange,
          icono: Icons.schedule_rounded,
        );
      case _EstadoTurno.finalizado:
        return const _VisualEstado(
          estado: _EstadoTurno.finalizado,
          texto: 'FINALIZADO',
          color: _textSecondary,
          icono: Icons.check_circle_outline_rounded,
        );
    }
  }

  _EstadoTurno _obtenerEstado(_TurnoOperador turno) {
    final ahora = DateTime.now();

    if (!ahora.isBefore(turno.inicio) && ahora.isBefore(turno.fin)) {
      return _EstadoTurno.enTurno;
    }

    if (ahora.isBefore(turno.inicio)) {
      return _EstadoTurno.proximo;
    }

    return _EstadoTurno.finalizado;
  }

  String _tiempoRestante(_TurnoOperador turno) {
    final diferencia = turno.fin.difference(DateTime.now());

    if (diferencia.isNegative) {
      return 'Turno finalizado';
    }

    final horas = diferencia.inHours;
    final minutos = diferencia.inMinutes.remainder(60);

    if (horas > 0) {
      return 'Finaliza en ${horas}h ${minutos}min';
    }

    return 'Finaliza en ${minutos}min';
  }

  List<DateTime> _generarDiasMes(DateTime fecha) {
    final ultimoDia = DateTime(fecha.year, fecha.month + 1, 0).day;

    return List.generate(
      ultimoDia,
      (index) => DateTime(fecha.year, fecha.month, index + 1),
    );
  }

  String _fechaVisible(DateTime fecha) {
    if (_esHoy(fecha)) {
      return 'Hoy, ${fecha.day} de ${_nombreMes(fecha.month)}';
    }

    final manana = DateTime.now().add(const Duration(days: 1));

    if (_mismaFecha(fecha, manana)) {
      return 'Mañana, ${fecha.day} de ${_nombreMes(fecha.month)}';
    }

    final ayer = DateTime.now().subtract(const Duration(days: 1));

    if (_mismaFecha(fecha, ayer)) {
      return 'Ayer, ${fecha.day} de ${_nombreMes(fecha.month)}';
    }

    return '${_nombreDia(fecha)}, ${fecha.day} de '
        '${_nombreMes(fecha.month)}';
  }

  String _tituloTurnosFecha(DateTime fecha) {
    if (_esHoy(fecha)) return 'TURNOS DE HOY';

    return 'TURNOS DEL ${fecha.day} DE '
        '${_nombreMes(fecha.month).toUpperCase()}';
  }

  String _fechaCorta(DateTime fecha) {
    return '${fecha.day} ${_nombreMes(fecha.month).substring(0, 3)}';
  }

  String _nombreDia(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return dias[fecha.weekday - 1];
  }

  String _diaCorto(DateTime fecha) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  String _nombreMes(int mes) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return meses[mes - 1];
  }

  String _mesCapitalizado(int mes) {
    final nombre = _nombreMes(mes);
    return '${nombre[0].toUpperCase()}${nombre.substring(1)}';
  }

  String _fechaSql(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  bool _esHoy(DateTime fecha) {
    return _mismaFecha(fecha, DateTime.now());
  }

  bool _mismaFecha(DateTime primera, DateTime segunda) {
    return primera.year == segunda.year &&
        primera.month == segunda.month &&
        primera.day == segunda.day;
  }
}

class _BotonVista extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonVista({
    required this.texto,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8A5CFF);
    const textSecondary = Color(0xFF9BA6C7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: seleccionado ? purple : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                color: seleccionado ? Colors.white : textSecondary,
                size: 19,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: seleccionado ? Colors.white : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

class _PuntoActivo extends StatelessWidget {
  const _PuntoActivo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF20D489),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF20D489),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _DiaSemanaLabel extends StatelessWidget {
  final String texto;

  const _DiaSemanaLabel(this.texto);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF9BA6C7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AvatarIniciales extends StatelessWidget {
  final String iniciales;
  final Color color;
  final double size;

  const _AvatarIniciales({
    required this.iniciales,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        iniciales,
        style: TextStyle(
          color: color,
          fontSize: size * 0.28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final _VisualEstado visual;

  const _BadgeEstado({
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            visual.icono,
            color: visual.color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            visual.texto,
            style: TextStyle(
              color: visual.color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualEstado {
  final _EstadoTurno estado;
  final String texto;
  final Color color;
  final IconData icono;

  const _VisualEstado({
    required this.estado,
    required this.texto,
    required this.color,
    required this.icono,
  });
}

class _TurnoOperador {
  final int? id;
  final DateTime fecha;
  final String nombre;
  final String horaInicio;
  final String horaFin;
  final DateTime inicio;
  final DateTime fin;

  const _TurnoOperador({
    required this.id,
    required this.fecha,
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.inicio,
    required this.fin,
  });

  String get iniciales {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '--';

    if (partes.length == 1) {
      final palabra = partes.first;

      if (palabra.length == 1) {
        return palabra.toUpperCase();
      }

      return palabra.substring(0, 2).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  factory _TurnoOperador.fromMap(Map<String, dynamic> map) {
    final fecha = DateTime.parse(map['fecha'].toString());

    final horaInicio = _normalizarHora(
      map['hora_inicio']?.toString() ?? '00:00',
    );

    final horaFin = _normalizarHora(
      map['hora_fin']?.toString() ?? '00:00',
    );

    final inicio = _combinarFechaHora(fecha, horaInicio);
    var fin = _combinarFechaHora(fecha, horaFin);

    if (!fin.isAfter(inicio)) {
      fin = fin.add(const Duration(days: 1));
    }

    return _TurnoOperador(
      id: int.tryParse(map['id']?.toString() ?? ''),
      fecha: fecha,
      nombre: map['nombre']?.toString() ?? 'Operador sin nombre',
      horaInicio: horaInicio,
      horaFin: horaFin,
      inicio: inicio,
      fin: fin,
    );
  }

  static String _normalizarHora(String hora) {
    final partes = hora.split(':');

    if (partes.length < 2) return '00:00';

    return '${partes[0].padLeft(2, '0')}:'
        '${partes[1].padLeft(2, '0')}';
  }

  static DateTime _combinarFechaHora(
    DateTime fecha,
    String hora,
  ) {
    final partes = hora.split(':');

    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.tryParse(partes[0]) ?? 0,
      int.tryParse(partes[1]) ?? 0,
    );
  }
}
