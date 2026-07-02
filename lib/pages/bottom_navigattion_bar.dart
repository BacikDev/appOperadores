import 'package:app_cabecera/pages/details_events.dart';
import 'package:app_cabecera/pages/farmacias_screen.dart';
import 'package:app_cabecera/pages/home_screen.dart';
import 'package:app_cabecera/pages/sensor_card.dart';
import 'package:flutter/material.dart';



class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> screens = [
  const HomeScreen(),
  const CanalesScreen(),
  FarmaciasScreen(),
  const PendientesScreen(),
];

  void onItemTapped(int index) {
    if (index == 4) {
      scaffoldKey.currentState?.openEndDrawer();
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,

      endDrawer: RightSideMenu(
  onSelectPage: (index) {
    setState(() {
      currentIndex = index;
    });
  },
),

      body: IndexedStack(
  index: currentIndex,
  children: screens,
),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 43, 46, 54),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF0B1220),
            selectedItemColor: const Color(0xFF7C83FF),
            unselectedItemColor: Colors.white70,
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
                icon: Icon(Icons.local_pharmacy_rounded),
                label: 'Farmacias',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_turned_in_rounded),
                label: 'Pendientes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_rounded),
                label: 'Más',
              ),
            ],
          ),
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
              onTap: () {
                Navigator.pop(context);
                onSelectPage(0);
              },
            ),

            _MenuItem(
              icon: Icons.live_tv_rounded,
              title: 'Canales',
              onTap: () {
                Navigator.pop(context);
                onSelectPage(1);
              },
            ),

            _MenuItem(
              icon: Icons.sports_soccer_rounded,
              title: 'Eventos deportivos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmaciasScreen(),
                  ),
                );
              },
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
              icon: Icons.local_pharmacy_rounded,
              title: 'Farmacia',
              onTap: () {
                Navigator.pop(context);
                onSelectPage(2);
              },
            ),

            _MenuItem(
              icon: Icons.assignment_rounded,
              title: 'Pendientes',
              onTap: () {
                Navigator.pop(context);
                onSelectPage(3);
              },
            ),

            const Divider(color: Colors.white24),

            _MenuItem(
              icon: Icons.report_problem_rounded,
              title: 'Lista de reclamos',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _MenuItem(
              icon: Icons.email_rounded,
              title: 'Correos',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _MenuItem(
              icon: Icons.article_rounded,
              title: 'Contenidos',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _MenuItem(
              icon: Icons.videocam_rounded,
              title: 'Cámaras',
              onTap: () {
                Navigator.pop(context);
              },
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
      leading: Icon(icon,color: Colors.white),
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

class CanalesScreen extends StatelessWidget {
  const CanalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Canales"),
    );
  }
}

class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Pendientes"),
    );
  }
}