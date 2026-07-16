import 'package:app_cabecera/controller/WeatherController.dart';
import 'package:app_cabecera/controller/sensor_controller.dart';
import 'package:app_cabecera/controller/connection_status_controller.dart';
import 'package:app_cabecera/pages/blue_iris_screen.dart';
import 'package:app_cabecera/pages/canales_screen.dart';
import 'package:app_cabecera/pages/farmacias_screen.dart';
import 'package:app_cabecera/pages/operadores_turno_screen.dart';
import 'package:app_cabecera/pages/pendientes_screen.dart';
import 'package:app_cabecera/pages/security_cameras_screen.dart';
import 'package:app_cabecera/pages/sensor_card.dart';
import 'package:app_cabecera/pages/sports_screen.dart';
import 'package:app_cabecera/pages/transmisiones_screen.dart';
import 'package:app_cabecera/pages/weather_screen.dart.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  final SensorController sensorController = Get.put(SensorController());
  final WeatherController weatherController = Get.put(WeatherController());
  final ConnectionStatusController connectionStatusController =
      Get.find<ConnectionStatusController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sensorController.cargarDatos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      connectionStatusController.comprobarTodo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardHomeScreen();
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  ConnectionStatusController get _connectionStatus =>
      Get.find<ConnectionStatusController>();

  void _openScreen(BuildContext context, Widget screen) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, animation, __) => screen,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 4),
              Obx(() {
                final internet =
                    _connectionStatus.internetDisponible.value;
                final supabase =
                    _connectionStatus.supabaseDisponible.value;
                final vpn = _connectionStatus.vpnActiva.value;

                return _ConnectionStatusBanner(
                  internet: internet,
                  supabase: supabase,
                  vpn: vpn,
                );
              }),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Panel de control operativo',
                        style: TextStyle(
                          color: Color(0xFF9BA6C7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  _WeatherMiniCard(),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                'MÓDULOS',
                style: TextStyle(
                  color: Color(0xFF8A5CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                flex: 3,
                child: Obx(() {
                  final vpnActiva =
                      _connectionStatus.vpnActiva.value;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.08,
        children: [
          _ModuleCard(
            icon: Icons.live_tv_rounded,
            title: 'Canales',
            color: const Color(0xFF1296FF),
            onTap: () => _openScreen(context, CanalesScreen()),
          ),
          _ModuleCard(
            icon: Icons.sports_soccer_rounded,
            title: 'Eventos',
            color: const Color(0xFF20D489),
            onTap: () => _openScreen(
              context,
              SportsScreen(
                deporteId: null,
                nombre: null,
                fondo: null,
              ),
            ),
          ),
          _ModuleCard(
            icon: Icons.local_pharmacy_rounded,
            title: 'Farmacias',
            color: const Color(0xFF8A5CFF),
            onTap: () => _openScreen(context, FarmaciasScreen()),
          ),
          _ModuleCard(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Pendientes',
            color: const Color(0xFFFFA726),
            onTap: () => _openScreen(
              context,
              const PendientesScreen(),
            ),
          ),
          _ModuleCard(
            icon: Icons.videocam_rounded,
            title: 'Cámaras',
            color: const Color(0xFF00D1C1),
            enabled: vpnActiva,
            disabledLabel: 'VPN requerida',
            onTap: () => _openScreen(context, BlueIrisScreen()),
          ),
          // _ModuleCard(
          //   icon: Icons.videocam_rounded,
          //   title: 'Cámaras Seguridad',
          //   color: const Color(0xFF00D1C1),
          //   onTap: () => _openScreen(context, SecurityCamerasScreen()),
          // ),
          _ModuleCard(
            icon: Icons.live_tv_rounded,
            title: 'En vivo',
            color: const Color(0xFF8B5CFF),
            enabled: vpnActiva,
            disabledLabel: 'VPN requerida',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransmisionesScreen(),
                ),
              );
            },
          ),
          
                        ],
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 8),

              const Row(
                children: [
                  Expanded(child: _OperatorCard()),
                  SizedBox(width: 10),
                  Expanded(child: _CabeceraCard()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionStatusBanner extends StatelessWidget {
  final bool internet;
  final bool supabase;
  final bool vpn;

  const _ConnectionStatusBanner({
    required this.internet,
    required this.supabase,
    required this.vpn,
  });

  @override
  Widget build(BuildContext context) {

    final color = !internet
        ? const Color(0xFFFF4F81)
        : !supabase
            ? const Color(0xFFFFA726)
            : vpn
                ? const Color(0xFF20D489)
                : const Color(0xFFFFA726);

    final texto = !internet
        ? 'Sin conexión a Internet'
        : !supabase
            ? 'Supabase no disponible'
            : vpn
                ? 'Red ECC disponible'
                : 'VPN apagada · Cámaras y transmisiones deshabilitadas';

    final icono = !internet
        ? Icons.wifi_off_rounded
        : vpn
            ? Icons.shield_rounded
            : Icons.vpn_key_off_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.tv_outlined,
          color: Color(0xFF8A5CFF),
          size: 42,
        ),
        SizedBox(width: 6),
        Column(
          children: [
            Text(
              'EL LÍDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 23,
              ),
            ),
            Text(
              'Junto a Vos',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 5,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherMiniCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.find<WeatherController>();

    return Obx(() {
      if (weatherController.isLoading.value) {
        return _weatherContainer(
          child: const SizedBox(
            width: 145,
            height: 55,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8A5CFF),
                strokeWidth: 2,
              ),
            ),
          ),
        );
      }

      final ultima = weatherController.ultimaActualizacion.value;

      final hora = ultima == null
          ? ''
          : '${ultima.hour.toString().padLeft(2, '0')}:${ultima.minute.toString().padLeft(2, '0')}';

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WeatherScreen(),
              ),
            );
          },
          child: _weatherContainer(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  weatherController.iconoClima,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weatherController.temperatura.value.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: Text(
                        weatherController.descripcion.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9BA6C7),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      '💧 ${weatherController.humedad.value}%  🌬 ${weatherController.viento.value.toStringAsFixed(0)} km/h',
                      style: const TextStyle(
                        color: Color(0xFF9BA6C7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _weatherContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
  final String? disabledLabel;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.enabled = true,
    this.disabledLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: enabled
            ? onTap
            : () {
                Get.snackbar(
                  'VPN ZeroTier requerida',
                  'Este módulo no está habilitado porque la VPN no está activa.',
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFF0D172A),
                  colorText: Colors.white,
                  icon: const Icon(
                    Icons.vpn_key_off_rounded,
                    color: Color(0xFFFFA726),
                  ),
                );
              },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: enabled ? 1 : 0.48,
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Icon(
                  icon,
                  color: color,
                  size: 42,
                ),
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (enabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 13,
                )
              else
                Text(
                  disabledLabel ?? 'No disponible',
                  style: const TextStyle(
                    color: Color(0xFFFFA726),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _OperatorCard extends StatefulWidget {
  const _OperatorCard();

  @override
  State<_OperatorCard> createState() => _OperatorCardState();
}

class _OperatorCardState extends State<_OperatorCard> {
  final SupabaseClient _supabase = Supabase.instance.client;

  Timer? _timer;

  bool _cargando = true;
  String? _error;

  String _operadorActual = 'Sin turno';
  String _horarioActual = '--:-- - --:--';

  String _operadorSiguiente = 'Sin próximo turno';
  String _horarioSiguiente = '';

  @override
  void initState() {
    super.initState();
    _cargarTurnos();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cargarTurnos(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarTurnos() async {
    try {
      final ahora = DateTime.now();
      final desde = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ).subtract(const Duration(days: 1));

      final hasta = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ).add(const Duration(days: 2));

      final respuesta = await _supabase
          .from('operador_turno')
          .select(
            'id, fecha, nombre, hora_inicio, hora_fin, activo',
          )
          .eq('activo', true)
          .gte('fecha', _formatearFecha(desde))
          .lte('fecha', _formatearFecha(hasta))
          .order('fecha', ascending: true)
          .order('hora_inicio', ascending: true);

      final turnos = (respuesta as List)
          .map(
            (fila) => _TurnoOperador.fromMap(
              Map<String, dynamic>.from(fila as Map),
            ),
          )
          .toList();

      _TurnoOperador? actual;
      _TurnoOperador? siguiente;

      for (final turno in turnos) {
        if (!ahora.isBefore(turno.inicio) &&
            ahora.isBefore(turno.fin)) {
          actual = turno;
          break;
        }
      }

      for (final turno in turnos) {
        if (turno.inicio.isAfter(ahora)) {
          siguiente = turno;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = null;

        if (actual != null) {
          _operadorActual = actual.nombre;
          _horarioActual =
              '${actual.horaInicio} - ${actual.horaFin} hs';
        } else {
          _operadorActual = 'Sin operador asignado';
          _horarioActual = '--:-- - --:--';
        }

        if (siguiente != null) {
          _operadorSiguiente = siguiente.nombre;
          _horarioSiguiente =
              '${siguiente.horaInicio} - ${siguiente.horaFin} hs';
        } else {
          _operadorSiguiente = 'Sin próximo turno';
          _horarioSiguiente = '';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No se pudo cargar';
      });
    }
  }
  

  String _formatearFecha(DateTime fecha) {
    final year = fecha.year.toString().padLeft(4, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
  

  @override
Widget build(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const OperadoresTurnoScreen(),
          ),
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'OPERADOR DE TURNO',
                style: TextStyle(
                  color: Color(0xFF8A5CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF8A5CFF),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF6C63FF),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _error != null
                              ? Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF4F81),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _operadorActual,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      _horarioActual,
                                      style: const TextStyle(
                                        color: Color(0xFF9BA6C7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Siguiente: $_operadorSiguiente',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF20D489),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (_horarioSiguiente.isNotEmpty)
                                      Text(
                                        _horarioSiguiente,
                                        style: const TextStyle(
                                          color: Color(0xFF9BA6C7),
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _TurnoOperador {
  final String nombre;
  final String horaInicio;
  final String horaFin;
  final DateTime inicio;
  final DateTime fin;

  const _TurnoOperador({
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.inicio,
    required this.fin,
  });

  factory _TurnoOperador.fromMap(Map<String, dynamic> map) {
    final fecha = DateTime.parse(map['fecha'].toString());
    final horaInicio = _normalizarHora(
      map['hora_inicio'].toString(),
    );
    final horaFin = _normalizarHora(
      map['hora_fin'].toString(),
    );

    final inicio = _combinarFechaHora(fecha, horaInicio);
    var fin = _combinarFechaHora(fecha, horaFin);

    if (!fin.isAfter(inicio)) {
      fin = fin.add(const Duration(days: 1));
    }

    return _TurnoOperador(
      nombre: map['nombre']?.toString() ?? 'Sin nombre',
      horaInicio: horaInicio,
      horaFin: horaFin,
      inicio: inicio,
      fin: fin,
    );
  }

  static String _normalizarHora(String hora) {
    final partes = hora.split(':');

    if (partes.length < 2) {
      return '00:00';
    }

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
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }
}

class _CabeceraCard extends StatelessWidget {
  const _CabeceraCard();

  @override
  Widget build(BuildContext context) {
    final SensorController sensorController = Get.find<SensorController>();

    return Obx(() {
      final lectura = sensorController.ultimaLectura.value;

      if (lectura == null) {
        return _cabeceraContainer(
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8A5CFF),
            ),
          ),
        );
      }

      final hora =
          '${lectura.createdAt.hour.toString().padLeft(2, '0')}:${lectura.createdAt.minute.toString().padLeft(2, '0')}';

      final temperatura = lectura.temperatura;
      final humedad = lectura.humedad;

      final estado = temperatura >= 23
          ? 'Prender extractor'
          : 'Estado normal';

      final estadoColor = temperatura >= 23
          ? const Color(0xFFFFA726)
          : const Color(0xFF20D489);

      return Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SensorDashboardPage(),
        ),
      );
    },
    child: _cabeceraContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
            Center(
              child: const Text(
                'CABECERA',
                style: TextStyle(
                  color: Color(0xFF8A5CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                const Icon(
                  Icons.thermostat_rounded,
                  color: Color(0xFFFF4F81),
                  size: 28,
                ),
                Expanded(
                  child: _SensorValue(
                    title: 'Temp.',
                    value: '${temperatura.toStringAsFixed(1)}°',
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF2997FF),
                  size: 25,
                ),
                Expanded(
                  child: _SensorValue(
                    title: 'Hum.',
                    value: '${humedad.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),

            const Spacer(),

            Row(
              children: [
                Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 16)),
                Icon(
                  temperatura >= 23
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: estadoColor,
                  size: 16,
                ),
                Expanded(
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            Center(
              child: Text(
                'Actualizado $hora',
                style: const TextStyle(
                  color: Color(0xFF9BA6C7),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);
      
    });
  }

  Widget _cabeceraContainer({required Widget child}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _SensorValue extends StatelessWidget {
  final String title;
  final String value;

  const _SensorValue({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9BA6C7),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}