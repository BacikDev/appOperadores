import 'package:app_cabecera/controller/sensor_controller.dart';
import 'package:app_cabecera/pages/canales_screen.dart';
import 'package:app_cabecera/pages/farmacias_screen.dart';
import 'package:app_cabecera/pages/sensor_card.dart';
import 'package:app_cabecera/pages/sports_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SensorController sensorController = Get.put(SensorController());

@override
void initState() {
  super.initState();
  sensorController.cargarDatos();
}
  int currentIndex = 0;

  late final List<Widget> screens = [
    DashboardHomeScreen(scaffoldKey: scaffoldKey),
     CanalesScreen(),
     SportsScreen(deporteId: null, nombre: null, fondo: null,),
     FarmaciasScreen(),
     PendientesScreen(),
  
  ];

  void onItemTapped(int index) {
    if (index == 4) {
      scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    if (index < screens.length) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  void openPage(int index) {
    Navigator.pop(context);

    if (index < screens.length) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 174, 196, 242),
      endDrawer: RightSideMenu(onSelectPage: openPage),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DashboardHomeScreen({
    super.key,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
              _Header(scaffoldKey: scaffoldKey),

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
                      SizedBox(height: 2),
                      Text(
                        'Panel de control operativo',
                        style: TextStyle(
                          color: Color(0xFF9BA6C7),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  _WeatherMiniCard(),
                ],
              ),

              const SizedBox(height: 3),

              const Text(
                'MÓDULOS',
                style: TextStyle(
                  color: Color(0xFF8A5CFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 5),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
                children: [
                  _ModuleCard(
                    icon: Icons.live_tv_rounded,
                    title: 'Canales',
                    color: Color(0xFF1296FF),
                    onTap: () {
                      final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
                      state?.onItemTapped(1);
                    },
                  ),
                  _ModuleCard(
                    icon: Icons.sports_soccer_rounded,
                    title: 'Eventos',
                    color: Color(0xFF20D489),
                    onTap: () {
                      final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
                      state?.onItemTapped(2);
                    },
                  ),
                  _ModuleCard(
                    icon: Icons.local_pharmacy_rounded,
                    title: 'Farmacias',
                    color: Color(0xFF8A5CFF),
                    onTap: () {
                      final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
                      state?.onItemTapped(3);
                    },
                  ),
                  _ModuleCard(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Pendientes',
                    color: Color(0xFFFFA726),
                    onTap: () {},
                  ),
                  _ModuleCard(
                    icon: Icons.report_problem_rounded,
                    title: 'Reclamos',
                    color: Color(0xFFFF4F81),
                    onTap: () {},
                  ),
                  _ModuleCard(
                    icon: Icons.videocam_rounded,
                    title: 'Cámaras',
                    color: Color(0xFF00D1C1),
                    onTap: () {},
                  ),
                  _ModuleCard(
                    icon: Icons.folder_rounded,
                    title: 'Contenido',
                    color: Color(0xFF00D1C1),
                    onTap: () {},
                  ),
                  _ModuleCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Sutítulados',
                    color: Color(0xFF2979FF),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: const [
                  Expanded(child: _OperatorCard()),
                  SizedBox(width: 14),
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

class _Header extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _Header({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 32),
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        const Spacer(),
        const Icon(
          Icons.tv_outlined,
          color: Color(0xFF8A5CFF),
          size: 48,
        ),
        const SizedBox(width: 5),
        const Column(
          children: [
            Text(
              'EL LÍDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 24,
              ),
            ),
            Text(
              'Junto a Vos',
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 5,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const Spacer(),

        // NOTIFICACIONES
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 8,
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_queue_rounded, color: Colors.white, size: 34),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '23°C',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                'Parcialmente nublado',
                style: TextStyle(
                  color: Color(0xFF9BA6C7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFF0D172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 50),
              const SizedBox(height: 1),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              const SizedBox(height: 1),
              Icon(Icons.keyboard_arrow_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  const _OperatorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),

      ), 
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'OPERADOR DE TURNO',
              style: TextStyle(
                color: Color(0xFF8A5CFF),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 3),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(Icons.person, color: Colors.white, size: 34),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joaquín',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '08:00 - 16:00 hs',
                      style: TextStyle(color: Color(0xFF9BA6C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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


class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex > 3 ? 0 : currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B1220),
          selectedItemColor: const Color(0xFF8A5CFF),
          unselectedItemColor: Colors.white54,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_rounded),
              label: 'Canales',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_outlined),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_rounded),
              label: 'Farmacias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}

class RightSideMenu extends StatelessWidget {
  final Function(int) onSelectPage;

  const RightSideMenu({
    super.key,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1220),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const SizedBox(height: 20),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(Icons.live_tv_rounded, color: Colors.white),
              ),
              title: Text(
                'Cabecera App',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Panel de control',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            _MenuItem(
              icon: Icons.home_rounded,
              title: 'Inicio',
              onTap: () => onSelectPage(0),
            ),
            _MenuItem(
              icon: Icons.live_tv_rounded,
              title: 'Canales',
              onTap: () => onSelectPage(1),
            ),
            _MenuItem(
              icon: Icons.sports_soccer_outlined,
              title: 'Eventos Deportivos',
              onTap: () => onSelectPage(2),
            ),
            _MenuItem(
              icon: Icons.medical_services_outlined,
              title: 'Farmacias',
              onTap: () => onSelectPage(3),
            ),
            const Divider(color: Colors.white24),
            _MenuItem(
              icon: Icons.sports_soccer_rounded,
              title: 'Eventos deportivos',
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.thermostat_rounded,
              title: 'Temperatura',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SensorDashboardPage(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.report_problem_rounded,
              title: 'Lista de reclamos',
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.email_rounded,
              title: 'Correos',
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.article_rounded,
              title: 'Contenidos',
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.videocam_rounded,
              title: 'Cámaras',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF050B18),
      body: Center(
        child: Text(
          'Pendientes',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}